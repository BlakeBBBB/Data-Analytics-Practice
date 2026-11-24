-- DAY 1: GROUPING AND SINGLE-CTE REVIEW
--
-- TABLE REFERENCE
--
-- dbo.Orders
-- OrderID, CustomerID, OrderDate, Status, SalesChannel
--
-- dbo.OrderItems
-- OrderItemID, OrderID, ProductID, Quantity, UnitPrice
--
-- RELATIONSHIP
-- Orders.OrderID = OrderItems.OrderID


-- BUSINESS QUESTION
--
-- The online sales manager wants to review larger baskets
-- from completed online orders.
--
-- Return one row per order showing:
-- Order ID, customer ID, order date, number of different
-- products, total units purchased, and total order value.
--
-- Label each order:
-- 'High Value' for an order value of at least $400,
-- 'Mid Value' for at least $200,
-- 'Standard' otherwise.
--
-- Include only orders containing at least 3 different
-- products and at least 6 total units.
--
-- Sort by total order value highest first,
-- then order ID lowest first.
--
-- Use one CTE to calculate the order totals.
-- Finish the filtering and labeling in the outer query.

with FirstCTE as (

select o.orderid, o.customerid, o.orderdate, count(distinct oi.productid) as DifferentProducts, sum(oi.quantity) as TotalUnits, sum(oi.quantity * oi.unitprice) as OrderValue
from dbo.orders as o
inner join dbo.orderitems as oi
on o.orderid = oi.orderid
where o.status = 'Completed'
and o.saleschannel = 'Online'
group by o.orderid, o.customerid, o.orderdate
)

select orderid, customerid, orderdate, DifferentProducts, TotalUnits, OrderValue, 

	case when OrderValue >= 400 then 'High Value'
	when OrderValue >= 200 then 'Mid Value'
	else 'Standard'
	end as BasketValue

from FirstCTE

where DifferentProducts >= 3
and TotalUnits >= 6
order by OrderValue desc, orderid asc;

-- DAY 1: CUSTOMER SUMMARY REVIEW
--
-- TABLE REFERENCE
--
-- dbo.Customers
-- CustomerID, CustomerName, City
--
-- dbo.Orders
-- OrderID, CustomerID, OrderDate, Status, SalesChannel
--
-- RELATIONSHIP
-- Customers.CustomerID = Orders.CustomerID


-- BUSINESS QUESTION
--
-- Customer service wants a report covering every customer
-- in Madison and Milwaukee, including those with no orders.
--
-- Show customer ID, name, city, total number of orders,
-- completed order count, returned order count,
-- and most recent order date.
--
-- Count orders across all statuses and both sales channels.
--
-- Label each customer:
-- 'Priority Review' if they have at least 5 total orders
-- AND at least 2 returned orders.
-- 'Standard' otherwise.
--
-- Include customers with no orders and display their
-- counts as zero. Leave their most recent order date NULL.
--
-- Sort by returned order count highest first,
-- then total order count highest first,
-- then customer name A–Z.
--
-- Use one CTE to prepare the customer summary.
-- Apply the review label in the outer query.

with SecondCTE as (

select c.customerid, c.customername, c.city, count(orderid) as OrderCount, 

sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOrders,

max(o.orderdate) as MostRecentOrder

from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Milwaukee')
group by c.customerid, c.customername, c.city
)

select customerid, customername, city, OrderCount, CompletedOrders, ReturnedOrders, MostRecentOrder,

case when OrderCount >= 5 and ReturnedOrders >= 2 then 'Priority Review'
else 'Standard'
end as ReviewCase


from SecondCTE


order by ReturnedOrders desc, OrderCount desc, customername asc;

-- TABLE REFERENCE
--
-- dbo.Customers
-- CustomerID, CustomerName, City
--
-- dbo.Orders
-- OrderID, CustomerID, OrderDate, Status, SalesChannel
--
-- BUSINESS QUESTION
--
-- The Green Bay manager wants to review completed in-store
-- purchasing activity for EVERY customer in Green Bay,
-- including customers with no qualifying purchases.
--
-- Show customer ID, customer name, number of completed
-- in-store orders, and latest completed in-store order date.
--
-- Display zero when a customer has no qualifying orders.
-- Leave their latest qualifying order date NULL.
--
-- Label each customer:
-- 'Regular' for at least 4 qualifying orders,
-- 'Occasional' for 1–3 qualifying orders,
-- 'No Purchases' for zero qualifying orders.
--
-- Sort by qualifying order count highest first,
-- then customer name A–Z.
--
-- Use one CTE to summarize qualifying orders by customer.
-- In the outer query, connect that summary to Customers.
--
-- Remember: COALESCE(value, 0) replaces a NULL with zero.

with ThirdCTE as (

select c.customerid, c.customername, count(o.orderid) as OrderCount, max(o.orderdate) as RecentOrder
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid 
where c.city = 'Green Bay'
and o.status = 'Completed'
and o.saleschannel = 'In Store'
group by c.customerid, c.customername
)
select customerid, customername, OrderCount, RecentOrder,

case when OrderCount >= 4 then 'Regular'
when OrderCount >= 1 then 'Occasional'
else 'No PUrchases'
end as Frequency

from ThirdCTE
order by OrderCount desc, customername asc;

-- TABLE REFERENCE
--
-- dbo.Customers
-- CustomerID, CustomerName, City
--
-- dbo.Orders
-- OrderID, CustomerID, OrderDate, Status, SalesChannel
--
-- BUSINESS QUESTION
--
-- The Madison manager wants a list of EVERY Madison customer
-- and how many returned orders each customer has.
--
-- Show customer ID, customer name, and returned order count.
--
-- Customers with no returned orders must still appear,
-- with a count of zero.
--
-- Sort by returned order count highest first,
-- then customer name A–Z.

select c.customerid, c.customername, count(o.orderid) as OrderCount

	

from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
and o.status = 'Returned'
where c.city = 'Madison'
group by c.customerid, c.customername
order by OrderCount desc, c.customername asc;

-- dbo.Customers
-- CustomerID, CustomerName, City
--
-- dbo.Orders
-- OrderID, CustomerID, OrderDate, Status, SalesChannel
--
-- BUSINESS QUESTION
--
-- The Milwaukee manager wants to review completed online
-- purchases for EVERY customer in Milwaukee.
--
-- Show customer ID, customer name, qualifying order count,
-- and the most recent qualifying order date.
--
-- Customers with no completed online orders must still
-- appear with an order count of zero and a NULL date.
--
-- Sort by qualifying order count highest first,
-- then customer name A–Z.

select c.customerid, c.customername, count(o.orderid) as OrderCount, max(o.orderdate) as RecentOrder

from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
and o.status = 'Completed'
and o.saleschannel = 'Online'
where c.city = 'Milwaukee'
group by c.customerid, c.customername
order by OrderCount desc, c.customername asc;