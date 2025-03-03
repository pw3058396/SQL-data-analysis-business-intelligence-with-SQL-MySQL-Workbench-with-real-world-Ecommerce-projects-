Select 
	website_sessions.device_type,
    website_sessions.utm_source,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/ count(distinct website_sessions.website_session_id) as conv_rate
From website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.created_at between '2012-08-22' and '2012-09-18'
	and website_sessions.utm_campaign = 'nonbrand'
	and utm_source in ('bsearch', 'gsearch')
Group by 1,2