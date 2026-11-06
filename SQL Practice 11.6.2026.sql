-- Problem 1: We want to compare order outcomes for our online customers.
-- For each customer with online orders, include customer ID,
-- total online order count, completed count, and cancelled count.
-- Only include customers with at least 3 online orders overall.
-- Put the most cancelled orders first, then highest total order count,
-- then customer ID ascending.

select customerid, count(orderid) as OrderCount,

	sum(case when status = 'Completed' then 1 else 0 end) as CompletedOrders,
	sum(case when status = 'Cancelled' then 1 else 0 end) as CancelledOrders
from dbo.orders
where saleschannel = 'Online'
group by customerid
having count(orderid) >= 3
order by CancelledOrders desc, OrderCount desc, customerid asc;

-- Problem 2: We need an order activity report for every customer
-- in Madison, including those who have never ordered.
-- Include customer ID, name, total order count,
-- completed order count, returned order count, and latest order date.
--
-- Add an ActivityTier based on total orders:
-- 10 or more: 'Frequent'
-- 1–9: 'Occasional'
-- 0: 'Never Ordered'
--
-- Include orders of every status.
-- Put the most returned orders first, then highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, count(o.orderid) as OrderCount, max(o.orderdate) as Latest,

		sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
		sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOrders,

	case 

		when count(o.orderid) >= 10 then 'Frequent'
		when count(o.orderid) >= 1 then 'Occasional'
		else 'Never Ordered'
	end as ActivityTier
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city = 'Madison'
group by c.customerid, c.customername
order by ReturnedOrders desc, OrderCount desc, c.customername asc;

-- Problem 3: We want to identify repeat customers in Chicago and
-- Milwaukee who may need follow-up about cancelled orders.
--
-- Include customer ID, name, city, total order count,
-- completed order count, cancelled order count, and latest order date.
-- Count orders of every status.
-- Keep customers with at least 5 orders overall.
--
-- Add a FollowUp column:
-- 3 or more cancelled orders: 'Priority'
-- 1–2 cancelled orders: 'Check In'
-- No cancelled orders: 'No Follow-Up'
--
-- Put the most cancelled orders first, then most completed orders,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount,

	sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
	sum(case when o.status = 'Cancelled' then 1 else 0 end) as CancelledOrders,

	max(o.orderdate) as LatestOrder,

case
    when sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 3 then 'Priority'
    when sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 1 then 'Check In'
    else 'No Follow-Up'
end as FollowUp

from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Milwaukee','Chicago')
group by c.customerid, c.customername, c.city
having count(o.orderid) >= 5
order by CancelledOrders desc, CompletedOrders desc, c.customername asc;

-- Problem 4: We need a customer outreach report for Madison,
-- Green Bay, and Milwaukee, including customers who never ordered.
--
-- Include customer ID, name, city, total order count,
-- completed order count, cancelled order count, and latest order date.
-- Include orders of every status.
--
-- Add a Market column based on the customer's city:
-- Madison: 'Local'
-- All other included cities: 'Regional'
--
-- Add a FollowUp column based on cancelled order count:
-- 3 or more: 'Priority'
-- 1–2: 'Check In'
-- 0: 'No Follow-Up'
--
-- Put the most cancelled orders first, then highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, 

	sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
	sum(case when o.status = 'Cancelled' then 1 else 0 end) as CancelledOrders,

	max(o.orderdate) as Latest,

	case
		when c.city = 'Madison' then 'Local'
		else 'Regional'
	end as Market,

	case
			when 
					sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 3 then 'Priority'
				when 	sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 1 then 'Check In'
					else 'No Follow Up'
			end as FollowUp
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Green Bay','Milwaukee')
group by c.customerid, c.customername, c.city
order by CancelledOrders desc, count(o.orderid) desc, c.customername asc;

-- Problem 5: For each customer with orders, count their returned orders.
-- Add a ReturnFlag: at least 2 returns means 'Review';
-- otherwise use 'Standard'.

select customerid, count(orderid) as OrderCount, 

	sum(case when status = 'Returned' then 1 else 0 end) as ReturnedOrders,

	case when sum(case when status = 'Returned' then 1 else 0 end) >= 2 then 'Review'
	else 'Standard'
end as ReturnFlag
from dbo.orders
group by customerid;

-- Problem 6: For each customer with orders, include their customer ID
-- and cancelled order count.
-- Add a FollowUp column:
-- At least 3 cancelled orders: 'Contact'
-- Otherwise: 'No Action'
-- Put the most cancelled orders first.

select customerid, count(orderid) as OrderCount,

	sum(case when status = 'Cancelled' then 1 else 0 end) as CancelledOrders,

	case when sum(case when status = 'Cancelled' then 1 else 0 end) >= 3 then 'Contact'
	else 'No Action'
	end as FollowUp
from dbo.orders
group by customerid
order by CancelledOrders desc;

-- Problem 7: For each customer with orders, include customer ID
-- and completed order count.
-- Add a CustomerTier based on completed orders:
-- 10 or more: 'Established'
-- 5–9: 'Growing'
-- Below 5: 'New'
-- Include orders of every status in the underlying data.
-- Put the most completed orders first.

select customerid, 

	sum(case when status = 'Completed' then 1 else 0 end) as CompletedOrders,

	case when sum(case when status = 'Completed' then 1 else 0 end) >= 10 then 'Established'
	when sum(case when status = 'Completed' then 1 else 0 end) >= 5 then 'Growing'
	else 'New'
	end as CustomerTier
from dbo.orders
group by customerid
order by CompletedOrders desc;

-- Problem 8: We need a customer outreach report for Madison and
-- Green Bay, including customers who have never ordered.
--
-- Include customer ID, name, city, total order count,
-- completed order count, cancelled order count, and latest order date.
-- Include orders of every status.
--
-- Add a Market column:
-- Madison: 'Local'
-- Green Bay: 'Regional'
--
-- Add a FollowUp column based on cancelled orders:
-- 3 or more: 'Priority'
-- 1–2: 'Check In'
-- 0: 'No Action'
--
-- Put the most cancelled orders first, then highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, max(o.orderdate) as Latest,
		sum(case when status = 'Completed' then 1 else 0 end) as 'CompletedCount',
		sum(case when status = 'Cancelled' then 1 else 0 end) as 'CancelledCount',

	case when c.city = 'Madison' then 'Local'
	else 'Regional'
	end as Market,

	case when sum(case when status = 'Cancelled' then 1 else 0 end) >= 3 then 'Priority'
	when sum(case when status = 'Cancelled' then 1 else 0 end) >= 1 then 'Check In'
	else 'No Action'
	end as FollowUp

from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Green Bay')
group by c.customerid, c.customername, c.city
order by CancelledCount desc, OrderCount desc, c.customername asc;

-- Problem 9: We need a customer review for Chicago and Milwaukee,
-- including customers who have never ordered.
--
-- Include customer ID, name, city, total order count,
-- completed order count, returned order count,
-- and earliest and latest order dates.
-- Include orders of every status.
--
-- Add a Market column:
-- Chicago: 'Illinois'
-- Milwaukee: 'Wisconsin'
--
-- Add a ReturnTier based on returned orders:
-- 3 or more: 'High'
-- 1–2: 'Some'
-- 0: 'None'
--
-- Put the most returned orders first, then most completed orders,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, min(o.orderdate) as Oldest, max(o.orderdate) as Newest, 

			sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
			sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOrders,

			case when c.city = 'Chicago' then 'Illinois'
			else 'Wisconsin'
			end as Market,

			case when sum(case when o.status = 'Returned' then 1 else 0 end) >= 3 then 'High'
			when sum(case when o.status = 'Returned' then 1 else 0 end) >= 1 then 'Some'
			else 'None'
			end as ReturnTier

	from dbo.customers as c
	left join dbo.orders as o
	on c.customerid = o.customerid
where c.city in('Chicago','Milwaukee')
group by c.customerid, c.customername, c.city
order by ReturnedOrders desc, CompletedOrders desc, c.customername asc;

-- Problem 10: Marketing wants to review repeat customers in Madison,
-- Green Bay, and Chicago.
--
-- Include customer ID, name, city, total order count,
-- online order count, in-store order count, and latest order date.
-- Include orders of every status.
-- Keep customers with at least 5 orders overall.
--
-- Add a Region column:
-- Chicago: 'Illinois'
-- All other included cities: 'Wisconsin'
--
-- Add an OnlineTier based on online orders:
-- 8 or more: 'Frequent Online'
-- 3–7: 'Occasional Online'
-- Below 3: 'Rarely Online'
--
-- Put the most online orders first, then highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, max(o.orderdate) as Latest,

	sum(case when o.saleschannel = 'Online' then 1 else 0 end) as OnlineOrders,
	sum(case when o.saleschannel = 'In Store' then 1 else 0 end) as InStoreOrders,

	case when c.city = 'Chicago' then 'Illinois'
	else 'Wisconsin'
	end as Region,

	case when sum(case when o.saleschannel = 'Online' then 1 else 0 end) >= 8 then 'Frequent Online'
	when sum(case when o.saleschannel = 'Online' then 1 else 0 end) >= 3 then 'Occasional Online'
	else 'Rarely Online'
	end as OnlineTier

from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Chicago','Green Bay')
group by c.customerid, c.customername, c.city 
having count(o.orderid)>= 5
order by OnlineOrders desc, OrderCount desc, c.CustomerName asc;

-- Problem 11: We want a customer service report for Madison and Chicago,
-- including customers who have never ordered.
--
-- Include customer ID, name, city, total order count,
-- completed order count, returned order count, and latest order date.
-- Include orders of every status.
--
-- Add a Market column:
-- Madison: 'Local'
-- Chicago: 'Out of State'
--
-- Add a ServiceTier based on returned orders:
-- 3 or more: 'Priority Review'
-- 1–2: 'Monitor'
-- 0: 'No Returns'
--
-- Put the most returned orders first, then highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, max(o.orderdate) as LatestOrder,

			sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
			sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOrders,

			case when c.city = 'Madison' then 'Local'
			else 'Out of State'
			end as Market,

			case when sum(case when o.status = 'Returned' then 1 else 0 end) >= 3 then 'Priority Review'
			when sum(case when o.status = 'Returned' then 1 else 0 end) >= 1 then 'Monitor'
			else 'No Returns'
			end as ServiceTier
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Chicago')
group by c.customerid, c.CustomerName, c.city
order by ReturnedOrders desc, OrderCount desc, c.CustomerName asc;

-- Problem 12: Marketing wants an activity report for customers in
-- Green Bay, Milwaukee, and Chicago, including those who never ordered.
--
-- Include customer ID, name, city, total order count,
-- online order count, in-store order count,
-- and earliest and latest order dates.
-- Include orders of every status.
--
-- Add a Region column:
-- Chicago: 'Illinois'
-- All other included cities: 'Wisconsin'
--
-- Add an OnlineTier based on online orders:
-- 6 or more: 'Regular Online'
-- 1–5: 'Occasional Online'
-- 0: 'No Online Orders'
--
-- Put the most online orders first, then highest total order count,
-- then customer name alphabetically.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, min(o.orderdate) as EarliestOrder, max(o.orderdate) as LatestOrder,
				sum(case when o.saleschannel = 'Online' then 1 else 0 end) as OnlineOrders,
				sum(case when o.saleschannel = 'In Store' then 1 else 0 end) as InStoreOrders,

			case 
					when c.city = 'Chicago' then 'Illinois' 
					else 'Wisconsin'
					end as Region,
			case 
				when
					sum(case when o.saleschannel = 'Online' then 1 else 0 end) >= 6 then 'Regular Online'
				when	sum(case when o.saleschannel = 'Online' then 1 else 0 end) >= 1 then 'Occasional Online'
					else 'No Online Orders'
				end as OnlineTier
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Green Bay','Chicago','Milwaukee')
group by c.customerid, c.customername, c.city
order by OnlineOrders desc, OrderCount desc, c.CustomerName asc;

-- Problem 13: Marketing wants to contact customers who signed up
-- but have never placed an order.
-- Find those customers in Madison and Green Bay.
-- Include customer ID, name, city, and signup date.
-- Put the newest signups first, then customer name alphabetically.

select c.customerid, c.customername, c.city, c.signupdate
from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid
where c.city in('Madison','Green Bay')
and o.orderid is null
order by c.signupdate desc, c.CustomerName asc;

-- Problem 14: We want to review clothing and accessories that have
-- never appeared in an order.
-- Include product ID, name, category, and list price.
-- Put the most expensive products first, then product name alphabetically.

select p.productid, p.productname, p.category, p.listprice
from dbo.RetailProducts as p
left join dbo.orderitems as o
on p.productid = o.productid
where category in('Clothing','Accessories')
and o.orderid is null
order by p.listprice desc, p.productname asc;

-- Problem 15: Marketing needs a customer outreach report for Madison,
-- Green Bay, Milwaukee, and Chicago, including people who never ordered.
--
-- Include customer ID, name, city, signup date, total order count,
-- completed, cancelled, and returned order counts,
-- online and in-store order counts,
-- and earliest and latest order dates.
-- Include orders of every status.
--
-- Add a Region column:
-- Chicago: 'Illinois'
-- All other included cities: 'Wisconsin'
--
-- Add an OrderHistory column using a NULL check on the latest order date:
-- Missing date: 'Never Ordered'
-- Otherwise: 'Has Ordered'
--
-- Add a CustomerTier based on completed orders:
-- 10 or more: 'Established'
-- 5–9: 'Growing'
-- 1–4: 'New'
-- 0: 'No Completed Orders'
--
-- Add a FollowUp column based on cancelled orders:
-- 3 or more: 'Priority'
-- 1–2: 'Check In'
-- 0: 'No Action'
--
-- Put the most cancelled orders first, then most completed orders,
-- then newest signup date, then customer name alphabetically.

select c.customerid, c.customername, c.city, c.signupdate, count(o.orderid) as OrderCount, min(o.orderdate) as EarliestOrder, max(o.orderdate) as RecentOrder,

	sum(case when o.status = 'Completed' then 1 else 0 end) as CompletedOrders,
	sum(case when o.status = 'Cancelled' then 1 else 0 end) as CancelledOrders,
	sum(case when o.status = 'Returned' then 1 else 0 end) as ReturnedOrders,

	sum(case when o.saleschannel = 'Online' then 1 else 0 end) as OnlineOrders,
	sum(case when o.saleschannel = 'In Store' then 1 else 0 end) as InStoreOrders,

	case when c.city = 'Chicago' then 'Illinois'
	else 'Wisconsin'
	end as Region,

	case
    when max(o.orderdate) is null then 'Never Ordered'
    else 'Has Ordered'
end as OrderHistory,

	case when sum(case when o.status = 'Completed' then 1 else 0 end) >= 10 then 'Established'
	when sum(case when o.status = 'Completed' then 1 else 0 end) >= 5 then 'Growing'
	when sum(case when o.status = 'Completed' then 1 else 0 end) >= 1 then 'New'
	else 'No Completed Orders'
	end as CustomerTier,

	case when sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 3 then 'Priority'
	when sum(case when o.status = 'Cancelled' then 1 else 0 end) >= 1 then 'Check In'
	else 'No Action'
	end as FollowUp

from dbo.customers as c
left join dbo.orders as o
on c.customerid = o.customerid

where c.city in('Madison','Green Bay','Milwaukee','Chicago')

group by c.customerid, c.customername, c.city, c.signupdate

order by CancelledOrders desc, CompletedOrders desc, c.signupdate desc, c.customername asc;
