-- We bid our gsearch nonbrand desktop campaign up on 2012-05-19.
-- Coul you pull weekly trend for both desktop and mobile to see the impact on the volume

USE mavenfuzzyfactory;
Select 
	-- year(created_at),
    -- week(created_at),
	Min(DATE(created_at)) as week_start_date,
    Count(Distinct Case when device_type = 'desktop' then website_session_id else null end) as dtop_sessions,
    Count(Distinct Case when device_type = 'mobile' then website_session_id else null end) as mob_sessions
From website_sessions
Where created_at > '2012-04-15' 
	and created_at < '2012-06-09' 
	and utm_source = 'gsearch' 
	and utm_campaign = 'nonbrand'
Group By 
	year(created_at),
    week(created_at)

