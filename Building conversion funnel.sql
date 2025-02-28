-- Build us a full conversion funnal, analyzing how many customer make it to each step?
-- Start with /lander-1 and build the finnel all the way to our thank you page and use date since Aug 15



-- Step 1: Select alll pageviews for relevant sessions
-- Step 2: Identify each pageview as the specific funnel step
-- Step 3: create the session-level conversion funnel view
-- Step 4: aggregat the data to assess funnel performance

-- Find every distinct url 
Select distinct website_pageviews.pageview_url
From  website_pageviews inner join website_sessions
	on website_pageviews.website_session_id = website_sessions.website_session_id
	and website_pageviews.created_at > '2012-08-05'
    and website_pageviews.created_at < '2012-09-05'
    and website_sessions.utm_source = 'gsearch';
    
    
Select 
	website_pageviews.pageview_url,
    website_pageviews.website_session_id,
    website_pageviews.created_at,
    case when website_pageviews.pageview_url = '/lander-1' then 1 else 0 end as lander_flag,
    case when website_pageviews.pageview_url = '/products' then 1 else 0 end as products_flag,
    case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as the_original_mr_fuzzy_flag,
    case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_flag,
    case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_flag,
    case when website_pageviews.pageview_url = '/billing' then 1 else 0 end as billing_flag,
	case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you_flag
From  website_pageviews inner join website_sessions
	on website_pageviews.website_session_id = website_sessions.website_session_id
	and website_pageviews.created_at > '2012-08-05'
    and website_pageviews.created_at < '2012-09-05'
    and website_sessions.utm_source = 'gsearch';


Create temporary table page_landing_record
Select
	website_session_id,
    max(lander_flag) as lander_made,
    max(products_flag) as product_made,
    max(the_original_mr_fuzzy_flag) as mr_fuzzy_made,
	max(cart_flag) as cart_made,
	max(shipping_flag) as shipping_made,
	max(billing_flag) as billing_made,
    max(thank_you_flag) as thank_you_made
From(
	Select 
	website_pageviews.pageview_url,
    website_pageviews.website_session_id,
    website_pageviews.created_at,
    case when website_pageviews.pageview_url = '/lander-1' then 1 else 0 end as lander_flag,
    case when website_pageviews.pageview_url = '/products' then 1 else 0 end as products_flag,
    case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as the_original_mr_fuzzy_flag,
    case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_flag,
    case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_flag,
    case when website_pageviews.pageview_url = '/billing' then 1 else 0 end as billing_flag,
	case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you_flag
From  website_pageviews inner join website_sessions
	on website_pageviews.website_session_id = website_sessions.website_session_id
	and website_pageviews.created_at > '2012-08-05'
    and website_pageviews.created_at < '2012-09-05'
    and website_sessions.utm_source = 'gsearch') as pageview_level
Group by website_session_id;

Select * from page_landing_record;

Select 
    count(case when lander_made =1 then 1 else null end) as to_session,
    count(case when product_made = 1  then 1 else null end) as to_product,
    count(case when mr_fuzzy_made = 1 then 1 else null end) as to_myfuzzy,
    count(case when cart_made = 1 then 1 else null end) as to_cart,
    count(case when shipping_made = 1 then 1 else null end) as to_shipping,
    count(case when billing_made = 1 then 1 else null end) as to_billing,
    count(case when thank_you_made = 1 then 1 else null end) as to_thankyou
From page_landing_record;

Select 
	to_product/ to_session as lander_click_rate,
    to_myfuzzy/ to_product as product_click_rate,
    to_cart/ to_myfuzzy as myfuzzy_click_rate,
    to_shipping/ to_cart as cart_click_rate,
    to_billing/ to_shipping as shipping_click_rate,
    to_thankyou/ to_billing as billing_click_rate
From ( Select 
    count(case when lander_made =1 then 1 else null end) as to_session,
    count(case when product_made = 1  then 1 else null end) as to_product,
    count(case when mr_fuzzy_made = 1 then 1 else null end) as to_myfuzzy,
    count(case when cart_made = 1 then 1 else null end) as to_cart,
    count(case when shipping_made = 1 then 1 else null end) as to_shipping,
    count(case when billing_made = 1 then 1 else null end) as to_billing,
    count(case when thank_you_made = 1 then 1 else null end) as to_thankyou
From page_landing_record) as to_website;

	
