-- take a look and see whether /billing-2 is doing any better than original /billing page
-- we wondering what % of sessions on those pages end up placing order, 
-- FYI we ran this test for all traffic, not just for our search visitor


-- Step 1: Select alll pageviews for relevant sessions
-- Step 2: Identify each pageview as the specific funnel step
-- Step 3: create the session-level conversion funnel view
-- Step 4: aggregat the data to assess funnel performance

-- Find the date that /billing-2 is launched
Select 
	pageview_url,
	Min(created_at) as first_created_at,
    website_pageview_id as first_page_view
From website_pageviews 
Where pageview_url = '/billing-2';
-- first page_view_id is 53550



Select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
From Website_pageviews
	left join orders
    on Website_pageviews.website_session_id = orders.website_session_id
Where website_pageviews.website_pageview_id >= 53550 -- first pageview_id where the test start
	and website_pageviews.created_at < '2012-11-10' -- time for assignment
    and website_pageviews.pageview_url in ('/billing','/billing-2');

Select 
	billing_version_seen,
    count(website_session_id) as sessions,
    count(order_id) as orders,
	count(order_id) / count(website_session_id) as billing_to_order_rtcount
From (
	Select 
		website_pageviews.website_session_id,
		website_pageviews.pageview_url AS billing_version_seen,
		orders.order_id
	From Website_pageviews
		left join orders
		on Website_pageviews.website_session_id = orders.website_session_id
	Where website_pageviews.website_pageview_id >= 53550 -- first pageview_id where the test start
		and website_pageviews.created_at < '2012-11-10' -- time for assignment
		and website_pageviews.pageview_url in ('/billing','/billing-2')
	) as page_version_order
    
Group by billing_version_seen;
    