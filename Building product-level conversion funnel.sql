-- analyze the conversion funnel from each product page to conversion
-- produce a comparison betwenn the two conversion funnel, for all website traffic
Use mavenfuzzyfactory;

Select distinct pageview_url from website_pageviews;

-- Step 1 Find every website_session_id that click in each product page
Create temporary table product_page_sessions
Select 
	website_session_id,
    website_pageview_id,
    case when pageview_url = '/the-original-mr-fuzzy' then 'mrfuzzy'
		when pageview_url = '/the-forever-love-bear' then 'lovebear'
        else null
        end as product_seen
From website_pageviews
Where created_at between '2013-01-06' and '2013-04-10'
	and pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear')
;

-- Step 2: Find distinct pageviewid and url under the same website_session and click after product page
Select distinct
	website_pageviews.pageview_url
From product_page_sessions left join website_pageviews
	on product_page_sessions.website_session_id = website_pageviews.website_session_id
Where website_pageviews. website_pageview_id > product_page_sessions.website_pageview_id;

-- Step 3: flag the pageviewid under the same website_session and click after product page
Select 
	product_page_sessions.website_session_id,
    website_pageviews.website_pageview_id,
    website_pageviews.pageview_url,
    case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as to_cart,
    case when website_pageviews.pageview_url = '/the-forever-love-bear' then 1 else 0 end as to_cart,
    case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as to_cart,
	case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as to_shipping,
    case when website_pageviews.pageview_url = '/billing-2' then 1 else 0 end as to_billing,
	case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as to_thankyou
    
From product_page_sessions left join website_pageviews
	on product_page_sessions.website_session_id = website_pageviews.website_session_id
Where website_pageviews. website_pageview_id > product_page_sessions.website_pageview_id;
;


-- Step 4: make the table website_session_id level
Create temporary table pageview_after_product
Select
	website_session_id,
    max(to_cart) as to_cart,
    max(to_shipping) as to_shipping,
    max(to_billing) as to_billing,
	max(to_thankyou) as to_thankyou
From 
(Select 
	product_page_sessions.website_session_id,
    website_pageviews.website_pageview_id,
    website_pageviews.pageview_url,
    case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as to_cart,
	case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as to_shipping,
    case when website_pageviews.pageview_url = '/billing-2' then 1 else 0 end as to_billing,
	case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as to_thankyou
    
From product_page_sessions left join website_pageviews
	on product_page_sessions.website_session_id = website_pageviews.website_session_id
Where website_pageviews. website_pageview_id > product_page_sessions.website_pageview_id
)as pageview_of_sessions
Group by 1
;



-- Step 5: find total amount of each page view, segmant with two product_page
Select 
	product_page_sessions.product_seen,
	count(distinct product_page_sessions.website_session_id) as sessions,
    count(distinct case when pageview_after_product.to_cart = 1 then pageview_after_product.website_session_id else null end) as to_cart,
	count(distinct case when pageview_after_product.to_shipping = 1 then pageview_after_product.website_session_id else null end) as to_shipping,
	count(distinct case when pageview_after_product.to_billing = 1 then pageview_after_product.website_session_id else null end) as to_billing,
	count(distinct case when pageview_after_product.to_thankyou = 1 then pageview_after_product.website_session_id else null end) as to_thankyou

From product_page_sessions left join pageview_after_product
	on pageview_after_product.website_session_id = product_page_sessions.website_session_id
Group by 1;


-- Step 6:  Find the amount of sessions for each page
Select 
	product_page_sessions.product_seen,
	count(distinct case when pageview_after_product.to_cart = 1 then pageview_after_product.website_session_id else null end)/
		count(distinct product_page_sessions.website_session_id) as product_page_click_rt,
	count(distinct case when pageview_after_product.to_shipping = 1 then pageview_after_product.website_session_id else null end)/
		count(distinct case when pageview_after_product.to_cart = 1 then pageview_after_product.website_session_id else null end) as cart_click_rt,
	count(distinct case when pageview_after_product.to_billing = 1 then pageview_after_product.website_session_id else null end)/
		count(distinct case when pageview_after_product.to_shipping = 1 then pageview_after_product.website_session_id else null end) as shipping_click_rt,
	count(distinct case when pageview_after_product.to_thankyou = 1 then pageview_after_product.website_session_id else null end)/
		count(distinct case when pageview_after_product.to_billing = 1 then pageview_after_product.website_session_id else null end) as billing_click_rt

From product_page_sessions left join pageview_after_product
	on pageview_after_product.website_session_id = product_page_sessions.website_session_id
Group by 1;