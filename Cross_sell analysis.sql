 -- On September 25th start to add a 2nd product while on the /cart page.
 -- Please compare the month before vs the month after the change? I'd like to see CTR from the /cart page,
 -- Avg products per order, AOV, and overall revenue per /cart page view
 
Use mavenfuzzyfactory;

 Select * from orders;
 

 -- Step 1: Find cart all session
Create temporary table cart_session
 Select 
	website_session_id,
    website_pageview_id,
    pageview_url,
    created_at
From website_pageviews
Where created_at > '2013-08-25'
	and created_at < '2013-10-25'
	and pageview_url = '/cart';
    
    
-- Step 2: Find the click through page session    
Select 
	cart_session.created_at,
	cart_session.website_session_id,
    cart_session.website_pageview_id,
    case when website_pageviews.website_pageview_id is not null then 1 else 0 end as click_through_pageview,
    website_pageviews.pageview_url
    
From cart_session left join website_pageviews
	on cart_session.website_session_id = website_pageviews.website_session_id
	and website_pageviews.website_pageview_id > cart_session.website_pageview_id
;


-- Step 3: make the table session level
-- Create temporary table click_through_table
Select 
	created_at,
	website_session_id,
    max(click_through_pageview) as click_through_pageview
From 
(Select 
	cart_session.created_at,
	cart_session.website_session_id,
    cart_session.website_pageview_id,
    case when website_pageviews.website_pageview_id is not null then 1 else 0 end as click_through_pageview,
    website_pageviews.pageview_url
    
From cart_session left join website_pageviews
	on cart_session.website_session_id = website_pageviews.website_session_id
	and website_pageviews.website_pageview_id > cart_session.website_pageview_id
) as click_next
Group by 1,2
;




-- Step 4 left join with orders and calculate the data needed
Select
Case 
	when click_through_table.created_at <'2013-09-25' then 'A. Pre_Cross_Sell'
	when click_through_table.created_at >='2013-09-25' then 'B. Post_Cross_Sell'
	end as time_period,
Count(Distinct click_through_table.website_session_id) as case_sessions,
Count(case when click_through_table.click_through_pageview= 1 then click_through_table.website_session_id else null end) as clickthroughs,
Count(case when click_through_table.click_through_pageview= 1 then click_through_table.website_session_id else null end)/ Count(Distinct click_through_table.website_session_id) as cart_ctr,
Sum(orders.items_purchased)/count(orders.order_id) as product_per_order,
Sum(orders.price_usd)/count(orders.order_id) as aov,
Sum(orders.price_usd)/Count(Distinct click_through_table.website_session_id) as rev_per_cart_session
From click_through_table left join orders
	on click_through_table.website_session_id = orders.website_session_id
Group by 1
;










