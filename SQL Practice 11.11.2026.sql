-- Warm-up: Order Review Timeline
--
-- Build one timeline of completed in-store orders and returned
-- online orders. Keep every qualifying order, even when two rows
-- look identical in the output.
--
-- Return CustomerID, ReviewDate, and ReviewType.
-- Use OrderDate for ReviewDate.
-- Label completed in-store orders 'Store Purchase'.
-- Label returned online orders 'Online Return'.
-- Sort the combined timeline newest first.
--
-- dbo.Orders (CustomerID, OrderDate, Status, SalesChannel)
-- Status values: 'Completed', 'Returned'
-- SalesChannel values: 'In Store', 'Online'

select customerid, orderdate as ReviewDate, 'Store Purchase' as ReviewType
from dbo.orders
where status = 'Completed'
and saleschannel = 'In Store'

union all

select customerid, orderdate as ReviewDate, 'Online Return' as ReviewType
from dbo.orders
where status = 'Returned'
and saleschannel = 'Online'

order by ReviewDate desc;

-- Practice Problem: Signup and First Purchase Timeline
--
-- Marketing wants one timeline showing when customers signed up
-- and when they made their first completed purchase.
--
-- Return CustomerID, EventDate, and EventType, in that order.
--
-- First SELECT: Return each customer's SignupDate.
-- Label those rows 'Signup'.
--
-- Second SELECT: Return each customer's earliest OrderDate
-- among orders with Status = 'Completed'.
-- Label those rows 'First Purchase'.
--
-- Keep both events if they happened on the same date.
-- Sort the combined timeline newest first.
--
-- dbo.Customers (CustomerID, SignupDate)
-- dbo.Orders (CustomerID, OrderDate, Status)

select customerid, signupdate as EventDate, 'Signup' as EventType
from dbo.customers

union all

SELECT CustomerID, MIN(OrderDate) AS EventDate, 'First Purchase' AS EventType
FROM dbo.Orders
WHERE Status = 'Completed'
GROUP BY CustomerID

-- Practice Problem: First and Most Recent Purchase
--
-- Sales wants a timeline showing each customer's first and most
-- recent completed purchase. Use only orders with Status = 'Completed'.
--
-- Return CustomerID, EventDate, and EventType, in that order.
--
-- First SELECT: Return each customer's earliest completed OrderDate.
-- Label it 'First Purchase'.
--
-- Second SELECT: Return each customer's latest completed OrderDate.
-- Label it 'Most Recent Purchase'.
--
-- If a customer has only one completed order, show both events
-- with the same date. Sort the combined timeline newest first.
--
-- dbo.Orders (CustomerID, OrderDate, Status)

select customerid, min(orderdate) as EventDate, 'First Purchase' as EventType
from dbo.orders
where status = 'Completed'
group by customerid

union all

select customerid, max(orderdate) as EventDate, 'Most Recent Purchase' as EventType
from dbo.orders
where status = 'Completed'
group by customerid

order by EventDate desc;

-- Practice Problem: Completed Order Counts by Channel
--
-- Return CustomerID, CompletedOrders, and ChannelLabel.
--
-- First SELECT: Count completed online orders per customer.
-- Label those rows 'Online'.
--
-- Second SELECT: Count completed in-store orders per customer.
-- Label those rows 'In Store'.
--
-- Combine the summaries with UNION ALL. Sort the entire result
-- by CompletedOrders descending, then CustomerID ascending.
--
-- dbo.Orders (CustomerID, Status, SalesChannel)
-- Status: 'Completed'
-- SalesChannel: 'Online', 'In Store'

select customerid, count(customerid) as CompletedOrders, 'Online' as ChannelLabel
from dbo.orders
where status = 'Completed'
and saleschannel = 'Online'
group by customerid

union all

select customerid, count(customerid) as CompletedOrders, 'In Store' as ChannelLabel
from dbo.orders
where status = 'Completed'
and saleschannel = 'In Store'
group by customerid

order by CompletedOrders desc, CustomerID asc;

-- Practice Problem: Customer Review List
--
-- Include customers who meet either condition:
--   1. At least 3 completed online orders.
--   2. At least 2 returned in-store orders.
--
-- Return only CustomerID. If a customer qualifies both ways,
-- show them once. Sort by CustomerID ascending.
--
-- dbo.Orders (CustomerID, Status, SalesChannel)
-- Status values: 'Completed', 'Returned'
-- SalesChannel values: 'Online', 'In Store'

SELECT CustomerID
FROM dbo.Orders
WHERE SalesChannel = 'Online'
  AND Status = 'Completed'
GROUP BY CustomerID
HAVING COUNT(*) >= 3

union

select customerid

	from dbo.orders
	where saleschannel = 'In Store'
	and status = 'Returned'
	group by customerid 
	having count(*) >= 2

order by customerid asc;

-- Practice 1: Customer Outreach List
--
-- The customer experience team wants to invite two groups to a survey:
--   1. Customers with at least 4 completed in-store orders.
--   2. Customers with at least 2 cancelled online orders.
--
-- Return only CustomerID. Send one invitation per customer,
-- even if they qualify for both groups.
-- Sort by CustomerID ascending.
--
-- Table: dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- Status values: 'Completed', 'Cancelled'
-- SalesChannel values: 'In Store', 'Online'

select customerid
from dbo.orders
where status = 'Completed'
and saleschannel = 'In Store'
group by customerid
having count(*) >= 4

union 

select customerid
from dbo.orders
where status = 'Cancelled'
and saleschannel = 'Online'
group by customerid
having count(*) >= 2

order by customerid asc;

-- Practice 2: Customer Service Review
--
-- Customer service wants a report for two groups:
--   1. Customers with at least 3 completed online orders.
--   2. Customers with at least 2 cancelled in-store orders.
--
-- Return CustomerID, OrderCount, and ReviewGroup.
-- Label the first group 'Online Purchases' and the second
-- group 'Store Cancellations'.
--
-- If a customer qualifies for both groups, show both rows.
-- Sort by OrderCount descending, then CustomerID ascending.
--
-- Table: dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- Status values: 'Completed', 'Cancelled'
-- SalesChannel values: 'Online', 'In Store'

select customerid, count(*) as OrderCount, 'Online Purchases' as ReviewGroup
from dbo.orders
where status = 'Completed'
and saleschannel = 'Online'
group by customerid
having count(*) >= 3

union all

select customerid, count(*) as OrderCount, 'Store Cancellations' as ReviewGroup
from dbo.orders
where status = 'Cancelled'
and saleschannel = 'In Store'
group by customerid
having count(*) >= 2

order by OrderCount desc, customerid asc;

-- Practice 3: Customer Appreciation List
--
-- Marketing wants to invite every customer who lives in Madison,
-- plus customers from any city with at least 3 completed online orders.
-- Madison customers qualify even if they have never placed an order.
--
-- Return CustomerID, CustomerName, and City. Show each customer
-- only once, even if they qualify both ways.
-- Sort by CustomerName ascending, then CustomerID ascending.
--
-- Tables:
--   dbo.Customers (CustomerID, CustomerName, City)
--   dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
--
-- Data values: 'Madison', 'Completed', 'Online'

select customerid, customername, city
from dbo.customers
where city = 'Madison'

union 

select o.customerid, c.customername, c.city
from dbo.orders as o
inner join dbo.customers as c
on c.customerid = o.customerid
where o.saleschannel = 'Online'
and o.status = 'Completed'
group by o.customerid, c.customername, c.city
having count(*) >= 3 

order by customername asc, customerid asc;