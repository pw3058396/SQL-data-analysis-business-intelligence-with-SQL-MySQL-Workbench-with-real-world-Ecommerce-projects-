-- pull the conversion rates from session to order by device type
-- if the desktop performance is better on mobile we may bid up for desktop specifically to get more volume?

USE mavenfuzzyfactory;
Select 
	website_sessions.device_type,
	Count(distinct website_sessions.website_session_id) as sessions,
    Count(distinct orders.order_id) as orders,
    Count(distinct orders.order_id)/Count(distinct website_sessions.website_session_id) as session_to_order_conve_rate    
From website_sessions 
	left join orders
		on orders.website_session_id = website_sessions.website_session_id
Where website_sessions.created_at <'2012-05-11' and utm_source ='gsearch' and utm_campaign = 'nonbrand'
group by 1