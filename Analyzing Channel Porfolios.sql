
Use mavenfuzzyfactory;

Select distinct utm_source from website_sessions;

Select
	Min(date(created_at)) as week_start_date,
	count(case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_sessions,
    count(case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_sessions
From website_sessions
Where created_at < '2012-11-29'
	and created_at > '2012-08-22'
    and utm_campaign = 'nonbrand'
Group by week(created_at);


