-- The Green Bay store manager wants a list of every Green Bay
-- customer and how many completed in-store orders they’ve placed.
-- Include customers with zero qualifying orders.
--
-- Return CustomerID, CustomerName, and CompletedOrders.
-- Sort by CompletedOrders highest first, then CustomerName A–Z.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (CustomerID, Status, SalesChannel)
-- Values: 'Green Bay', 'Completed', 'In Store'

with GBInStore as (

select customerid, count(*) as CompletedOrders
from dbo.orders
where status = 'Completed'
and saleschannel = 'In Store'
group by customerid
)

select c.customerid, c.customername, coalesce (gi.CompletedOrders,0) as CompletedOrders
from dbo.customers as c
left join GBInStore as gi
on c.customerid = gi.customerid
where c.city = 'Green Bay'
order by CompletedOrders desc, c.customername asc;

-- The Madison store manager wants to compare online and in-store
-- shopping for every Madison customer.
--
-- Show CustomerID, CustomerName, OnlineOrders, and InStoreOrders.
-- Count only completed orders. Show 0 for either channel when
-- the customer has no qualifying orders there.
--
-- Include customers with no completed orders at all.
-- Sort by OnlineOrders descending, then CustomerName ascending.
--
-- Use one CTE to calculate both counts per customer.
--
-- dbo.Customers (CustomerID, CustomerName, City)
-- dbo.Orders (CustomerID, Status, SalesChannel)
-- Values: 'Madison', 'Completed', 'Online', 'In Store'

with MadisonOrdering as (

select customerid, 

	sum(case when saleschannel = 'Online' then 1 else 0 end) as OnlineOrders,
	sum(case when saleschannel = 'In Store' then 1 else 0 end) as InStoreOrders
from dbo.orders
where status = 'Completed'
group by customerid
)

select c.customerid, c.customername, coalesce(mo.OnlineOrders,0) as OnlineOrders, coalesce(mo.InStoreOrders,0) as InStoreOrders
from dbo.customers as c
left join MadisonOrdering as mo
on c.customerid = mo.customerid
where c.city = 'Madison'
order by OnlineOrders desc, c.customername asc;

-- Merchandising wants to know which Accessories products
-- generated the most gross profit from completed online sales.
--
-- Use a CTE to calculate each product's units sold, revenue,
-- and gross profit. Use the actual sale price from OrderItems.
--
-- Revenue = Quantity × UnitPrice
-- Gross profit = Quantity × (UnitPrice − UnitCost), summed per product.
--
-- Return ProductName, UnitsSold, Revenue, GrossProfit, and ProfitTier.
-- Only include products that sold at least 20 units.
-- Label products with $500 or more in gross profit 'High Profit'
-- and the rest 'Standard'.
--
-- Sort by GrossProfit highest first, then ProductName A–Z.
--
-- dbo.RetailProducts (ProductID, ProductName, Category, UnitCost)
-- dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
-- dbo.Orders (OrderID, Status, SalesChannel)
-- Values: 'Accessories', 'Completed', 'Online'

WITH AccessoriesProfit AS (
    SELECT
        oi.ProductID,
        rp.ProductName,
        SUM(oi.Quantity) AS UnitsSold,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue,
        SUM(oi.Quantity * (oi.UnitPrice - rp.UnitCost)) AS [Gross Profit]
    FROM dbo.OrderItems AS oi
    INNER JOIN dbo.RetailProducts AS rp
        ON oi.ProductID = rp.ProductID
    INNER JOIN dbo.Orders AS o
        ON oi.OrderID = o.OrderID
    WHERE rp.Category = 'Accessories'
      AND o.Status = 'Completed'
      AND o.SalesChannel = 'Online'
    GROUP BY oi.ProductID, rp.ProductName
)
SELECT
    ProductName,
    UnitsSold,
    Revenue,
    [Gross Profit],
    CASE
        WHEN [Gross Profit] >= 500 THEN 'High Profit'
        ELSE 'Standard'
    END AS ProfitTier
FROM AccessoriesProfit
WHERE UnitsSold >= 20
ORDER BY [Gross Profit] DESC, ProductName ASC;

-- Customer service wants a list of completed online orders
-- worth at least $200 so they can review larger purchases.
--
-- Use a CTE to calculate one total per order.
-- OrderTotal is the sum of Quantity * UnitPrice across its items.
--
-- Return OrderID, CustomerID, OrderDate, and OrderTotal.
-- Sort by OrderTotal highest first, then OrderID ascending.
--
-- dbo.OrderItems (OrderID, Quantity, UnitPrice)
-- dbo.Orders (OrderID, CustomerID, OrderDate, Status, SalesChannel)
-- Values: 'Completed', 'Online'

with TotalPerOrder as (

    select orderid, sum(quantity * unitprice) as OrderTotal
    from dbo.orderitems
    group by orderid

    )

    select o.orderid, o.customerid, o.orderdate, tpo.OrderTotal
    from dbo.orders as o
    inner join TotalPerOrder as tpo
    on o.orderid = tpo.orderid
    where o.status = 'Completed'
    and o.saleschannel = 'Online'
    and tpo.OrderTotal >= 200
    order by OrderTotal desc, OrderID asc;

    -- The sales team wants to find completed orders with at least
-- 5 units across 3 or more distinct products.
--
-- Use a CTE to calculate TotalUnits and DistinctProducts per order.
-- If a product appears on two lines, count it once toward
-- DistinctProducts but include the units from both lines.
--
-- Return OrderID, CustomerID, SalesChannel, TotalUnits, and
-- DistinctProducts. Sort by DistinctProducts highest first,
-- then TotalUnits highest first, then OrderID ascending.
--
-- dbo.OrderItems (OrderID, ProductID, Quantity)
-- dbo.Orders (OrderID, CustomerID, SalesChannel, Status)
-- Status value: 'Completed'

;WITH SexyCTE AS (
    SELECT
        OrderID,
        SUM(Quantity) AS TotalUnits,
        COUNT(DISTINCT ProductID) AS DistinctProducts
    FROM dbo.OrderItems
    GROUP BY OrderID
)
SELECT
    o.OrderID,
    o.CustomerID,
    o.SalesChannel,
    cs.TotalUnits,
    cs.DistinctProducts
FROM dbo.Orders AS o
INNER JOIN SexyCTE AS cs
    ON o.OrderID = cs.OrderID
WHERE o.Status = 'Completed'
  AND cs.TotalUnits >= 5
  AND cs.DistinctProducts >= 3
ORDER BY cs.DistinctProducts DESC, cs.TotalUnits DESC, o.OrderID ASC;

-- Sales wants to find customers who spent at least $500
-- across completed online orders.
--
-- Use a CTE to calculate total spending per customer.
-- Each order item's value is Quantity * UnitPrice.
--
-- Return CustomerID, CustomerName, and TotalSpent.
-- Sort by TotalSpent highest first, then CustomerName A–Z.
--
-- dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- dbo.OrderItems (OrderID, Quantity, UnitPrice)
-- dbo.Customers (CustomerID, CustomerName)
-- Values: 'Completed', 'Online'

WITH OnlineCTE AS (
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSpent
    FROM dbo.Orders AS o
    INNER JOIN dbo.OrderItems AS oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
      AND o.SalesChannel = 'Online'
    GROUP BY o.CustomerID
)
SELECT
    c.CustomerID,
    c.CustomerName,
    oc.TotalSpent
FROM OnlineCTE AS oc
INNER JOIN dbo.Customers AS c
    ON oc.CustomerID = c.CustomerID
WHERE oc.TotalSpent >= 500
ORDER BY oc.TotalSpent DESC, c.CustomerName ASC;

-- Sales wants to know which cities generated at least $5,000
-- in revenue from completed in-store orders.
--
-- Use a CTE to calculate total revenue per city.
-- Each order item's revenue is Quantity * UnitPrice.
--
-- Return City and TotalRevenue. Sort by TotalRevenue descending,
-- then City ascending.
--
-- dbo.Customers (CustomerID, City)
-- dbo.Orders (OrderID, CustomerID, Status, SalesChannel)
-- dbo.OrderItems (OrderID, Quantity, UnitPrice)
-- Values: 'Completed', 'In Store'

;WITH RevenueCity AS (
    SELECT
        c.City,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
    FROM dbo.Orders AS o
    INNER JOIN dbo.OrderItems AS oi
        ON o.OrderID = oi.OrderID
    INNER JOIN dbo.Customers AS c
        ON o.CustomerID = c.CustomerID
    WHERE o.Status = 'Completed'
      AND o.SalesChannel = 'In Store'
    GROUP BY c.City
)
SELECT City, TotalRevenue
FROM RevenueCity
WHERE TotalRevenue >= 5000
ORDER BY TotalRevenue DESC, City ASC;

-- Merchandising wants to compare how much each product category
-- sold online versus in stores. Use completed orders only.
--
-- Use one CTE to calculate OnlineRevenue and InStoreRevenue
-- for each category. Revenue per line is Quantity * UnitPrice.
--
-- Return Category, OnlineRevenue, InStoreRevenue, and RevenueGap.
-- RevenueGap is OnlineRevenue minus InStoreRevenue.
-- Show only categories where online revenue was higher.
-- Sort by RevenueGap highest first, then Category A–Z.
--
-- dbo.RetailProducts (ProductID, Category)
-- dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
-- dbo.Orders (OrderID, Status, SalesChannel)
-- Values: 'Completed', 'Online', 'In Store'

with RevenueComparison as (

select rp.category, 

    sum(case when o.saleschannel = 'Online' then oi.quantity * oi.Unitprice else 0 end) as OnlineRevenue,
    sum(case when o.saleschannel = 'In Store' then oi.quantity * oi.unitprice else 0 end) as InStoreRevenue

from dbo.RetailProducts as rp
inner join dbo.orderitems as oi
on rp.productid = oi.productid
inner join dbo.orders as o
on o.orderid = oi.orderid
where o.status = 'Completed'
group by rp.Category
)

    select rc.category, OnlineRevenue, InStoreRevenue, OnlineRevenue - InStoreRevenue as RevenueGap
    from RevenueComparison as rc
    where OnlineRevenue > InStoreRevenue
    order by RevenueGap desc, rc.category asc;

-- Customer service wants to find customers whose most recent
-- completed order was worth at least $250.
--
-- Return CustomerID, CustomerName, OrderID, OrderDate, and OrderTotal.
-- Return at most one row per customer. If two completed orders have
-- the same OrderDate, treat the higher OrderID as the more recent one.
--
-- OrderTotal is the sum of Quantity * UnitPrice for that order.
-- Apply the $250 cutoff after identifying the most recent order.
-- If a customer's latest completed order was $100 and an older one
-- was $300, that customer should not appear.
--
-- Sort by OrderTotal descending, then CustomerID ascending.
--
-- dbo.Customers (CustomerID, CustomerName)
-- dbo.Orders (OrderID, CustomerID, OrderDate, Status)
-- dbo.OrderItems (OrderID, Quantity, UnitPrice)
-- Status value: 'Completed'

with CTEohYeah as (

        select o.customerid, oi.orderid, o.orderdate, sum(oi.quantity * oi.unitprice) as OrderTotal
        from dbo.orders as o
        inner join orderitems as oi
        on o.orderid = oi.orderid
        where o.status = 'Completed'
        group by o.customerid, oi.orderid, o.orderdate