-- We bid down gsearch nonbrand on 2012-04-15, please pull gsearch nonbrand trended session volume, by week,
-- to see if the bid changes have caused volume to drop at all

Select 
	Min(date(created_at)) as week_start_date,
    count(distinct website_session_id) as sessions
From website_sessions
Where created_at < '2012-05-12'
	and utm_source = 'gsearch'
    and utm_campaign= 'nonbrand'
Group by 
	year(created_at),
	week(created_at)
