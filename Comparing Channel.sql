

Select
	utm_source,
	count(distinct website_session_id) as sessions, 
    count(distinct case when device_type = 'mobile' then website_session_id else null end) as mobile_sessions,
    count(distinct case when device_type = 'mobile' then website_session_id end)/count(distinct website_session_id) as pct_mobile
From website_sessions
Where created_at between '2012-08-22' and '2012-11-30'
	And utm_campaign = 'nonbrand'
Group by 1;