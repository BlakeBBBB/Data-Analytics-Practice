-- The Milwaukee manager wants to identify regular online customers.
-- Using completed online orders, return each customer's ID, name,
-- order count, and most recent order date.
-- Include only customers with at least 3 qualifying orders.
-- Label those with 6 or more 'Regular'; otherwise, 'Occasional'.
-- Sort by highest order count, then customer name alphabetically.
-- Use a CTE to organize your answer.

with RegOnlineCTE as (
	
		select c.customerid, c.customername, count(o.orderid) as OrderCount, max(o.orderdate) as RecentOrder
	from dbo.customers as c
	inner join dbo.orders as o
	on c.customerid = o.customerid
	where c.city = 'Milwaukee'
	and o.saleschannel = 'Online'
	and o.status = 'Completed'
	group by c.customerid, c.customername
	)

	select customerid, customername, OrderCount, RecentOrder,

	case when OrderCount >= 6 then 'Regular'
	else 'Occasional'
	end as CountofOrders
from RegOnlineCTE
where OrderCount >= 3
order by OrderCount desc, CustomerName asc;

-- The Madison manager is planning a customer rewards campaign.
-- For completed in-store purchases, identify customers with at least
-- 3 orders and total spending of $500 or more.
-- Include customer ID, name, order count, total spending,
-- and most recent qualifying order date.
-- Label customers spending $1,500 or more 'Gold',
-- $800 or more 'Silver', and everyone else 'Bronze'.
-- Sort by highest spending, then customer name alphabetically.
-- Use a CTE.

with RewardCampaign as (

select c.customerid, c.customername, count(distinct o.orderid) as OrderCount, sum(oi.quantity * oi.unitprice) as TotalSpending, max(o.orderdate) as RecentOrder
from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
inner join dbo.OrderItems as oi
on o.orderid = oi.orderid
where c.city = 'Madison'
and o.status = 'Completed'
and o.saleschannel = 'In Store'
group by c.customerid, c.customername
)

select customerid, customername, OrderCount, TotalSpending, RecentOrder,

case when TotalSpending >= 1500 then 'Gold'
when TotalSpending >= 800 then 'Silver'
else 'Bronze'
end as CustomerTier

from RewardCampaign
where OrderCount >= 3
and TotalSpending >= 500
order by TotalSpending desc, customername asc;

-- The Green Bay manager wants to recognize loyal online shoppers.
-- Consider completed online orders only.
-- Find customers with at least 4 orders and $700 in total spending.
-- Include their ID, name, order count, total units purchased,
-- total spending, and most recent qualifying order date.
-- Label customers 'VIP' if they have at least 6 orders
-- AND have spent at least $1,500; otherwise, label them 'Standard'.
-- Sort by total spending highest first, then customer name A–Z.
-- Use a CTE.

with GBOnline as (

select c.customerid, c.customername, count(distinct o.orderid) as OrderCount, sum(oi.quantity) as UnitsPurchased, 
sum(oi.quantity * oi.unitprice) as TotalSpending, max(o.orderdate) as RecentOrder
from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
inner join dbo.orderitems as oi
on o.orderid = oi.orderid
where c.city = 'Green Bay'
and o.saleschannel = 'Online'
and o.status = 'Completed'
group by c.customerid, c.customername
)

select customerid, customername, OrderCount, UnitsPurchased, TotalSpending, RecentOrder,

case when OrderCount >= 6 and TotalSpending >= 1500 then 'VIP'
else 'Standard'
end as CustomerLabel

from GBOnline
where OrderCount >= 4
and TotalSpending >= 700
order by TotalSpending desc, customername asc;

-- The sales manager wants customers who placed at least two
-- completed online orders worth $200 or more each.
-- Return customer ID and the number of qualifying orders.
-- Sort by qualifying order count highest first, then customer ID.
-- Use two CTEs.

with OrderTotals as (
    select o.customerid,
           o.orderid,
           sum(oi.quantity * oi.unitprice) as OrderTotal
    from dbo.orders as o
    inner join dbo.orderitems as oi
        on o.orderid = oi.orderid
    where o.status = 'Completed'
      and o.saleschannel = 'Online'
    group by o.customerid, o.orderid
),

LargeOrdersByCustomer as (
    select customerid,
           count(*) as QualifyingOrders
    from OrderTotals
    where OrderTotal >= 200
    group by customerid
)

select customerid, QualifyingOrders
from LargeOrdersByCustomer
where QualifyingOrders >= 2
order by QualifyingOrders desc, customerid asc;

-- The store manager wants to review larger completed in-store orders.
-- Return order ID, customer ID, total units, and total order value.
-- Include only orders worth at least $150.
-- Sort by order value highest first, then order ID.
-- Use one CTE.

with LargeInStore as (

	select o.orderid, o.customerid, sum(oi.quantity) as TotalUnits, sum(oi.quantity * oi.unitprice) as TotalValue
	from dbo.orders as o
	inner join dbo.orderitems as oi
	on o.orderid = oi.orderid
	where o.saleschannel = 'In Store'
	and o.status = 'Completed'
	group by o.orderid, o.customerid
	)

	select orderid, customerid, TotalUnits, TotalValue
	from LargeInStore
	where TotalValue >= 150
	order by TotalValue desc, orderid asc;

	-- The online sales manager wants to review completed online orders
-- containing at least 8 units and worth at least $250.
-- Include order ID, customer ID, total units, and total order value.
-- Label orders worth $500 or more 'High Value';
-- label the rest 'Standard'.
-- Sort by order value highest first, then order ID ascending.
-- Use one CTE, with one row per order.

with SalesCtEWhoa as (

select o.orderid, o.customerid, sum(oi.quantity) as TotalUnits, sum(oi.quantity * oi.unitprice) as TotalOrderValue
from dbo.orders as o
inner join dbo.orderitems as oi
on o.orderid = oi.orderid
where o.status = 'Completed'
and o.saleschannel = 'Online'
group by o.orderid, o.customerid
)

select orderid, customerid, TotalUnits, TotalOrderValue, 

	case when TotalOrderValue >= 500 then 'High Value'
	else 'Standard'
	end as CustomerTier
from SalesCtEWhoa
where TotalUnits >= 8
and TotalOrderValue >= 250
order by TotalOrderValue desc, orderid asc;