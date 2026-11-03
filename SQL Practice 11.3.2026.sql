-- Problem 1: We'd like to identify repeat online customers in Madison
-- and Green Bay. Find those with at least 3 completed online orders.
-- Include their ID, name, city, order count, and earliest and latest
-- qualifying order dates.
-- Put the most recent customers first, then highest order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city,
       count(o.orderid) as OrderCount,
       min(o.orderdate) as Earliest,
       max(o.orderdate) as Latest
from dbo.customers as c
inner join dbo.orders as o
    on c.customerid = o.customerid
where o.SalesChannel = 'Online'
and c.city in ('Madison', 'Green Bay')
and o.status = 'Completed'
group by c.customerid, c.customername, c.city
having count(o.orderid) >= 3
order by Latest desc, OrderCount desc, c.customername asc;


-- Problem 2: We want to identify our highest-spending customers.
-- For completed orders only, calculate each customer's total spending
-- and number of distinct orders.
-- Include customer ID and name, and put the highest spenders first.

select c.customerid, c.customername,
       count(distinct o.orderid) as UniqueOrders,
       sum(oi.Quantity * oi.UnitPrice) as Revenue
from dbo.customers as c
inner join dbo.orders as o
    on c.customerid = o.customerid
inner join dbo.OrderItems as oi
    on o.orderid = oi.orderid
where o.status = 'Completed'
group by c.customerid, c.customername
order by Revenue desc;

-- Problem 3: We're planning a loyalty campaign in Madison and Milwaukee.
-- Find customers who have placed at least 3 completed online orders
-- and spent at least $1,000 across those orders.
-- I'd like their ID, name, city, order count, total spending,
-- and most recent qualifying order date.
-- Prioritize the biggest spenders, then those who ordered most recently.

select c.customerid, c.customername, c.city, count(distinct o.orderid) as OrderCount, sum(oi.Quantity * oi.UnitPrice) as Revenue, max(o.orderdate) as Latest
from dbo.Customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
inner join dbo.orderitems as oi
on o.orderid = oi.orderid
where c.city in('Madison', 'Milwaukee')
and o.status = 'Completed'
and o.SalesChannel = 'Online'
group by c.customerid, c.customername, c.city
having count(distinct o.orderid) >= 3
and sum(oi.Quantity * oi.UnitPrice) >= 1000
order by Revenue desc, max(o.orderdate) desc;

-- Problem 4: We're reviewing which clothing products perform best online.
-- Using completed online orders, find products that have sold at least
-- 100 units across at least 20 distinct orders.
-- Include product ID, name, total units sold, order count, and revenue.
-- Put the highest-revenue products first, then the highest unit sales.

select p.productid, p.productname, sum(oi.Quantity) as UnitsSold, count(distinct o.orderid) as OrderCount, sum(oi.Quantity * oi.UnitPrice) as Revenue
from dbo.RetailProducts as p
inner join dbo.OrderItems as oi
on p.productid = oi.productid
inner join dbo.orders as o
on o.orderid = oi.orderid
where o.SalesChannel = 'Online'
and p.category = 'Clothing'
and o.status = 'Completed'
group by p.productid, p.productname
having count(distinct o.orderid) >= 20
and sum(oi.Quantity) >= 100
order by Revenue desc, UnitsSold desc;

--                                                                    CASE function practice

-- Problem 5: List each product's name and list price.
-- Add a PriceTier column that labels products priced at $40 or more
-- as 'Higher Price' and everything else as 'Lower Price'.

select productname, listprice,
case
    when ListPrice >= 40 then 'Higher Price'
    else 'Lower Price'
end as PriceTier
from dbo.RetailProducts

-- Problem 6: We'd like to flag products for a pricing review.
-- List each product's name and unit cost.
-- Add a CostTier column: a unit cost of $25 or more should be
-- labeled 'High Cost'; everything else should be 'Low Cost'.
-- Put the highest unit costs first.

select productname, unitcost,
    case
        when UnitCost >= 25 then 'High Cost'
        else 'Low Cost'
    end as CostTier
from dbo.RetailProducts
order by UnitCost desc;

-- Problem 7: We need price tiers for our clothing catalog.
-- Include each clothing product's name and list price.
-- Add a PriceTier column with these labels:
-- $60 or more: 'Premium'
-- $30 up to, but not including, $60: 'Midrange'
-- Below $30: 'Budget'
-- Put the most expensive products first.

select productname, listprice,
case
        when ListPrice >= 60 then 'Premium'
    when ListPrice >= 30 then 'Midrange'
    else 'Budget'
end as PriceTier
from dbo.RetailProducts
where category = 'Clothing'
order by ListPrice desc;

-- Problem 8: We're reviewing the costs of our accessories.
-- List each accessory's name and unit cost.
-- Add a CostTier column:
-- $30 or more: 'High'
-- $15 up to, but not including, $30: 'Medium'
-- Below $15: 'Low'
-- Put the highest unit costs first.

select productname, unitcost,
    case
        when UnitCost >= 30 then 'High'
        when UnitCost >= 15 then 'Medium'
    else 'Low'
end as CostTier
from dbo.RetailProducts
where category = 'Accessories'
order by UnitCost desc;

-- Problem 9: We're reviewing potential profit per unit for our clothing.
-- Include product name, list price, unit cost, and the difference
-- between list price and unit cost as PotentialProfit.
-- Add a ProfitTier column:
-- $30 or more: 'High'
-- $15 up to, but not including, $30: 'Medium'
-- Below $15: 'Low'
-- Put the highest potential profit first.

select productname, listprice, unitcost, listprice - unitcost as PotentialProfit,
case
        when listprice - unitcost >= 30 then 'High'
        when listprice - unitcost >= 15 then 'Medium'
        else 'Low'
    end as ProfitTier
from dbo.RetailProducts
where category = 'Clothing'
order by PotentialProfit desc;

-- Problem 10: We're planning a loyalty campaign for online customers
-- in Madison and Milwaukee.
-- Using completed online orders only, find customers with at least
-- 3 distinct orders and at least $1,000 in total spending.
-- Include customer ID, name, city, distinct order count, total units
-- purchased, total spending, and most recent qualifying order date.
-- Add a CustomerTier column based on that spending:
-- $3,000 or more: 'Gold'
-- $1,500 up to, but not including, $3,000: 'Silver'
-- Below $1,500: 'Bronze'
-- Put the biggest spenders first, then those with the most orders,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(distinct o.orderid) as OrderCount,
            sum(oi.Quantity) as UnitsPurchased, sum(oi.Quantity * oi.UnitPrice) as [Total Spending], max(o.orderdate) as LastOrder,
        case
                when sum(oi.Quantity * oi.UnitPrice) >= 3000 then 'Gold'
                when sum(oi.Quantity * oi.UnitPrice) >= 1500 then 'Silver'
                else 'Bronze'
        end as CustomerTier
from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
inner join dbo.orderitems as oi
on o.orderid = oi.orderid
where o.SalesChannel = 'Online'
and c.city in('Madison','Milwaukee')
and o.status = 'Completed'
group by c.customerid, c.customername, c.city
having count(distinct o.orderid) >= 3
and sum(oi.Quantity * oi.UnitPrice) >= 1000
order by [Total Spending] desc, OrderCount desc, c.customername asc;

