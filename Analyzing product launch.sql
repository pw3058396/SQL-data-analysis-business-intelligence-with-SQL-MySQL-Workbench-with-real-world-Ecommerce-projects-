Use mavenfuzzyfactory;

Select distinct primary_product_id from orders
;
    

Select 
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) as conv_rate,
    sum(orders.price_usd) / count(distinct website_sessions.website_session_id) as revenue_per_session,
    count(distinct Case when orders.primary_product_id = 1 then orders.order_id else null end) as product_one_orders,
    count(distinct Case when orders.primary_product_id = 2 then orders.order_id else null end) as product_two_orders
From website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.created_at between '2012-04-01' and '2013-04-05'
Group by 1,2;
