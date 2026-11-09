-- Customer service wants to review customers in Madison and Chicago.
-- Include everyone in those cities, even if they have never ordered.
-- Include their ID, name, city, total order count, cancelled order count,
-- and most recent order date.
--
-- Label customers with 3 or more cancelled orders 'Priority',
-- those with 1–2 'Check In', and everyone else 'No Action'.
--
-- Put the most cancellations first, then the highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, max(o.orderdate) as RecentOrder,

	sum(case when o.status = 'Cancelled' then 1 else 0 end) as CancelledCount,

	case 
		when 
			sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 3 then 'Priority'
			when sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 1 then 'Check In'
			else 'No Action'
		end as Labels
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Chicago')
group by c.customerid, c.customername, c.city
order by CancelledCount desc, OrderCount desc, c.customername asc;

-- Marketing wants to understand online shopping activity among
-- customers in Green Bay and Milwaukee, including those with no orders.
--
-- Include customer ID, name, city, total order count,
-- online order count, in-store order count, and earliest order date.
--
-- Label customers with at least 5 online orders 'Online Regular',
-- those with 1–4 'Occasional Online', and those with none 'No Online Orders'.
--
-- Limit the report to customers with fewer than 8 total orders.
-- Sort by online order count descending, total order count descending,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, min(o.orderdate) as EarliestOrder,

		sum(case when o.saleschannel = 'Online' then 1 else 0 end) as OnlineSales,
		sum(case when o.saleschannel = 'InStore' then 1 else 0 end) as InStoreSales,

		case when 
					sum(case when o.saleschannel = 'Online' then 1 else 0 end) >= 5 then 'Online Regular'
					when sum(case when o.saleschannel = 'Online' then 1 else 0 end) >= 1 then 'Occasional Online'
					else 'No Online Orders'
			end as Labels
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Green Bay','Milwaukee')
group by c.customerid, c.customername, c.city
having count(o.orderid) < 8
order by OnlineSales desc, OrderCount desc, c.customername asc;

-- Sales wants to identify valuable online customers in Madison and Milwaukee.
-- Consider completed online orders only.
--
-- Include customer ID, name, city, number of distinct orders,
-- total units purchased, total spending, and latest qualifying order date.
--
-- Label spending of $2,500 or more 'Gold',
-- $1,200 or more 'Silver', and everything below that 'Bronze'.
--
-- Include only customers with at least 3 qualifying orders
-- and at least $800 in spending.
--
-- Sort by spending descending, then order count descending,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(distinct o.orderid) as OrderCount, sum(oi.Quantity) as TotalUnits, sum(oi.Quantity * oi.UnitPrice) as TotalSpending, max(o.orderdate)
as LastestOrder,

	case when sum(oi.quantity * oi.unitprice) >= 2500 then 'Gold'
	when sum(oi.quantity * oi.unitprice) >= 1200 then 'Silver'
	else 'Bronze'
	end as SpendingTier

from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
inner join dbo.orderitems as oi
on o.orderid = oi.orderid
where c.city in('Madison','Milwaukee')
and o.status = 'Completed'
and o.Saleschannel = 'Online'
group by c.customerid, c.customername, c.city
having count(distinct o.orderid) >= 3
and sum(oi.quantity * oi.unitprice) >= 800
order by TotalSpending desc, OrderCount desc, c.customername asc;