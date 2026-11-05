-- Problem 1: We want to review order outcomes for each customer.
-- Include customer ID, completed order count, and returned order count.
-- Include orders of every status in the underlying data.
-- Put customers with the most returned orders first,
-- then the most completed orders.

select customerid,
					sum(case when Status = 'Completed' then 1 else 0 end) as CompletedCount,
					sum(case when Status = 'Returned' then 1 else 0 end) as ReturnedCount
				from dbo.orders
group by customerid
order by ReturnedCount desc, CompletedCount desc;

-- Problem 2: For online orders only, compare each customer's
-- completed and cancelled order counts.
-- Include customer ID and both counts.
-- Put the most cancelled orders first, then the most completed orders.

select customerid,
					sum(case when Status = 'Completed' then 1 else 0 end) as CompletedCount,
					sum(case when Status = 'Cancelled' then 1 else 0 end) as CancelledCount
			from dbo.orders
where SalesChannel = 'Online'
group by customerid
order by CancelledCount desc, CompletedCount desc;

-- Problem 3: We want to compare how repeat customers place
-- their completed orders.
-- For each customer, include their total completed order count,
-- split into online and in-store counts in separate columns.
-- Only include customers with at least 4 completed orders overall.
-- Put the highest total completed order counts first,
-- then the highest online counts.

select customerid, count(*) as OrderCount,
		sum(case when SalesChannel = 'Online' then 1 else 0 end) as OnlineOrders,
		sum(case when SalesChannel = 'In Store' then 1 else 0 end) as InStoreOrders
	from dbo.orders
where status = 'Completed'
group by customerid
having count(*) >= 4
order by OrderCount desc, OnlineOrders desc;

-- Problem 4: We're reviewing order outcomes for customers in
-- Madison and Milwaukee.
-- Include customer ID, name, city, total order count,
-- completed order count, and cancelled order count.
-- Count orders of every status in the total.
-- Only include customers with at least 5 orders overall.
-- Put the most cancelled orders first, then the highest total
-- order count, then customer name alphabetically.

select c.customerid, c.customername, c.city, count(*) as OrderCount, 
	sum(case when o.Status = 'Completed' then 1 else 0 end) as CompletedCount,
	sum(case when o.Status = 'Cancelled' then 1 else 0 end) as CancelledCount
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Milwaukee')
group by c.customerid, c.customername, c.city
having count(*) >= 5
order by CancelledCount desc, OrderCount desc, c.CustomerName asc;

-- Problem 5: We need an activity report for every customer in Green Bay,
-- including customers who have never ordered.
-- Include customer ID, name, total order count, completed order count,
-- and returned order count.
-- Count orders of every status in the total.
-- Customers with no orders should have zero in each count.
-- Put the highest total order counts first, then names alphabetically.

select c.customerid, c.customername, count(o.orderid) as OrderCount, 
		sum(case when Status = 'Completed' then 1 else 0 end) as CompletedCount,
		sum(case when Status = 'Returned' then 1 else 0 end) as ReturnedCount
	from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city = 'Green Bay'
group by c.customerid, c.customername
order by OrderCount desc, c.customername asc;

-- Problem 6: We want to review how customers in Chicago and Milwaukee
-- place their orders, including customers who have never ordered.
-- Include customer ID, name, city, total order count,
-- online order count, and in-store order count.
-- Include orders of every status.
-- Keep only customers with fewer than 3 orders overall.
-- Put customers with the fewest orders first, then names alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, 
	sum(case when o.SalesChannel = 'Online' then 1 else 0 end) as OnlineOrders,
	sum(case when o.SalesChannel = 'In Store' then 1 else 0 end) as InStoreOrders
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Chicago','Milwaukee')
group by c.customerid, c.customername, c.city
having count(o.orderid) < 3
order by OrderCount asc, c.customername asc;

-- Problem 7: Marketing wants an activity report for customers
-- in Madison and Green Bay, including people who have never ordered.
--
-- Include customer ID, name, city, total order count,
-- completed order count, cancelled order count,
-- and their most recent order date.
-- Include orders of every status when calculating the total
-- and most recent date.
--
-- Add an ActivityTier based on total order count:
-- 6 or more: 'Frequent'
-- 1–5: 'Occasional'
-- 0: 'Never Ordered'
--
-- Keep customers with fewer than 8 orders overall.
-- Put the most completed orders first, then highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, max(o.orderdate) as RecentOrder,
		sum(case when o.Status = 'Completed' then 1 else 0 end) as CompletedOrders,
		sum(case when o.Status = 'Cancelled' then 1 else 0 end) as CancelledOrders,
					
					case 
							when count(o.orderid) >= 6 then 'Frequent'
							when count(o.orderid) >= 1 then 'Occasional'
							else 'Never Ordered'
					end as ActivityTier

from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Green Bay','Madison')
group by c.customerid, c.customername, c.city
having count(o.orderid) < 8
order by CompletedOrders desc, OrderCount desc, c.CustomerName asc;

-- Problem 8: We want to understand shopping activity among customers
-- in Chicago and Milwaukee, including those who have never ordered.
--
-- Include customer ID, name, city, total order count,
-- online order count, in-store order count,
-- and their earliest and latest order dates.
-- Include orders of every status.
--
-- Add an EngagementTier based on total order count:
-- 5 or more: 'Regular'
-- 1–4: 'Occasional'
-- 0: 'Not Yet Active'
--
-- Keep customers with no more than 7 orders overall.
-- Put the most online orders first, then highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, min(o.orderdate) as Oldest, max(o.orderdate) as Newest,
		sum(case when o.saleschannel = 'Online' then 1 else 0 end) as OnlineOrders,
		sum(case when o.saleschannel = 'In Store' then 1 else 0 end) as InStoreOrders,

			case

				when count(o.orderid) >= 5 then 'Regular'
				when count(o.orderid) >= 1 then 'Occasional'
				else 'Not Yet Active'
			end as EngagementTier
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid 
where c.city in('Chicago','Milwaukee')
group by c.customerid, c.customername, c.city 
having count(o.orderid) <= 7
order by OnlineOrders desc, OrderCount desc, c.customername asc;

-- Problem 9: We're preparing a customer activity review for Madison,
-- Green Bay, and Milwaukee. Include customers who have never ordered.
--
-- Include customer ID, name, city, total order count,
-- completed, cancelled, and returned order counts,
-- online and in-store order counts,
-- and earliest and latest order dates.
-- Use orders of every status for the total, channel counts, and dates.
--
-- Add an ActivityTier based on total order count:
-- 6 or more: 'Frequent'
-- 3–5: 'Occasional'
-- 1–2: 'New'
-- 0: 'Never Ordered'
--
-- Also add a ReturnFlag:
-- Customers with at least 2 returned orders get 'Review';
-- everyone else gets 'Standard'.
--
-- Keep customers with no more than 8 orders overall.
-- Put the most returned orders first, then most completed orders,
-- then highest total order count, then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, min(o.orderdate) as Oldest, max(o.orderdate) as Newest, 
	sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
	sum(case when o.status = 'Cancelled' then 1 else 0 end) as CancelledOrders,
	sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOrders,

	sum(case when o.saleschannel = 'Online' then 1 else 0 end) as OnlineOrders,
	sum(case when o.saleschannel = 'In Store' then 1 else 0 end) as InStoreOrders,

	case 
			when count(o.orderid) >= 6 then 'Frequent'
			when count(o.orderid) >= 3 then 'Occasional'
			when count(o.orderid) >= 1 then 'New'
			else 'Never Ordered'
		end as ActivityTier
,case
		when sum(case when o.status = 'Returned' then 1 else 0 end) >= 2 then 'Review'
		else 'Standard'
	end as ReturnFlag
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Milwaukee','Green Bay')
group by c.customerid, c.customername, c.city
having count(o.orderid) <= 8
order by ReturnedOrders desc, CompletedOrders desc, OrderCount desc, c.customername asc;

-- Problem 10: We need a customer activity report for Chicago and
-- Milwaukee, including customers who have never ordered.
--
-- Include customer ID, name, city, total order count,
-- completed, cancelled, and returned order counts,
-- online and in-store order counts,
-- and earliest and latest order dates.
-- Include orders of every status.
--
-- Add a CustomerTier based on completed orders:
-- 10 or more: 'Established'
-- 5–9: 'Growing'
-- 1–4: 'New'
-- 0: 'No Completed Orders'
--
-- Add a FollowUp column:
-- Customers with at least 2 cancelled orders get 'Contact';
-- everyone else gets 'No Follow-Up'.
--
-- Put the most cancelled orders first, then most completed orders,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, 

		sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
		sum(case when o.status = 'Cancelled' then 1 else 0 end) as CancelledOrders,
		sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOrders,

		sum(case when o.saleschannel = 'Online' then 1 else 0 end) as OnlineOrders,
		sum(case when o.saleschannel = 'In Store' then 1 else 0 end) as InStoreOrders,
	min(o.orderdate) as Oldest, max(o.orderdate) as Newest,

	case
    when sum(case when o.status = 'Completed' then 1 else 0 end) >= 10 then 'Established'
    when sum(case when o.status = 'Completed' then 1 else 0 end) >= 5 then 'Growing'
    when sum(case when o.status = 'Completed' then 1 else 0 end) >= 1 then 'New'
    else 'No Completed Orders'
end as CustomerTier,

	case when sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 2 then 'Contact'
		else 'No Follow Up' 
	end as FollowUp
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Milwaukee','Chicago')
group by c.customerid, c.customername, c.city
order by CancelledOrders desc, CompletedOrders desc, c.CustomerName asc;