-- Problem 1: We're reviewing pricing for our bags.
-- Include product name, list price, and unit cost.
-- Label each product 'Premium' if its list price is at least $60,
-- 'Midrange' if it's at least $30 but below $60,
-- and 'Budget' otherwise.
-- Put the most expensive products first.

select productname, listprice, unitcost,
	case 
		when ListPrice >= 60 then 'Premium'
		when ListPrice >= 30 then 'Midrange'
		else 'Budget'
		end as 'PriceTier'
from dbo.RetailProducts
where category = 'Bags'
order by ListPrice desc;

-- Problem 2: We're reviewing potential profit on our accessories.
-- Include product name, list price, unit cost, and the difference
-- between list price and unit cost as PotentialProfit.
-- Label that difference 'High' at $25 or more,
-- 'Medium' at $15 up to but not including $25,
-- and 'Low' below $15. Name the column ProfitTier.
-- Put products with the highest potential profit first.

select productname, listprice, unitcost, listprice - unitcost as PotentialProfit,
		case
				when listprice - unitcost >= 25 then 'High'
				when listprice - unitcost >= 15 then 'Medium'
				else 'Low'
			end as ProfitTier
from dbo.RetailProducts
where category = 'Accessories'
order by PotentialProfit desc;

-- Problem 3: We want to flag our most valuable individual order lines.
-- Include order item ID, order ID, quantity, unit price,
-- and the line's total value as LineTotal.
-- Label each line 'High Value' at $150 or more,
-- 'Medium Value' at $75 up to but not including $150,
-- and 'Low Value' below $75. Name the column ValueTier.
-- Only include lines with at least 2 units.
-- Put the highest-value lines first.

select orderitemid, orderid, quantity, unitprice, quantity * unitprice as LineTotal,
	case	
		when quantity * unitprice >= 150 then 'High Value'
		when quantity * unitprice >= 75 then 'Medium Value'
		else 'Low Value'
	end as ValueTier
from dbo.orderitems
where quantity >= 2
order by LineTotal desc;

-- Problem 4: We're reviewing individual order lines for bulk purchases.
-- Include order item ID, product ID, quantity, unit price,
-- and the line's total value as LineTotal.
-- Only include lines with a unit price of at least $20.
-- Add a SizeTier column:
-- 4 or more units: 'Large'
-- 2 or 3 units: 'Medium'
-- Otherwise: 'Small'
-- Put the largest quantities first, then highest line totals.

select orderitemid, productid, quantity, unitprice, quantity * unitprice as LineTotal,
	case
		when Quantity >= 4 then 'Large'
		when Quantity >= 2 then 'Medium'
		else 'Small'
	end as SizeTier
from dbo.orderitems
where unitprice >= 20
order by Quantity desc, LineTotal desc;

-- Problem 5: We want to identify our larger orders.
-- For each order, calculate total units purchased and total order value.
-- Only include orders containing at least 5 units in total.
-- Add an OrderTier column based on total order value:
-- $300 or more: 'High'
-- $150 up to, but not including, $300: 'Medium'
-- Below $150: 'Low'
-- Include the order ID and put the highest-value orders first.

select orderid, sum(quantity) as QuantityTotal, sum(quantity * unitprice) as [Total Order Value],
	case
		when sum(quantity * unitprice) >= 300 then 'High'
		when sum(quantity * unitprice) >= 150 then 'Medium'
		else 'Low'
	end as OrderTier
from dbo.OrderItems
group by orderid
having sum(Quantity) >= 5
order by [Total Order Value] desc;

-- Problem 6: Which products are generating the most sales revenue?
-- For each product, include its ID, total units sold, and total revenue.
-- Only include products with at least 200 units sold across all
-- their order lines.
-- Add a RevenueTier column:
-- $10,000 or more: 'High'
-- $5,000 up to, but not including, $10,000: 'Medium'
-- Below $5,000: 'Low'
-- Put the highest-revenue products first.

select productid, sum(Quantity) as Quant, sum(quantity * unitprice) as Revenue,
	case
		when sum(quantity * unitprice) >= 10000 then 'High'
		when sum(quantity * unitprice) >= 5000 then 'Medium'
		else 'Low'
	end as RevenueTier
from dbo.orderitems
group by productid
having sum(quantity) >= 200
order by Revenue desc;

-- Problem 7: Marketing wants a customer activity list that includes
-- people who have never placed an order.
-- Include every customer's ID, name, and number of orders,
-- counting orders of any status.
-- Add an ActivityTier column:
-- 5 or more orders: 'Frequent'
-- 1–4 orders: 'Occasional'
-- No orders: 'Never Ordered'
-- Put customers with the fewest orders first, then names alphabetically.

select c.customerid, c.customername, count(distinct o.orderid) as OrderCount, 
	case
		when count(distinct o.orderid) >= 5 then 'Frequent'
		when count(distinct o.orderid) >= 1 then 'Occasional'
		else 'Never Ordered'
	end as ActivityTier
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
group by c.customerid, c.customername
order by OrderCount asc, c.customername asc;

-- Problem 8: We're planning a loyalty campaign for our in-store
-- customers in Green Bay and Chicago.
--
-- Using completed in-store orders only, find customers who have
-- placed at least 3 distinct orders and spent at least $800.
--
-- Include customer ID, name, city, number of orders, total units
-- purchased, total spending, and their earliest and latest
-- qualifying order dates.
--
-- Add a LoyaltyTier based on total spending:
-- $2,500 or more: 'Gold'
-- $1,200 up to, but not including, $2,500: 'Silver'
-- Below $1,200: 'Bronze'
--
-- Prioritize the biggest spenders, then those with the most orders,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(distinct o.orderid) as OrderCount, sum(oi.Quantity) as [Units Purchased], sum(oi.quantity * oi.unitprice) as [Total Spending], 
min(o.OrderDate) as Earliest,
max(o.OrderDate) as Latest,
	case
		when sum(oi.quantity * oi.unitprice) >= 2500 then 'Gold'
		when sum(oi.quantity * oi.unitprice) >= 1200 then 'Silver'
		else 'Bronze'
	end as LoyaltyTier
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
left join dbo.orderitems as oi
on o.orderid = oi.orderid
where o.SalesChannel = 'In Store'
and c.city in('Green Bay','Chicago')
and o.status = 'Completed'
group by c.customerid, c.customername, c.city
having count(distinct o.orderid) >= 3
and sum(oi.quantity * oi.unitprice) >= 800
order by [Total Spending] desc, OrderCount desc, c.CustomerName asc;

-- Problem 9: Which accessories are our strongest online sellers?
-- Focus on completed online orders.
--
-- Include product ID, name, total units sold, distinct order count,
-- and total sales revenue.
-- Only include products with at least 100 units sold across
-- at least 30 distinct orders.
--
-- Label products by revenue in a SalesTier column:
-- $10,000 or more: 'Strong'
-- $5,000 up to, but not including, $10,000: 'Steady'
-- Below $5,000: 'Developing'
--
-- Put the highest-revenue products first, then highest units sold,
-- then product name alphabetically.

select p.productid, p.productname, sum(oi.quantity) as [Units Sold], count(distinct o.orderid) as UniqueOrders, sum(oi.Quantity * oi.UnitPrice) as Revenue,
	case
		when sum(oi.Quantity * oi.UnitPrice) >= 10000 then 'Strong'
		when sum(oi.Quantity * oi.UnitPrice) >= 5000 then 'Steady'
		else 'Developing'
	end as SalesTier
from dbo.RetailProducts as p
inner join dbo.orderitems as oi
on p.productid = oi.productid
inner join dbo.orders as o
on o.orderid = oi.orderid
where p.category = 'accessories'
and o.status = 'Completed'
and o.saleschannel = 'Online'
group by p.productid, p.productname
having sum(oi.quantity) >= 100
and count(distinct o.orderid) >= 30
order by Revenue desc, [Units Sold] desc, p.productname asc;
--													   		Learning Aggregate CASE functions

-- Problem 10: Count how many orders have a status of 'Completed'.
-- Use SUM with CASE and name the result CompletedOrders.

select 
		sum(
			case
				when Status = 'Completed' then 1
				else 0
			end
			)
			as CompletedOrders
		from dbo.Orders;

-- Problem 11: Count cancelled orders using SUM with CASE.
-- Name the result CancelledOrders.
-- The status value is 'Cancelled'.

select sum(case when Status = 'Cancelled' then 1
else 0 end) as CancalledOrders
from dbo.orders

-- Problem 12: Return one row with two columns:
-- CompletedOrders and CancelledOrders.
-- Use SUM with CASE to count each status separately.

select
	sum(case when Status = 'Completed' then 1 else 0 end) as CompletedOrders,
	sum(case when Status = 'Cancelled' then 1 else 0 end) as CancelledOrders
from dbo.Orders;

-- Problem 13: Count online orders and in-store orders separately.
-- Return one row with columns OnlineOrders and InStoreOrders.
-- Include orders of every status.
-- SalesChannel values are 'Online' and 'In Store'.

select 
	sum(case when SalesChannel = 'Online' then 1 else 0 end) as OnlineOrders,
	sum(case when SalesChannel = 'In Store' then 1 else 0 end) as InStoreOrders
from dbo.orders;

-- Problem 14: We want to compare how each customer shops.
-- Include customer ID, online order count, and in-store order count.
-- Include orders of every status.
-- Return one row per customer who has orders.
-- Put customers with the most online orders first.

select customerid,

			sum(case when SalesChannel = 'Online' then 1 else 0 end) as OnlineOrders,
			sum(case when SalesChannel = 'In Store' then 1 else 0 end) as InStoreOrders
		from dbo.orders
group by customerid
order by OnlineOrders desc;

-- Problem 15: We want to review order outcomes for each customer.
-- Include customer ID, completed order count, and cancelled order count.
-- Return one row per customer who has orders, including all statuses
-- in the underlying data.
-- Put customers with the most cancelled orders first,
-- then the most completed orders.

select customerid,
		sum(case when Status = 'Completed' then 1 else 0 end) as CompletedOrders,
		sum(case when Status = 'Cancelled' then 1 else 0 end) as CancelledOrders
	from dbo.orders
group by customerid
order by CancelledOrders desc, CompletedOrders desc;