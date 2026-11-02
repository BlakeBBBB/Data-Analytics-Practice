-- Problem 1: Which credited performers have at least 5 Top 20 songs,
-- with those songs averaging at least 25 weeks on the chart?
-- Include performer, song count, and average chart weeks.
-- Sort by longest average chart stay, then highest song count.

select performer, count(*) as Songs, avg(weeks_on_chart) as AvgWeeks
from dbo.hot100_clean
where peak_position <= 20
group by performer
having count(*) >= 5
and avg(weeks_on_chart) >= 25
order by AvgWeeks desc, Songs desc;

-- Problem 2: Excluding Drake and Glee Cast, which credited performers
-- have at least 8 songs with a nonmissing Spotify track ID
-- and an average peak position of 30 or better?
-- Include performer, song count, average peak, and longest chart stay.
-- Sort by best average peak, then highest song count.

select performer, count(*) as Songs, avg(peak_position) as Peakzilla, max(weeks_on_chart) as LongestStay
from dbo.hot100_clean
where spotify_track_id is not null
and performer <> 'Drake' and performer <> 'Glee Cast'
group by performer
having count(*) >= 8
and avg(peak_position) <= 30
order by Peakzilla asc, Songs desc;

-- Problem 3: We're putting together a report on artists with staying power.
-- Which performers have at least 6 songs that each lasted 20 weeks or more
-- on the chart? I'd like their song count, average chart stay, and best
-- peak position, with the longest averages first. If there's a tie,
-- put whoever has more qualifying songs first.
-- Use dbo.hot100_clean.

select performer, count(*) as Songs, avg(weeks_on_chart) as AvgWeeks, min(peak_position) as Topp
from dbo.hot100_clean
where weeks_on_chart >= 20
group by performer
having count(*) >= 6
order by AvgWeeks desc, Songs desc;

-- Problem 4: We're reviewing artists for a promotional campaign.
-- Which artists appear on at least 2 Top 20 songs?
-- Only consider songs whose titles contain neither 'Summer' nor 'Rain'.
-- Include artist, qualifying song count, average peak, and best peak.
-- Put the strongest average peak first, then the highest song count.

select a.artist, count(*) as Songs, avg(s.peak_position) as AvgPeak, min(s.peak_position) as Best
from dbo.SongArtists as a
inner join dbo.songs as s
on a.song_id = s.song_id
where s.peak_position <= 20
and s.song not like '%Summer%' and s.song not like '%Rain%'
group by a.artist
having count(*) >= 2
order by AvgPeak asc, Songs desc;

-- Problem 5: We need to check how complete our artist credits are.
-- For every Top 40 song, show its ID, title, peak position,
-- and number of credited artists. Include songs with no artist mapping,
-- showing an artist count of zero.
-- Put songs with the fewest artists first, then best peak position,
-- then title alphabetically.

select s.song_id, s.song, s.peak_position, count(a.artist) as ArtistCount
from songs as s
left join SongArtists as a
on s.song_id = a.song_id
where s.peak_position <= 40
group by s.song_id, s.song, s.peak_position
order by count(a.artist) asc, s.peak_position asc, s.song asc;

-- Problem 6: We want to promote Top 40 songs with smaller artist lineups.
-- Find songs with fewer than 2 credited artists, including songs
-- that have no artist mapping.
-- Include song ID, title, peak position, and artist count.
-- Put the best peak position first, then title alphabetically.

select s.song_id, s.song, s.peak_position, count(a.artist) as ArtistCount
from dbo.songs as s
left join SongArtists as a
on s.song_id = a.song_id
where s.peak_position <= 40
group by s.song_id, s.song, s.peak_position
having count(a.artist) < 2
order by s.peak_position asc, s.song asc;

-- Problem 7: We're reviewing collaborations for a playlist.
-- Which Top 20 songs have at least 2 credited artists?
-- Leave out songs whose titles contain 'Rain'.
-- Include song ID, title, peak position, and artist count.
-- Put songs with the most artists first, then best peak position,
-- then title alphabetically.

select s.song_id, s.song, s.peak_position, count(a.artist) as Artists
from Songs as s
inner join SongArtists as a
on s.song_id = a.song_id
where peak_position <= 20
and s.song not like '%Rain%'
group by s.song_id, s.song, s.peak_position
having count(a.artist) >= 2
order by Artists desc, s.peak_position asc, s.song asc;

-- Problem 8: Before we share the catalog report, I want to check
-- whether any of our biggest hits are missing artist credits.
-- Can you pull together a review list, with the most successful
-- songs at the top?
-- For this review, "biggest hits" means songs that reached the Top 10.

select s.song_id, s.song, count(a.artist) as Artists, s.peak_position
from Songs as s
left join SongArtists as a
on s.song_id = a.song_id
where s.peak_position <= 10
group by s.song_id, s.song, s.peak_position
having count(a.artist) = 0
order by s.peak_position asc;

-- Problem 9: We're checking the catalog before sending it to marketing.
-- Can you find Top 40 songs that have fewer than 2 credited artists?
-- Keep songs with missing credits on the list too.
-- Include enough detail to identify each song and see its artist count.
-- Prioritize missing credits first, then the strongest chart performance.

select s.song_id, s.song, s.peak_position, count(a.artist) as Artists
from Songs as s
left join SongArtists as a
on s.song_id = a.song_id
where s.peak_position <= 40
group by s.song_id, s.song, s.peak_position
having count(a.artist) < 2
order by Artists asc, s.peak_position asc;

-- Problem 10: Marketing wants a review list of songs with smaller
-- credited lineups before planning the next campaign.
-- Consider songs that peaked between positions 5 and 40.
-- Leave out titles containing 'Summer' or 'Rain'.
-- Keep songs with fewer than 2 credited artists, including those
-- with no artist mapping.
-- Include song ID, title, peak position, and artist count.
-- Put missing credits first, then best peak position,
-- then title alphabetically.

select s.song_id, s.song, s.peak_position, count(a.artist) as Artists
from songs as s
left join SongArtists as a
on s.song_id = a.song_id 
where s.peak_position between 5 and 40
and s.song not like '%Summer%' and s.song not like '%Rain%'
group by s.song_id, s.song, s.peak_position
having count(a.artist) < 2
order by Artists asc, s.peak_position asc, s.song asc;

-- Problem 11: We're building a shortlist of artists with repeated
-- chart success, rather than someone who had just one big hit.
-- Focus on Top 20 songs, leaving out titles containing 'Summer' or 'Rain'.
-- Alex is already covered by another campaign, so leave Alex out
-- of the artist shortlist.
-- I'd like artists with at least 2 qualifying songs whose average
-- peak is 10 or better.
-- Give me enough detail to compare their song counts, average peaks,
-- and best peaks. Lead with the strongest average, using song count
-- to break ties.

select a.artist, count(*) as Songs, avg(peak_position) as Avg, min(peak_position) as Peakzilla
from SongArtists as a
inner join songs as s
on a.song_id = s.song_id
where s.peak_position <= 20
and s.song not like '%Summer%' and s.song not like '%Rain%'
and a.artist <> 'Alex'
group by a.artist
having count(*) >= 2
and avg(peak_position) <= 10
order by Avg asc, Songs desc;

--														  !!!New practice tables created so changing the dataset!!!
-- Problem 12: We're reviewing our repeat customers.
-- Which customers have placed at least 5 completed orders?
-- Include their customer ID, name, city, and completed order count.
-- Put the most frequent customers first, then sort tied customers
-- alphabetically by name.
-- Completed orders have Status = 'Completed'.

select c.customerID, c.customername, c.city, count(o.orderid) as OrderCount
from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
where o.status = 'Completed'
group by c.customerid, c.customername, c.city
having count(o.orderid) >= 5
order by OrderCount desc, c.customername asc;

-- Problem 13: We're planning a loyalty campaign for online shoppers
-- in Madison and Milwaukee.
-- Find customers in those cities with at least 3 completed online orders.
-- Include their ID, name, city, qualifying order count,
-- and the dates of their first and most recent qualifying orders.
-- Prioritize customers with the most qualifying orders.
-- If counts tie, put the most recent shoppers first,
-- then sort by customer name alphabetically.
-- Status = 'Completed' and SalesChannel = 'Online'.

select c.customerid, c.customername, c.city, count(o.orderid) as OrderCount, 
									min(o.orderdate) as FirstOrder, max(o.orderdate) as LatestOrder
from customers as c
inner join orders as o
on c.customerid = o.customerid
where o.saleschannel = 'Online'
and c.city in('Madison', 'Milwaukee')
and o.Status = 'Completed'
group by c.customerid, c.customername, c.city
having count(o.orderid) >= 3
order by OrderCount desc, LatestOrder desc, c.customername asc;

-- Problem 14: We're checking repeat shoppers at our physical stores.
-- Find customers in Green Bay or Chicago who have at least
-- 2 completed in-store orders.
-- Include their ID, name, city, qualifying order count,
-- and their earliest and most recent qualifying order dates.
-- Put the customers who shopped most recently first.
-- Break ties by highest qualifying order count, then name alphabetically.
-- Status = 'Completed' and SalesChannel = 'In Store'.

select c.customerid, c.customername, c.city, count(orderid) as OrderCount, min(o.orderdate) as First, max(o.orderdate) as Last
from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
where o.SalesChannel = 'In Store'
and o.status = 'Completed'
and c.city in ('Green Bay', 'Chicago')
group by c.customerid, c.customername, c.city
having count(orderid) >= 2
order by Last desc, OrderCount desc, c.customername asc;

-- Problem 15: We want to recognize loyal online customers outside Chicago.
-- Find customers with at least 4 completed online orders.
-- Include their ID, name, city, qualifying order count,
-- and their first and most recent qualifying order dates.
-- Put customers with the most qualifying orders first,
-- then those who ordered most recently, then name alphabetically.
-- Status = 'Completed' and SalesChannel = 'Online'.

select c.customerid, c.customername, c.city, count(orderid) as OrderCount, min(orderdate) as First, max(Orderdate) as Last
from dbo.customers as c
inner join dbo.orders as o
on c.customerid = o.customerid
where c.city <> 'Chicago'
and SalesChannel = 'Online'
and o.status = 'Completed'
group by c.customerid, c.customername, c.city
having count(orderid) >= 4
order by OrderCount desc, Last desc, c.customername asc;