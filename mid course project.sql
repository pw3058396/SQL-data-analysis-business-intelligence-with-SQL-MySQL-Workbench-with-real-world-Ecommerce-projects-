Use mavenfuzzyfactory;

Select distinct utm_campaign from website_sessions;

-- First Question: pull monthly trends for gsearch sessions and orders to showcase the growth
-- Step 1: Find the website_session_id, and order number limited with gsearch
-- Step 2: Calculate total sessions and orders by months
-- Drop temporary table sessions_order;
Create temporary table sessions_order
Select 
	website_sessions.website_session_id,
    website_sessions.created_at,
    orders.order_id
From website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.utm_source = 'gsearch'
	and website_sessions.created_at < '2012-11-27';
    
Select * from sessions_order;


Select 
	Month(created_at) as month,
	count(Distinct website_session_id) as sessions,
    count(Distinct order_id) as orders,
    count(Distinct order_id)/count(Distinct website_session_id) as session_to_order_rate
From sessions_order
Group by month(created_at);

-- Question 2: same as question 1, but split out nonbrand and brand campaigns seperately 

Select distinct utm_campaign from website_sessions;
Select 
	year(website_sessions.created_at) as year,
	Month(website_sessions.created_at) as month,
	count(Distinct case when website_sessions.utm_campaign = 'brand' then website_sessions.website_session_id else null end) as brand_sessions,
    count(Distinct case when website_sessions.utm_campaign = 'brand' then orders.order_id else null end ) as brand_orders,
    count(Distinct case when website_sessions.utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as nonbrand_sessions,
    count(Distinct case when website_sessions.utm_campaign = 'nonbrand' then orders.order_id else null end ) as nonbrand_orders
    -- count(Distinct sessions_order.order_id)/count(Distinct sessions_order.website_session_id) as session_to_order_rate
From website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.utm_source = 'gsearch'
	and website_sessions.created_at < '2012-11-27'
Group by  1,2 ;


-- Question 3: Pull monthly sessions and orders split by device type on gsearch nonbrand
select distinct device_type from website_sessions;
Select 
	Year(website_sessions.created_at) as year,
	Month(website_sessions.created_at) as month,
    count(Distinct case when website_sessions.device_type = 'mobile' then website_sessions.website_session_id else null end) as mobile_sessions,
    count(Distinct case when website_sessions.device_type = 'mobile' then orders.order_id else null end ) as mobile_orders,
    count(Distinct case when website_sessions.device_type = 'desktop' then website_sessions.website_session_id else null end) as desktop_sessions,
    count(Distinct case when website_sessions.device_type = 'desktop' then orders.order_id else null end ) as desktop_orders
From website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.utm_source = 'gsearch'
	and website_sessions.created_at < '2012-11-27'
    and website_sessions.utm_campaign = 'nonbrand'
Group by 1,2;


-- Question 4: One of the board member may be concerned about the larde % of traffic from gsearch,
-- pull monthly trend of gsearch, alongside monthly trend for each of out channels
-- Step 1 find the total session and gsearch session by months and device it

Select 
	month(website_sessions.created_at),
	Count(Distinct website_session_id) as total_sessions,
	Count(Case when utm_source = 'gsearch' then utm_source else null end) as gsearch_sessions,
    Count(Case when utm_source = 'gsearch' then utm_source else null end)
    /Count(Distinct website_session_id) as gsearch_rate
From website_sessions
Where website_sessions.created_at < '2012-11-27'
Group by month(website_sessions.created_at);

-- correct solution
Select distinct utm_source, utm_campaign, http_referer from website_sessions
Where website_sessions.created_at < '2012-11-27';

Select 
	year(website_sessions.created_at) as year,
    month(website_sessions.created_at) as month,
    Count(distinct case when utm_source = 'gsearch' then website_sessions.website_session_id else null end) as gsearch_paid_sessions,
	Count(distinct case when utm_source = 'bsearch' then website_sessions.website_session_id else null end) as bsearch_paid_session,
    Count(distinct case when utm_source is null and http_referer is not null then website_sessions.website_session_id else null end) as organic_searh_session,
    Count(distinct case when utm_source is null and http_referer is null then website_sessions.website_session_id else null end) as direc_type_in_session
From website_sessions
Where website_sessions.created_at < '2012-11-27'
Group by 1,2;

-- Question 5: find the session to order conversion rates by month for the first 8 months

Create temporary table sessions_to_order
Select 
	website_sessions.website_session_id,
    website_sessions.created_at,
    orders.order_id
From website_sessions left join orders
	on website_sessions.website_session_id = orders.website_session_id
Where website_sessions.created_at < '2012-11-27';
    
Select * from sessions_order;


Select 
	Month(created_at) as month,
	count(Distinct website_session_id) as sessions,
    count(Distinct order_id) as orders,
    count(Distinct order_id)/count(Distinct website_session_id) as session_to_order_rate
From sessions_order
Group by month(created_at);

-- Question 6: For the gsearch lander test, please estimate the revenue that test earned us 
-- (Hint: Look at the increase in CVR from the test(Jun 19- Jun 28), and use nonbrand sessions and revenue since then
-- to calculate incremental value)
Select * from orders;

Select 
	date(w.created_at) as test_date,
	Count(distinct w.website_session_id) as sessions,
    Count(distinct o.order_id) as orders,
    Count(distinct o.order_id)/ Count(distinct w.website_session_id) as sessions_to_order_CVR,
    sum(o.price_usd)/ sum(o.items_purchased) as AOV,
	(sum(o.price_usd)/ sum(o.items_purchased)) / (Count(distinct o.order_id)/ Count(distinct w.website_session_id)) as incremental_value
From website_sessions as w
		left join orders as o
        on w.website_session_id = o.website_session_id
Where w.utm_source = 'gsearch'
	and w.utm_campaign = 'nonbrand'
	and Date(w.created_at) between '2012-06-19' and '2012-07-28'
Group by test_date;

-- correct solution

Select 
	Min(website_pageview_id) as first_test_pv
From website_pageviews
Where pageview_url = '/lander-1';

-- For this stop, we'll find the first pageview id
Create temporary table first_page_view
Select 
	website_pageviews.pageview_url as landing_page,
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as min_pageview_id
From website_pageviews
	inner join website_sessions
		on website_sessions.website_session_id = website_pageviews.website_session_id
        and website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
        and website_pageviews.website_pageview_id > 23504 -- First page view
        and utm_source = 'gsearch'
        and utm_campaign = 'nonbrand'
	Group by website_pageviews.website_session_id;

 Select 
	first_page_view.landing_page,
	Count(distinct first_page_view.website_session_id) as sessions,
    Count(distinct orders.order_id) as order_id,
    Count(distinct orders.order_id) /Count(distinct first_page_view.website_session_id)
 From first_page_view left join orders
	on first_page_view.website_session_id = orders.website_session_id
Group by 1;

-- 0.0318 for /home, 0.0406 for /lander-1
-- 0.0086 additional orders per session

Select
	max(website_sessions.website_session_id) as most_recent_nonbrand_hine_pageview
From website_sessions
	Left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
Where utm_source = 'gsearch'	
	and utm_campaign = 'nonbrand'
    and pageview_url = 'hone'
    and website_sessions.created_at < '2012-11-27';
-- max website session_id = 17145


Select 
	count(distinct website_sessions.website_session_id),
    count(distinct website_sessions.website_session_id)*0.0086 as incremental_orders 
From website_sessions
Where Created_at < '2012-11-27'
	and website_session_id > 17145
    and utm_source = 'gsearch'
    and utm_campaign = 'nonbrand';
-- 22972 website session since the test
-- X*0.087 incremental conversion 202 incremental orders since 7/29
		-- roghly 4 months, so roughly 50 extra orders per month



-- Question 7: For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each of the 
-- two pages to orders. You can use the same time period you analyze last time


Select distinct website_pageviews.pageview_url from website_pageviews
	left join website_sessions
	on website_sessions.website_session_id = website_pageviews.website_session_id
Where website_sessions.utm_source = 'gsearch'
	and website_sessions.utm_campaign = 'nonbrand'
	and Date(website_sessions.created_at) between '2012-06-19' and '2012-06-28';
    
    
Select 
	website_pageviews.pageview_url,
    website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id)
From website_sessions left join website_pageviews		
	on website_sessions.website_session_id = website_pageviews.website_session_id
Where website_sessions.utm_source = 'gsearch'
	and website_sessions.utm_campaign = 'nonbrand'
	and Date(website_sessions.created_at) between '2012-06-19' and '2012-07-28'
	Group by  website_pageviews.website_session_id;
    
-- Create temporary table to_website
Select 
	Case 
		when website_pageviews.pageview_url = '/home' then 'home_page'
		when website_pageviews.pageview_url = '/lander-1' then 'lander-1_page'
        else 'check logic'
	End as segmant,
	Count(distinct website_pageviews.website_session_id) as total_sessions,
    Count(distinct case when website_pageviews.pageview_url = '/products' then website_pageviews.website_session_id else null end) as to_product,
    Count(distinct case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then website_pageviews.website_session_id else null end) as to_fuzzy,
    Count(distinct case when website_pageviews.pageview_url = '/cart' then website_pageviews.website_session_id else null end) as to_cart,
    Count(distinct case when website_pageviews.pageview_url = '/shipping' then website_pageviews.website_session_id else null end) as to_shipping,
    Count(distinct case when website_pageviews.pageview_url = '/billing' then website_pageviews.website_session_id else null end) as to_billing,
    Count(distinct case when website_pageviews.pageview_url = '/thank-you-for-your-order' then website_pageviews.website_session_id else null end) as to_thankyou
From website_sessions left join website_pageviews		
	on website_sessions.website_session_id = website_pageviews.website_session_id
Where website_sessions.utm_source = 'gsearch'
	and website_sessions.utm_campaign = 'nonbrand'
	and Date(website_sessions.created_at) between '2012-06-19' and '2012-07-28'
Group by website_pageviews.website_session_id;
-- Having website_pageviews.pageview_url in ('/home', '/lander-1');

Select * from to_website;

Select 
	to_product/total_sessions as to_product_rate,
    to_fuzzy/ to_product as to_fuzzy_rate,
    to_cart/to_fuzzy as to_cart_rate,
    to_shipping/ to_cart as to_shipping_rate,
    to_billing/ to_shipping as to_billing_rate,
    to_thankyou/ to_billing as to_thankyou_rate
From to_website;

-- correct solution
Select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    Case when website_pageviews.pageview_url = '/home' then 1 else 0 end as homepage,
    Case when website_pageviews.pageview_url = '/lander-1' then 1 else 0 end as customer_lander,
	Case when website_pageviews.pageview_url = '/products' then 1 else 0 end as product_page,
	Case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
	Case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_page,
	Case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
	Case when website_pageviews.pageview_url = '/billing' then 1 else 0 end as billing_page,
	Case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
From website_sessions 
	left join website_pageviews
		on website_sessions.website_session_id = website_sessions.website_session_id
Where website_sessions.utm_source = 'gsearch'
	and website_sessions.utm_campaign = 'nonbrand'
	and website_sessions.created_at >'2012-06-19' 
    and website_sessions.created_at <'2012-07-28';

Create temporary table session_level_made_it_flagged
Select    
	website_session_id,
    Max(homepage) as saw_homepage,
    Max(customer_lander) as saw_customer_lander,
    Max(product_page) as saw_product_page,
    Max(mrfuzzy_page) as saw_mrfuzzy_page,
    Max(cart_page) as saw_cart_page,
    Max(shipping_page) as saw_shipping_page,
	Max(billing_page) as saw_billing_page,
	Max(thankyou_page) as saw_thankyou_page
From (
Select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    Case when website_pageviews.pageview_url = '/home' then 1 else 0 end as homepage,
    Case when website_pageviews.pageview_url = '/lander-1' then 1 else 0 end as customer_lander,
	Case when website_pageviews.pageview_url = '/products' then 1 else 0 end as product_page,
	Case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
	Case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_page,
	Case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
	Case when website_pageviews.pageview_url = '/billing' then 1 else 0 end as billing_page,
	Case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
From website_sessions 
	left join website_pageviews
		on website_sessions.website_session_id = website_sessions.website_session_id
Where website_sessions.utm_source = 'gsearch'
	and website_sessions.utm_campaign = 'nonbrand'
    and website_sessions.created_at <'2012-07-28'
	and website_sessions.created_at >'2012-06-19' 
Order by 
	website_sessions.website_session_id,
    website_pageviews.created_at
    ) as pageview_level
Group by website_session_id;

Select 
	Case 
		When saw_homepage = 1 then 'saw_hompage'
        when saw_customer_lander = 1 then 'saw_customer_lander'
		Else 'uh oh... check logic'
	End AS segment,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN saw_product_page = 1 then website_session_id ELSE NULL END) as to_product,
    COUNT(DISTINCT CASE WHEN saw_mrfuzzy_page = 1 then website_session_id ELSE NULL END) as to_fuzzy,
	COUNT(DISTINCT CASE WHEN saw_cart_page = 1 then website_session_id ELSE NULL END) as to_cart,
    COUNT(DISTINCT CASE WHEN saw_shipping_page = 1 then website_session_id ELSE NULL END) as to_shipping,
    COUNT(DISTINCT CASE WHEN saw_billing_page = 1 then website_session_id ELSE NULL END) as to_billing,
    COUNT(DISTINCT CASE WHEN saw_thankyou_page = 1 then website_session_id ELSE NULL END) as to_thankyou
From session_level_made_it_flagged
Group by 1
    
Select
	Case 
		When saw_homepage = 1 then 'saw_hompage'
        when saw_customer_lander = 1 then 'saw_customer_lander'
		Else 'uh oh... check logic'
	End AS segment,
   COUNT(DISTINCT CASE WHEN saw_product_page = 1 then website_session_id ELSE NULL END)/  COUNT(DISTINCT website_session_id) as lander_click_rate,
   COUNT(DISTINCT CASE WHEN saw_mrfuzzy_page = 1 then website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN saw_product_page = 1 then website_session_id ELSE NULL END) as product_click_rate,
   COUNT(DISTINCT CASE WHEN saw_cart_page = 1 then website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN saw_mrfuzzy_page = 1 then website_session_id ELSE NULL END) as mrfuzzy_click_rate,
   COUNT(DISTINCT CASE WHEN saw_shipping_page = 1 then website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN saw_cart_page = 1 then website_session_id ELSE NULL END) as cart_click_rate,
   COUNT(DISTINCT CASE WHEN saw_billing_page = 1 then website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN saw_shipping_page = 1 then website_session_id ELSE NULL END) as shipping_click_rate,
   COUNT(DISTINCT CASE WHEN saw_thankyou_page = 1 then website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN saw_billing_page = 1 then website_session_id ELSE NULL END) as billimh_click_rate
From session_level_made_it_flagged
Group by 1;
    
-- Question 8: I'd love for you to quantify the impact of our billing test, as well. 
-- Please analyze the lift generated from the test (Sep10-Nov10), 
-- in terms of revenue per billing page session, 
-- and then pull the number of billing page sessions for the past month to understand monthly impact.

-- Step 1 find the total revenue and total page sessions

Select * from orders;


Select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen,
    orders.order_id,
    orders.price_usd
From website_pageviews left join orders
on website_pageviews.website_session_id = orders.website_session_id 
Where website_pageviews.created_at between '2012-09-10' and '2012-11-10'
	and website_pageviews.pageview_url in ('/billing', '/billing-2');

Select
	billing_version_seen,
    Count(Distinct website_session_id) as sessions,
    SUM(price_usd)/Count(Distinct website_session_id) as revenuew_per_billing_page_seen
From(
Select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen,
    orders.order_id,
    orders.price_usd
From website_pageviews left join orders
on website_pageviews.website_session_id = orders.website_session_id 
Where website_pageviews.created_at between '2012-09-10' and '2012-11-10'
	and website_pageviews.pageview_url in ('/billing', '/billing-2')
) as billinh_pageview_and_order_data
Group by 1
;
-- $22.83 revenue per billing page seen for the old version
-- 31.34 for the new version
-- lift $8.51

Select
	Count(website_session_id) as billing_sessions_past_month
    From website_pageviews
    Where website_pageviews.created_at between '2012-10-27' and '2012-11-27'
	and website_pageviews.pageview_url in ('/billing', '/billing-2');
    
-- 1194 billing sessions past month
-- Lift $8.51 per billing session
-- Value of billing test: $10160 over the past month