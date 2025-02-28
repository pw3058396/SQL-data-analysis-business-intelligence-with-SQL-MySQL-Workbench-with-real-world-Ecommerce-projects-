-- On December 12th , we launched a third product targeting the birthday gift market.
-- Please run a pre-post analysis comparing the month before vs. the month after, in terms of session-to-order conversion rate,
-- AOV, product per order, and revenue per session? 


Use mavenfuzzyfactory;

-- Step 1: find relevant sessions and orders information
Select 
	case 
		when website_pageviews.created_at <= '2013-12-12' then 'A. Pre_Birthday_Bear'
        when website_pageviews.created_at > '2013-12-12' then 'B. Post_Birthday_Bear'
        else null end as time_period,
	website_pageviews.website_session_id,
    orders.order_id,
    orders.items_purchased,
    orders.price_usd

From website_pageviews 
	left join orders
		on website_pageviews.website_session_id = orders.website_session_id
where website_pageviews.created_at between '2013-11-12' and '2014-01-12';





-- Step 2: make the table in website_session level to avoid from duplicate
-- Create temporary table session_order_count
Select
	max(time_period) as time_period,
    website_session_id,
    max(order_id) as order_id,
    max(items_purchased) as items_purchased,
    max(price_usd) as price_usd
    
From(

Select 
	case 
		when website_pageviews.created_at <= '2013-12-12' then 'A. Pre_Birthday_Bear'
        when website_pageviews.created_at > '2013-12-12' then 'B. Post_Birthday_Bear'
        else null end as time_period,
	website_pageviews.website_session_id,
    orders.order_id,
    orders.items_purchased,
    orders.price_usd

From website_pageviews 
	left join orders
		on website_pageviews.website_session_id = orders.website_session_id
where website_pageviews.created_at between '2013-11-12' and '2014-01-12') as session_order
Group by 2;



-- Step 3: calculate for the result
Select 
	time_period,
    Count(Distinct website_session_id) as sessions,
    Count(Distinct order_id) as orders,
    Count(Distinct order_id)/Count(Distinct website_session_id) as conv_rate,
    SUM(price_usd)/ Count(Distinct order_id) as aov,
    SUM(items_purchased) / Count(Distinct order_id) as product_per_order,
    SUM(price_usd)/ Count(Distinct website_session_id) as revenue_per_session
From session_order_count
Group by 1;
    