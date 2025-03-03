-- Question 1: First, I'd like to show our volume growth. Can you pull overall session and order volume, trended by quarter for the lif of the business?
-- Since the most recent quarter is imcomplete, you can decide how to handle it.

Select
	year(website_sessions.created_at) as yr,
	quarter(website_sessions.created_at) as qtr,
	count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders
From website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
Group by 1,2;


-- Question 2: Showecase all of out efficiency improvement.show quarterly figures since we launched, 
-- for session to order conversion rate, revenue per order, and revenue per session.

Select
	year(website_sessions.created_at) as yr,
	quarter(website_sessions.created_at) as qtr,
    count(distinct orders.order_id) /count(distinct website_sessions.website_session_id) as conversion_rate,
    sum(orders.price_usd)/count(distinct orders.order_id) as revenue_per_order,
    sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as revenue_per_session
From website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
Group by 1,2;


-- Question 3: show how we've grown specific channel, would you pull a quarterly view of order from Gsearch nonbrand,
-- Bsearch nonbrand, brand search overall, organic search, and direct type-in?
-- Create temporary table channel_orders
Select 
	year(website_sessions.created_at),
    quarter(website_sessions.created_at),
    orders.created_at,
	website_sessions.utm_source,
    website_sessions.utm_campaign,
    http_referer,
	orders.order_id
From website_sessions inner join orders 
	on website_sessions.website_session_id = orders.website_session_id
;
    
    
Select 
	year(created_at) as yr,
    quarter(created_at) as qtr,
    Count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end) as gsearch_nonbrand,
    Count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end) as bsearch_nonbrand,
    Count(case when utm_campaign = 'brand' then order_id else null end) as brand_search,
    Count(case when utm_source is null and http_referer is not null then order_id else null end) as organic_search,
	Count(case when utm_source is null and http_referer is null then order_id else null end) as direct_type_in
From channel_orders 
Group by 1,2;




-- Question 4: show the overall session-to-order conversion rate trends for those same channels, by quarter. 
-- Please also make a note of any period where we made major improvement or optimization.

Create temporary table channel_orders
Select 
	year(website_sessions.created_at),
    quarter(website_sessions.created_at),
    website_sessions.created_at,
	website_sessions.utm_source,
    website_sessions.utm_campaign,
    http_referer,
    website_sessions.website_session_id,
	orders.order_id,
    Case 
		when website_sessions.utm_source = 'gsearch' and website_sessions.utm_campaign = 'nonbrand' then 'gsearch_nonbrand'
		when website_sessions.utm_source = 'bsearch' and website_sessions.utm_campaign = 'nonbrand' then 'bsearch_nonbrand'
        when website_sessions.utm_campaign = 'brand' then 'brand_search'
        when website_sessions.utm_source is null and website_sessions.http_referer is not null then 'organic_search'
        when website_sessions.utm_source is null and website_sessions.http_referer is null then 'direct_type_in'
	end as channel
From website_sessions left join orders 
	on website_sessions.website_session_id = orders.website_session_id
;

Select 
	year(created_at),
    quarter(created_at),
    Count(case when channel = 'gsearch_nonbrand' then order_id else null end)/ 
		Count(case when channel = 'gsearch_nonbrand' then website_session_id else null end) as gsearch_nonbrand_conversion_rt,
	Count(case when channel = 'bsearch_nonbrand' then order_id else null end)/ 
		Count(case when channel = 'bsearch_nonbrand' then website_session_id else null end) as bsearch_nonbrand_conversion_rt,
	Count(case when channel = 'brand_search' then order_id else null end)/ 
		Count(case when channel = 'brand_search' then website_session_id else null end) as brand_search_conversion_rt,
	Count(case when channel = 'organic_search' then order_id else null end)/ 
		Count(case when channel = 'organic_search' then website_session_id else null end) as organic_search_conversion_rt,
	Count(case when channel = 'direct_type_in' then order_id else null end)/ 
		Count(case when channel = 'direct_type_in' then website_session_id else null end) as direct_type_in_conversion_rt
From channel_orders 
Group by 1,2;



-- Question 5: We've come a long way since the day of selling a single product. Let's pull monthly trending revenue and margin by product,
-- along wirh a view of how conversion from /products to placing an order has improved



Select * from orders;
Select * from order_items;


-- pull monthly revenue and margin of each product
Select 

	year(created_at) as yr,
    month(created_at) as mo,
    Sum(Case when product_id = 1 then price_usd else null end) as product1_revenue,
    Sum(Case when product_id = 1 then price_usd else null end)- Sum(Case when product_id = 1 then cogs_usd else null end) as product1_margin,
    Sum(Case when product_id = 2 then price_usd else null end) as product2_revenue,
    Sum(Case when product_id = 2 then price_usd else null end)- Sum(Case when product_id = 2 then cogs_usd else null end) as product2_margin,
    Sum(Case when product_id = 3 then price_usd else null end) as product3_revenue,
    Sum(Case when product_id = 3 then price_usd else null end)- Sum(Case when product_id = 3 then cogs_usd else null end) as product3_margin,
    Sum(Case when product_id = 4 then price_usd else null end) as product4_revenue,
    Sum(Case when product_id = 4 then price_usd else null end)- Sum(Case when product_id = 4 then cogs_usd else null end) as product4_margin
From order_items   
Group by 1,2;
    
-- check if conversion from /products to placing an order has improved
select 
	year(website_pageviews.created_at),
    month(website_pageviews.created_at),
    Count(distinct website_pageviews.website_session_id) as sessions,
    Count(orders.order_id) as orders,
    Count(orders.order_id) / Count(distinct website_pageviews.website_session_id) as product_conversion_rate
From website_pageviews left join orders
	on website_pageviews.website_session_id = orders.website_session_id
	and website_pageviews.pageview_url = '/products' 
Group by 1,2
;



-- Question 6: Let's dive deeper into the impact of introducing new products. 
-- Please pull monthly sessions to the /product page, and shoe how the % of the session clicking through another page 
-- has changed over time, along with a view of how conversion from /products to placing and order has improved

-- Create temporary table product_page
Select 
	year(created_at) as yr,
    month(created_at) as mo,
    website_session_id,
    website_pageview_id
From website_pageviews
Where pageview_url= '/products';



Select 
	yr,
    mo,
    count(distinct product_page.website_session_id) as sessions_to_product_page,
    count(distinct website_pageviews.website_session_id) as clicked_to_next_page,
    count(distinct website_pageviews.website_session_id)/ count(distinct product_page.website_session_id) as click_through_rate,
	count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/ count(distinct product_page.website_session_id) as conversion_rate
From product_page 
	left join website_pageviews
		on product_page.website_session_id = website_pageviews.website_session_id
		and website_pageviews.website_pageview_id > product_page.website_pageview_id
	left join orders
	on website_pageviews.website_session_id = orders.website_session_id
Group by 1,2  ;  



-- Question 7: we made our 4th product available as a primary product on Dec 05, 2014(it was previously only a cross-sell item)
-- Could you please pull sales data since then, and show how well each product cross-sells from one another?
Select * from order_items;
select * from orders;
Create temporary table primary_table
Select
	order_id,
    primary_product_id,
    created_at as ordered_at
From orders
Where created_at > '2014-12-05';
    

Select 
	primary_table.*,
    order_items.product_id as cross_sell_product_id
    
From primary_table left join order_items
    on primary_table.order_id = order_items.order_id
    and order_items.is_primary_item = 0;
		
    
	
Select 
	 primary_product_id,
     count(distinct order_id) as total_orders,
     count(case when cross_sell_product_id = 1 then order_id else null end) as xsold_p1,
     count(case when cross_sell_product_id = 2 then order_id else null end) as xsold_p2,	
     count(case when cross_sell_product_id = 3 then order_id else null end) as xsold_p3,
     count(case when cross_sell_product_id = 4 then order_id else null end) as xsold_p4,
     count(case when cross_sell_product_id = 1 then order_id else null end)/ count(distinct order_id) as p1_xsellrate,
     count(case when cross_sell_product_id = 2 then order_id else null end)/ count(distinct order_id) as p1_xsellrate,
     count(case when cross_sell_product_id = 3 then order_id else null end)/ count(distinct order_id) as p1_xsellrate,
     count(case when cross_sell_product_id = 4 then order_id else null end)/ count(distinct order_id) as p1_xsellrate
from
(Select 
	primary_table.*,
    order_items.product_id as cross_sell_product_id
    
From primary_table left join order_items
    on primary_table.order_id = order_items.order_id
    and order_items.is_primary_item = 0
)as primary_w_cross_sell
Group by 1;


-- Question 8: In addition to telling investors aout what we've already achieved, 
-- let's show them thay we still have plenty of gas in the tank.
-- Based on all the analysis you've done, could you share some recommendation and opportunity for us going foward?


-- stable growth of sessions and orders, and the conversion rate also 
-- gsearch_nonbrand is our main traffic, while bsearch has the less performance, so bid up the gsearch_nonbrand more
-- product 4 cross sale the best compare to other product, therefore it's better to set it as a cross sales product 
-- product 1 still the best selling and margin product