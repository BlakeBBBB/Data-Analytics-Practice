-- The store manager wants to review completed in-store orders
-- containing at least 3 different products and worth at least $200.
-- Include order ID, customer ID, number of different products,
-- total units purchased, and total order value.
-- Label orders containing at least 10 units 'Large Basket';
-- label the rest 'Standard Basket'.
-- Sort by order value highest first, then order ID ascending.
-- Use one CTE.

with AnotherCTE as (

select o.orderid, o.customerid, count(distinct oi.productid) as DifferentProducts, sum(oi.quantity) as UnitsPurchased, 
sum(oi.quantity * oi.unitprice) as TotalOrderValue
from dbo.orders as o
inner join dbo.orderitems as oi
on o.orderid = oi.orderid
where o.saleschannel = 'In Store'
and o.status = 'Completed'
group by o.orderid, o.customerid
)

select orderid, customerid, DifferentProducts, UnitsPurchased, TotalOrderValue,

case when UnitsPurchased >= 10 then 'Large Basket'
else 'Standard Basket'
end as PurchaseSize

from AnotherCTE

where DifferentProducts >= 3
and TotalOrderValue >= 200

order by TotalOrderValue desc, orderid asc;

-- The sales manager wants to compare online and in-store performance
-- for products in the Clothing and Accessories categories.
-- Consider completed orders only.
--
-- Include product ID, product name, category, number of orders,
-- online units sold, in-store units sold, and total revenue.
--
-- Keep products appearing in at least 20 different orders
-- and generating at least $1,000 in revenue.
--
-- Label each product 'Online Lead' if it sold more units online,
-- 'Store Lead' if it sold more units in stores, or 'Even' if tied.
--
-- Sort by revenue highest first, then product name alphabetically.
-- Use one CTE.

with OneProduct as (

select rp.productid, rp.productname, rp.category, count(distinct o.orderid) as OrderCount, sum(oi.quantity * oi.unitprice) as Revenue,

sum(case when o.saleschannel = 'Online' then oi.quantity else 0 end) as OnlineSales,
sum(case when o.saleschannel = 'In Store' then oi.quantity else 0 end) as InStoreSales

from dbo.RetailProducts as rp
inner join dbo.orderitems as oi
on rp.productid = oi.productid
inner join dbo.orders as o
on oi.orderid = o.orderid

where category in('Clothing','Accessories')
and o.status = 'Completed'
group by rp.productid, rp.productname, rp.category
)

select productid, productname, category, OrderCount, Revenue, OnlineSales, InStoreSales,

case when OnlineSales > InStoreSales then 'Online Lead'
when OnlineSales < InStoreSales then 'Store Lead'
else 'Even' 
end as Leader

from OneProduct
where OrderCount >= 20
and Revenue >= 1000

order by Revenue desc, productname asc;

-- The regional manager wants to understand shopping preferences
-- among customers in Madison and Milwaukee.
-- Consider completed orders only.
--
-- Include customer ID, name, city, number of different orders,
-- online spending, in-store spending, total spending,
-- and most recent qualifying order date.
--
-- Keep customers with at least 4 orders and $1,000 in total spending.
--
-- Label customers 'Online Preferred' if online spending is higher,
-- 'Store Preferred' if in-store spending is higher, or 'Balanced'
-- if the amounts are equal.
--
-- Also label customers 'VIP' if they have at least 6 orders
-- AND total spending of at least $2,000; otherwise, 'Standard'.
--
-- Sort by total spending highest first, then customer name A–Z.
-- Use one CTE.

with PrefCTE as (

select c.customerid, c.customername, c.city, count(distinct o.orderid) as OrderCount, 

sum(case when o.saleschannel = 'Online' then oi.quantity * oi.unitprice else 0 end) as OnlineSpending,
sum(case when o.saleschannel = 'In Store' then oi.quantity * oi.unitprice else 0 end) as InStoreSpending,

sum(oi.quantity * oi.unitprice) as TotalSpending,
max(o.orderdate) as RecentOrder

from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
inner join dbo.orderitems as oi
on o.orderid = oi.orderid

where c.city in('Madison','Milwaukee')
and o.status = 'Completed'

group by c.customerid, c.customername, c.city 
)

select customerid, customername, city, OrderCount, OnlineSpending, InStoreSpending, TotalSpending, RecentOrder,

case when OnlineSpending > InStoreSpending then 'Online Preferred'
when OnlineSpending < InStoreSpending then 'Store Preferred'
else 'Balanced'
end as CustomerPreferences, 

case when OrderCount >= 6 and TotalSpending >= 2000 then 'VIP'
else 'Standard'
end as Tier

from PrefCTE
where OrderCount >= 4
and TotalSpending >= 1000

order by TotalSpending desc, customername asc;

