-- Customer Feedback List
--
-- Customer service wants to invite:
--   1. Everyone who lives in Milwaukee, even if they've never ordered.
--   2. Customers from any city who have at least 2 returned orders.
--
-- Return CustomerID, CustomerName, and City.
-- Show each customer once, even if they qualify both ways.
-- Sort by CustomerName, then CustomerID, both ascending.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (OrderID, CustomerID, Status)
-- Status value: 'Returned'

select customerid, customername, city
from dbo.customers
where city = 'Milwaukee'

union 

select o.customerid, c.customername, c.city
from dbo.orders as o
inner join dbo.customers as c
on o.customerid = c.customerid
where status = 'Returned'
group by o.customerid, c.customername, c.city
having count(*) >= 2

order by customername asc, customerid asc;

-- Practice: Customer Reach Across Sales Channels
--
-- Sales wants to know how many unique customers completed an order
-- online or in store. They also want to know how many distinct
-- customer-and-channel pairs those orders represent.
--
-- Step 1: Write two SELECTs that each return CustomerID and SalesChannel.
-- One should pull completed online orders. The other should pull
-- completed in-store orders. Combine them so each pair appears once.
--
-- A customer with five online orders and one in-store order should
-- appear twice in this result: once for Online and once for In Store.
--
-- Table: dbo.Orders (CustomerID, Status, SalesChannel)
-- Status: 'Completed'
-- SalesChannel: 'Online', 'In Store'

select 

count(*) as CustomerChannelPairs,
count(distinct customerid) as UniqueCustomers

from(


select customerid, saleschannel
from dbo.orders
where status = 'Completed'
and saleschannel = 'Online'

union

select customerid, saleschannel
from dbo.orders
where status = 'Completed'
and saleschannel = 'In Store')

	as CustomerChannels;

--															Starting CTEs !!!!!!!!!!!!! OMG

with ReturnedOrders as (
	select orderid
	from dbo.orders
	where status = 'Returned'
)
select count(*) as TotalReturned
from ReturnedOrders;

-- CTE Practice: Returns per Customer
--
-- Customer service wants to know how many orders each customer returned.
--
-- Step 1: Create a CTE named ReturnedOrders. Pull CustomerID
-- from dbo.Orders for rows where Status = 'Returned'.
--
-- Step 2: Query ReturnedOrders. Show CustomerID and the number
-- of returned orders for that customer. Name the count TotalReturned.
-- Sort by TotalReturned from highest to lowest.
--
-- Table: dbo.Orders (CustomerID, Status)

with ReturnedOrders as (

	select customerid
	from dbo.orders
	where status = 'Returned'
	)

select count(*) TotalReturned
from ReturnedOrders
group by customerid
order by TotalReturned desc;

-- CTE Practice: Repeat Customers
--
-- Step 1: Create a CTE named CompletedByCustomer.
-- Count completed orders per CustomerID and call the count TotalCompleted.
--
-- Step 2: Query CompletedByCustomer. Show CustomerID and TotalCompleted
-- for customers with at least 2 completed orders.
-- Sort by TotalCompleted from highest to lowest.
--
-- Table: dbo.Orders (CustomerID, Status)
-- Status value: 'Completed'

with CompletedByCustomer as (

	select customerid, count(*) as TotalCompleted
	from dbo.orders
	where status = 'Completed'
	group by customerid
	)

SELECT CustomerID, TotalCompleted
FROM CompletedByCustomer
WHERE TotalCompleted >= 2
ORDER BY TotalCompleted DESC;

-- CTE Practice: Customers With Multiple Returns
--
-- Find customers who returned at least two orders.
--
-- 1. Create a CTE named ReturnsByCustomer. Count orders with
--    Status = 'Returned' per CustomerID. Name the count TotalReturned.
--
-- 2. Query the CTE. Return CustomerID and TotalReturned for
--    customers who meet the cutoff.
--
-- Table: dbo.Orders (CustomerID, Status)

with ReturnsByCustomer as (

	select customerid, count(*) as TotalReturned
	from dbo.orders
	where status = 'Returned'
	group by customerid
	)

select customerid, TotalReturned
from ReturnsByCustomer
where TotalReturned >= 2

-- CTE Practice: Completed Orders by Customer
--
-- 1. Create a CTE named CompletedByCustomer. Count orders with
--    Status = 'Completed' per CustomerID. Name the count TotalCompleted.
--
-- 2. In the outer query, join CompletedByCustomer to dbo.Customers
--    on CustomerID.
--
-- 3. Return CustomerID, CustomerName, City, and TotalCompleted.
--    Keep customers with at least 2 completed orders.
--    Sort by TotalCompleted descending, then CustomerName ascending.
--
-- dbo.Orders (CustomerID, Status)
-- dbo.Customers (CustomerID, CustomerName, City)

with CompletedByCustomer as (

	select customerid, count(*) as TotalCompleted
	from dbo.orders
	where status = 'Completed'
	group by customerid)

SELECT cb.CustomerID, c.CustomerName, c.City, cb.TotalCompleted
FROM CompletedByCustomer AS cb
INNER JOIN dbo.Customers AS c
    ON cb.CustomerID = c.CustomerID
WHERE cb.TotalCompleted >= 2
ORDER BY cb.TotalCompleted DESC, c.CustomerName ASC;

-- CTE Practice: Most Recent Order by Customer
--
-- Customer service wants to see when each Milwaukee customer
-- last completed an order.
--
-- 1. Create a CTE named LastOrderByCustomer. Use dbo.Orders to find
--    the latest OrderDate for each CustomerID with a completed order.
--    Name that date LastCompletedOrder.
--
-- 2. In the outer query, join the CTE to dbo.Customers on CustomerID.
--    Keep only customers in Milwaukee.
--
-- 3. Return CustomerID, CustomerName, City, and LastCompletedOrder.
--    Sort newest order date first, then customer name A–Z.
--
-- dbo.Orders (CustomerID, OrderDate, Status)
-- dbo.Customers (CustomerID, CustomerName, City)
-- Values: 'Completed', 'Milwaukee'

with LastOrderByCustomer as (

select customerid, max(orderdate) as LastCompletedOrder
from dbo.orders
where status = 'Completed'
group by customerid
)

	select c.customerid, c.customername, c.city, lo.LastCompletedOrder
	from dbo.customers as c
	inner join LastOrderByCustomer as lo
	on lo.customerid = c.customerid
	where c.city = 'Milwaukee'
	order by LastCompletedOrder desc, c.customername asc;

-- CTE Practice: Completed Orders for All Milwaukee Customers
--
-- Customer service wants a list of every Milwaukee customer,
-- including those who have never placed a completed order.
--
-- 1. Create a CTE named CompletedByCustomer. Count completed
--    orders per CustomerID and name the count TotalCompleted.
--
-- 2. Join dbo.Customers to the CTE on CustomerID.
--    Keep every Milwaukee customer, even if they have no CTE match.
--
-- 3. Return CustomerID, CustomerName, and TotalCompleted.
--    Show 0 when a customer has no completed orders.
--    Sort by TotalCompleted descending, then CustomerName ascending.
--
-- dbo.Orders (CustomerID, Status)
-- dbo.Customers (CustomerID, CustomerName, City)
-- Values: 'Completed', 'Milwaukee'

with CompletedByCustomer as (

select customerid, count(*) as TotalCompleted
from dbo.orders
where status = 'Completed'
group by customerid
)

select c.customerid, c.customername, coalesce(cc.TotalCompleted,0) as TotalCompleted
from dbo.customers as c
left join CompletedByCustomer as cc
on cc.customerid = c.customerid
where c.city = 'Milwaukee'
order by TotalCompleted desc, c.customername asc;

-- CTE Practice: Returns for All Madison Customers
--
-- Customer service wants a report showing how many orders each
-- Madison customer has returned. Include customers with zero returns.
--
-- 1. Create a CTE named ReturnsByCustomer that counts orders with
--    Status = 'Returned' per CustomerID. Name the count TotalReturned.
--
-- 2. Join dbo.Customers to the CTE on CustomerID. Keep every Madison
--    customer, including those with no match in the CTE.
--
-- 3. Return CustomerID, CustomerName, and TotalReturned.
--    Use COALESCE to show 0 when the return count is NULL.
--
-- 4. Sort by TotalReturned descending, then CustomerName ascending.
--
-- dbo.Orders (CustomerID, Status)
-- dbo.Customers (CustomerID, CustomerName, City)

with ReturnsByCustomer as (
	
	select customerid, count(*) as TotalReturned
	from dbo.orders
	where status = 'Returned'
	group by customerid
	)

select c.customerid, c.customername, coalesce(rc.TotalReturned,0) as TotalReturned
from dbo.customers as c
left join ReturnsByCustomer as rc
on rc.customerid = c.customerid
where c.city = 'Madison'
order by TotalReturned desc, c.customername asc;

-- CTE Practice: Online Orders for All Milwaukee Customers
--
-- Show every Milwaukee customer, including those who have never
-- completed an online order.
--
-- 1. Create a CTE named OnlineOrdersByCustomer. For each CustomerID,
--    count completed online orders as TotalOnlineOrders and find
--    the most recent OrderDate as LastOnlineOrder.
--
-- 2. Join dbo.Customers to the CTE and keep every Milwaukee customer.
--
-- 3. Return CustomerID, CustomerName, TotalOnlineOrders, and LastOnlineOrder.
--    Show 0 for a missing count and leave the date NULL if there was no order.
--
-- 4. Sort by TotalOnlineOrders descending, then CustomerName ascending.
--
-- dbo.Orders (CustomerID, OrderDate, Status, SalesChannel)
-- dbo.Customers (CustomerID, CustomerName, City)
-- Values: 'Completed', 'Online', 'Milwaukee'

with OnlineOrdersByCustomer as (

	select customerid, count(*) as TotalOnlineOrders, max(orderdate) as LastOnlineOrder
	from dbo.orders
	where status = 'Completed'
	and saleschannel = 'Online'
	group by customerid
)

	select c.customerid, c.customername, coalesce(tl.TotalOnlineOrders,0) as TotalOnlineOrders
	from dbo.customers as c
	left join OnlineOrdersByCustomer as tl
	on tl.customerid = c.customerid
	where c.city = 'Milwaukee'
	order by TotalOnlineOrders desc, c.customername asc;

-- The Madison store manager is planning an outreach campaign and wants
-- a list of every Madison customer, including people who have never
-- completed an in-store purchase.
--
-- Show each customer's ID and name, how many completed in-store orders
-- they've placed, and the date of their most recent one. For customers
-- with no qualifying orders, show 0 for the count and NULL for the date.
--
-- Put customers with the most qualifying orders first. Break ties by
-- customer name A–Z.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (CustomerID, OrderDate, Status, SalesChannel)

WITH InStoreOrdersByCustomer AS (
    SELECT CustomerID,
           COUNT(*) AS TotalInStoreOrders,
           MAX(OrderDate) AS LastInStoreOrder
    FROM dbo.Orders
    WHERE Status = 'Completed'
      AND SalesChannel = 'In Store'
    GROUP BY CustomerID
)
SELECT c.CustomerID,
       c.CustomerName,
       COALESCE(ios.TotalInStoreOrders, 0) AS TotalInStoreOrders,
       ios.LastInStoreOrder
FROM dbo.Customers AS c
LEFT JOIN InStoreOrdersByCustomer AS ios
    ON ios.CustomerID = c.CustomerID
WHERE c.City = 'Madison'
ORDER BY TotalInStoreOrders DESC, c.CustomerName ASC;

-- The customer service team wants a report for every Green Bay
-- customer, including those who have never returned an online order.
--
-- Show each customer's ID and name, how many online orders they
-- returned, and the original order date of their most recent
-- returned online order.
--
-- Show 0 for the count and NULL for the date if they have no
-- qualifying orders. Sort by return count highest first, then
-- by customer name A–Z.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (CustomerID, OrderDate, Status, SalesChannel)
-- Use Status = 'Returned' and SalesChannel = 'Online'.

with ReturnedOnlineOrders as (

	select customerid, count(*) as ReturnedOrders, max(orderdate) as MostRecentReturnedOrder
	from dbo.orders
	where status = 'Returned'
	and saleschannel = 'Online'
group by customerid
)

	select c.customerid, c.customername, coalesce (ro.ReturnedOrders,0) as ReturnedOrders, ro.MostRecentReturnedOrder
	from dbo.customers as c
	left join ReturnedOnlineOrders as ro
	on c.customerid = ro.customerid
	where c.city = 'Green Bay'
	order by ReturnedOrders desc, c.customername asc;

-- The Milwaukee store manager wants to know how many in-store
-- orders each Milwaukee customer has cancelled.
--
-- Show CustomerID, CustomerName, and CancelledOrders.
-- Include every Milwaukee customer. Show 0 if they have never
-- cancelled an in-store order.
--
-- Sort by CancelledOrders highest first, then by customer name A–Z.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (CustomerID, Status, SalesChannel)
-- Use Status = 'Cancelled' and SalesChannel = 'In Store'.

with CancelledInStore as (

	select customerid, count(*) as CancelledOrders
	from dbo.orders
	where status = 'Cancelled'
	and saleschannel = 'In Store'
	group by customerid
)
	select c.customerid, c.customername, coalesce (cs.CancelledOrders,0) as CancelledOrders
	from dbo.customers as c
	left join CancelledInStore as cs
	on c.customerid = cs.customerid
	where c.city ='Milwaukee'
	order by CancelledOrders desc, c.customername asc;
