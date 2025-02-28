-- Take a look at 2012's monthly and weekly volume patterns, to find seasonal trend we should plan for in 2013.
-- Pull session volum and order volume

Use mavenfuzzyfactory;


-- Find the monthly volume 
Select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders
From website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.created_at <= '2012-12-31'
Group by 1,2;


-- Find the weekly volume 
Select 
	Min(Date(website_sessions.created_at)) as week_start_date,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders
From website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.created_at <= '2012-12-31'
Group by week(website_sessions.created_at);

