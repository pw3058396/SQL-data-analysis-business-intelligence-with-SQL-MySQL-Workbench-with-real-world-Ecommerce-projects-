
-- pull a comparison of conversion rates and revenue per sessions for repeat sessions vs new sessions

Select 
	website_sessions.is_repeat_session,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rate,
    sum(orders.price_usd) as revenue,
    sum(orders.price_usd) /count(distinct website_sessions.website_session_id) as rev_per_session
From website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.created_at >= '2014-01-01'
	and website_sessions.created_at < '2014-11-08'
Group by 1
;