-- The Milwaukee store manager wants to find customers who placed
-- at least 3 completed in-store orders and spent at least $300
-- across those orders.
--
-- Use a CTE to calculate order count and total spending per customer.
-- Each order item's value is Quantity * UnitPrice.
--
-- Return CustomerID, CustomerName, OrderCount, and TotalSpent.
-- Sort by TotalSpent highest first, then CustomerName A–Z.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- dbo.OrderItems (OrderID, Quantity, UnitPrice)
-- Values: 'Milwaukee', 'Completed', 'In Store'

with MilwaukeeManager as (

	select c.customerid, c.customername, count(distinct o.orderid) as OrderCount, sum(oi.quantity * oi.unitprice) as TotalSpending
	from dbo.customers as c
	inner join dbo.Orders as o
	on c.customerid = o.customerid
	inner join dbo.orderitems as oi
	on o.orderid = oi.orderid
	where o.saleschannel = 'In Store'
	and o.status = 'Completed'
	and c.city = 'Milwaukee'
	group by c.customerid, c.customername
	)

	select customerid, customername, OrderCount, TotalSpending
	from MilwaukeeManager
	where OrderCount >= 3
	and TotalSpending >= 300
	order by TotalSpending desc, customername asc;

-- Practice: Milwaukee Customer Outreach
--
-- The Milwaukee store manager wants a report of every customer who
-- has placed at least one completed in-store order. The manager wants
-- to see who qualifies for a thank-you offer and who is still building
-- toward it.
--
-- Return CustomerID, CustomerName, OrderCount, TotalSpending,
-- and OfferStatus. An order's value is SUM(Quantity * UnitPrice)
-- across its items. Count each order only once.
--
-- Show 'Eligible' for customers with at least 3 qualifying orders
-- AND at least $300 in qualifying spending. Show 'Not Yet' otherwise.
-- Keep both groups in the report.
--
-- Sort by TotalSpending descending, then CustomerName ascending.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- dbo.OrderItems (OrderID, Quantity, UnitPrice)
-- Values: 'Milwaukee', 'Completed', 'In Store'

with MilCusOutreach as (

		select c.customerid, c.customername, count(distinct o.orderid) as OrderCount, sum(oi.quantity * oi.unitprice) as TotalSpending
from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
inner join dbo.orderitems as oi
on o.orderid = oi.orderid
where c.city = 'Milwaukee'
and o.status = 'Completed'
and o.saleschannel = 'In Store'
group by c.customerid, c.customername
)
SELECT CustomerID,
       CustomerName,
       OrderCount,
       TotalSpending,
       CASE
           WHEN OrderCount >= 3 AND TotalSpending >= 300 THEN 'Eligible'
           ELSE 'Not Yet'
       END AS OfferStatus
FROM MilCusOutreach
ORDER BY TotalSpending DESC, CustomerName ASC;

-- Practice: Madison Customer Follow-Up
--
-- Customer service wants a report of Madison customers who placed
-- at least one online order, regardless of the order's status.
--
-- Use a CTE to calculate OnlineOrders and ReturnedOnlineOrders
-- per customer. Return CustomerID, CustomerName, both counts,
-- and a FollowUp label.
--
-- Label a customer 'Priority Review' if they placed at least
-- 5 online orders AND returned at least 2 of those orders.
-- Label everyone else 'Standard'. Keep both groups in the report.
--
-- Sort by ReturnedOnlineOrders highest first, then CustomerName A–Z.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- Values: 'Madison', 'Online', 'Returned'

with OrderCalc as (

	select c.customerid, c.customername, count(distinct o.orderid) as OnlineOrders,

	sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOnlineOrders

from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
where o.saleschannel = 'Online'
and c.city = 'Madison'
group by c.customerid, c.customername
)

	select customerid, customername, OnlineOrders, ReturnedOnlineOrders,

	case when OnlineOrders >= 5 and ReturnedOnlineOrders >= 2 then 'Priority Review'
	else 'Standard'
	end as FollowUp
from OrderCalc
order by ReturnedOnlineOrders desc, CustomerName asc;

-- Customer service wants a report of Green Bay customers who
-- have placed at least one in-store order, regardless of status.
--
-- Use a CTE to count all in-store orders and cancelled in-store
-- orders per customer. Name the counts StoreOrders and CancelledOrders.
--
-- Return CustomerID, CustomerName, both counts, and ReviewStatus.
-- Label customers 'Review' if they have at least 4 in-store orders
-- AND at least 2 cancellations. Label everyone else 'Standard'.
-- Keep both groups in the report.
--
-- Sort by CancelledOrders highest first, then CustomerName A–Z.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- Values: 'Green Bay', 'In Store', 'Cancelled'

with OrderCounterCTE as (

	select c.customerid, c.customername, count(distinct o.orderid) as StoreOrders, 

	sum(case when o.status = 'Cancelled' then 1 else 0 end) as CancelledOrders

from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid 
where c.city = 'Green Bay'
and o.saleschannel = 'In Store'
group by c.customerid, c.customername
)
	select customerid, customername, StoreOrders, CancelledOrders, 

	case when StoreOrders >= 4 and CancelledOrders >= 2 then 'Review'
	else 'Standard'
	end as ReviewStatus
from OrderCounterCTE
order by CancelledOrders desc, customername asc;

-- The sales team wants to find customers who placed at least
-- two completed online orders worth $200 or more each.
--
-- 1. Write a CTE named OrderTotals. Return one row per completed
--    online order with OrderID, CustomerID, and OrderTotal.
--    OrderTotal is SUM(Quantity * UnitPrice).
--
-- 2. Write a second CTE named LargeOrdersByCustomer that reads
--    from OrderTotals. Keep orders worth at least $200, then
--    count those orders and sum their totals per customer.
--
-- 3. Join the second CTE to Customers. Show CustomerID,
--    CustomerName, LargeOrderCount, and LargeOrderSpending.
--    Keep customers with at least two qualifying orders.
--    Sort by LargeOrderSpending highest first, then CustomerName A–Z.
--
-- dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- dbo.OrderItems (OrderID, Quantity, UnitPrice)
-- dbo.Customers (CustomerID, CustomerName)
-- Values: 'Completed', 'Online'

with OrderTotals as (

	select o.orderid, o.customerid, sum(oi.quantity * oi.unitprice) as OrderTotal
	from dbo.orders as o
	inner join OrderItems as oi
	on o.orderid = oi.orderid
	where o.status = 'Completed'
	and o.saleschannel = 'Online'
	group by o.orderid, o.customerid
	),

LargeOrdersByCustomer AS (
    SELECT CustomerID,
           COUNT(*) AS LargeOrderCount,
           SUM(OrderTotal) AS LargeOrderSpending
    FROM OrderTotals
    WHERE OrderTotal >= 200
    GROUP BY CustomerID
)

	SELECT
    c.CustomerID,
    c.CustomerName,
    l.LargeOrderCount,
    l.LargeOrderSpending
FROM LargeOrdersByCustomer AS l
INNER JOIN dbo.Customers AS c
    ON l.CustomerID = c.CustomerID
WHERE l.LargeOrderCount >= 2
ORDER BY l.LargeOrderSpending DESC, c.CustomerName ASC;