-- Customer service wants a follow-up list for Milwaukee and Green Bay.
-- They want one row per customer, including people who have never ordered.
--
-- The team needs the customer's ID, name, and city, along with their
-- total orders, completed orders, returned orders, and most recent order date.
--
-- For the follow-up label, use 'Priority' for 3 or more returns,
-- 'Monitor' for 1 or 2 returns, and 'No Follow-Up' for zero returns.
--
-- Focus on customers with fewer than 8 total orders.
-- Put customers with the most returns first. Break ties by completed
-- order count, highest first, then by customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, max(o.orderdate) as LatestOrder,

	sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
	sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOrders,

	case when sum(case when o.status = 'Returned' then 1 else 0 end) >= 3 then 'Priority'
	when sum(case when o.status = 'Returned' then 1 else 0 end) >= 1 then 'Monitor'
	else 'No Follow-Up'
	end as FollowUp

	from dbo.customers as c
	left join dbo.orders as o
	on c.customerid = o.customerid
where c.city in('Milwaukee','Green Bay')
group by c.customerid, c.customername, c.city
having count(o.orderid) < 8
order by ReturnedOrders desc, CompletedOrders desc, c.customername asc;

-- Merchandising wants to see which Clothing and Bags products
-- sell online and which ones sell in stores. Use completed orders only.
--
-- Return one row per product with its ID, name, category,
-- distinct order count, online units sold, in-store units sold,
-- total sales revenue, and most recent completed order date.
--
-- Label each product 'Online Lead' if it sold more units online,
-- 'In-Store Lead' if it sold more units in stores, or 'Even' if tied.
--
-- Include only products that appeared in at least 15 distinct
-- completed orders. Sort by revenue highest first, then by
-- distinct order count highest first, then by product name A–Z.

select p.productid, p.productname, p.category, count(distinct oi.orderid) as OrderCount, sum(oi.quantity * oi.unitprice) as Revenue, max(o.orderdate) as RecentOrder,

SUM(CASE WHEN o.SalesChannel = 'Online' THEN oi.Quantity ELSE 0 END) AS OnlineUnits,
SUM(CASE WHEN o.SalesChannel = 'In Store' THEN oi.Quantity ELSE 0 END) AS InStoreUnits,

		case when sum(case when o.saleschannel = 'Online' then oi.quantity else 0 end) > sum(case when o.saleschannel = 'In Store' then oi.Quantity else 0 end) then 'Online Lead'

		when sum(case when o.saleschannel = 'In Store' then oi.quantity else 0 end) > sum(case when o.saleschannel = 'Online' then oi.quantity else 0 end) then 'In Store Lead'
		else 'Even'
		end as ChannelLead
from dbo.RetailProducts as p
inner join dbo.orderitems as oi
on p.productid = oi.productid
inner join dbo.orders as o
on oi.orderid = o.orderid

where p.category in('Bags','Clothing')
and o.status = 'Completed'
group by p.productid, p.productname, p.category
having count(distinct oi.orderid) >= 15
order by Revenue desc, OrderCount desc, p.productname asc;

--																Learning UNIONS now

SELECT 'Madison' AS City
UNION 
SELECT 'Madison';

SELECT OrderID
FROM dbo.Orders
WHERE SalesChannel = 'Online'

union

select orderid
from dbo.orders
where status = 'Completed';

-- Practice Problem: Marketing Invitation List
--
-- Marketing wants to invite customers who live in Madison
-- or have placed at least one online order.
--
-- Return only CustomerID. Each customer should appear once,
-- even if they qualify both ways or placed multiple online orders.
--
-- Tables:
--   dbo.Customers (CustomerID, City)
--   dbo.Orders (CustomerID, SalesChannel)
--
-- Write two SELECT statements, each returning CustomerID.
-- Choose UNION or UNION ALL to combine the results.

select customerid
from dbo.customers
where city = 'Madison'

union

select customerid
from dbo.orders
where saleschannel = 'Online'

-- Practice Problem: Completed Orders by Channel
--
-- Sales wants one combined list of completed online and in-store orders.
-- Return only CustomerID and SalesChannel, in that order.
--
-- Keep one row per order. If a customer completed three online orders,
-- the result should show three rows for that customer and channel.
--
-- Table:
--   dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
--
-- Write one SELECT for completed 'Online' orders and another
-- for completed 'In Store' orders. Choose UNION or UNION ALL
-- to combine the two results.

select customerid, saleschannel
from dbo.orders
where status = 'Completed'
and saleschannel = 'Online'

union all

select customerid, saleschannel
from dbo.orders
where status = 'Completed'
and saleschannel = 'In Store'

-- Practice Problem: Customer Follow-Up List
--
-- Customer service wants a list of customers who had a cancelled
-- order or a returned order. They also want to know which sales
-- channel was involved.
--
-- Return CustomerID and SalesChannel, in that order.
-- Show each customer-and-channel combination once.
-- If a customer had two cancellations online and one return in store,
-- they should appear twice: once for Online and once for In Store.
--
-- Table:
--   dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
--
-- Write one SELECT for 'Cancelled' orders and another for 'Returned'
-- orders. Choose UNION or UNION ALL to combine the results.

select customerid, saleschannel
from dbo.orders
where status = 'Cancelled'

union

select customerid, saleschannel
from dbo.orders
where status = 'Returned'

-- Practice Problem: Customer Activity Feed
--
-- The sales team wants one timeline showing customer signups
-- and completed orders. Keep every event, even if a customer
-- placed two completed orders on the same day.
--
-- Return these columns in this order:
--   CustomerID, EventDate, EventType
--
-- For signups, use SignupDate and label the event 'Signup'.
-- For completed orders, use OrderDate and label it 'Completed Order'.
-- Sort the combined timeline from newest to oldest.
--
-- Tables:
--   dbo.Customers (CustomerID, SignupDate)
--   dbo.Orders (OrderID, CustomerID, OrderDate, Status)

select customerid, signupdate as EventDate, 'Signup' as EventType
from dbo.customers

union all

SELECT CustomerID, OrderDate, 'Completed Order'
from dbo.orders
where status = 'Completed'
order by EventDate desc;

-- Practice Problem: Customer Service Timeline
--
-- Customer service wants one timeline of cancellations and returns.
-- Both lists come from dbo.Orders. Keep one row per order.
--
-- Return these three columns in order:
--   CustomerID, EventDate, EventType
--
-- First SELECT: find 'Cancelled' orders. Use OrderDate as EventDate
-- and give each row the label 'Cancellation'.
--
-- Second SELECT: find 'Returned' orders. Use OrderDate again
-- and give each row the label 'Return'.
--
-- Stack the lists and sort the whole timeline from newest to oldest.
--
-- Table: dbo.Orders (OrderID, CustomerID, OrderDate, Status)

select customerid, orderdate as EventDate, 'Cancellation' as EventType
from dbo.orders
where status = 'Cancelled'

union all

select customerid, Orderdate, 'Return'
from dbo.orders
where status = 'Returned'

order by orderdate desc;

-- Practice Problem: Completed Sales Timeline
--
-- The sales team wants one timeline of completed online and in-store
-- orders. Keep one row per order, even if two orders look identical
-- in the columns below.
--
-- Return CustomerID, SaleDate, and ChannelLabel, in that order.
--
-- First SELECT: completed orders where SalesChannel = 'Online'.
-- Use OrderDate as SaleDate and label each row 'Web Sale'.
--
-- Second SELECT: completed orders where SalesChannel = 'In Store'.
-- Use OrderDate again and label each row 'Store Sale'.
--
-- Combine the two lists and sort the whole timeline newest first.
--
-- Table: dbo.Orders (OrderID, CustomerID, OrderDate, Status, SalesChannel)

select customerid, orderdate as SaleDate, 'Web Sale' as ChannelLabel
from dbo.orders
where saleschannel = 'Online'
and status = 'Completed'

union all

select customerid, orderdate, 'Store Sale'
from dbo.orders
where saleschannel = 'In Store'
and status = 'Completed'

order by Saledate desc;

-- Practice Problem: Order Follow-Up Timeline
--
-- Customer service wants one timeline of cancelled online orders
-- and returned in-store orders. Keep every qualifying order.
--
-- Return CustomerID, FollowUpDate, and Reason, in that order.
--
-- First SELECT: cancelled online orders.
-- Use OrderDate as FollowUpDate and label the Reason 'Online Cancellation'.
--
-- Second SELECT: returned in-store orders.
-- Use OrderDate again and label the Reason 'Store Return'.
--
-- Combine the lists and sort the timeline newest first.
--
-- Table:
-- dbo.Orders (OrderID, CustomerID, OrderDate, Status, SalesChannel)
--
-- Data values:
-- Status: 'Cancelled', 'Returned'
-- SalesChannel: 'Online', 'In Store'

select customerid, orderdate as FollowUpDate, 'Online Cancellation' as Reason
from dbo.orders 
where status = 'Cancelled'
and saleschannel = 'Online'

union all

select customerid, orderdate, 'Store Return' as Reason
from dbo.orders
where status = 'Returned'
and saleschannel = 'In Store'

order by FollowUpDate desc;