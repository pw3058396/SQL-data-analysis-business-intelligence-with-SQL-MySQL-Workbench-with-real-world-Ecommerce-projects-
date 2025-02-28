-- Calculate the conversion rate(CVR) from sessions to order? 

USE mavenfuzzyfactory;
Select 
	Count(distinct website_sessions.website_session_id) as sessions,
    Count(distinct orders.order_id) as orders,
    Count(distinct orders.order_id)/Count(distinct website_sessions.website_session_id) as session_to_order_conve_rate    
From website_sessions left join orders
on orders.website_session_id = website_sessions.website_session_id
Where website_sessions.created_at <'2012-04-14' and utm_source ='gsearch' and utm_campaign = 'nonbrand'