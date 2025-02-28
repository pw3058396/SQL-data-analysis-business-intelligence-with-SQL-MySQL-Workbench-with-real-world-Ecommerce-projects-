-- We ran a new custom landing page(/lander-1) in a 50/50 test against the homepage(/home) for our gsearch nonbrand traffic.
-- Pull bounce rate for two group so we can evaluate the new page, 
-- make sure look at the time period where /lander-1 get traffic


-- find the first pageview_id and relevant session_id, that only used for /lander -1

-- Find the timeline that the website /lander-1 first launch for test
Select 
	Min(created_at),
    Min(website_session_id)
From website_pageviews 
Where created_at < '2012-07-28' and pageview_url = '/lander-1';
-- /lander-1 created time: 2012-06-19 00:35:54
-- /lander-1 first session id: 11683

-- Create table for the first click in this time period
Create temporary table first_page_open
Select 
	website_pageviews.pageview_url,
	website_pageviews.website_session_id,
    min(website_pageview_id)
From website_pageviews Inner join website_sessions
	on website_pageviews.website_session_id = website_sessions.website_session_id
	and website_pageviews.created_at < '2012-07-28' 
	and website_pageviews.created_at > '2012-06-19' 
    and website_pageviews.website_session_id > 11683
    and website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
Group by 1, 2;


Select * from first_page_open;

-- Find the bounce session_id;
Create temporary table page_bounce
Select 
	first_page_open.pageview_url as bounce_url,
    first_page_open.website_session_id as bounce_session_id,
    count(website_pageviews.website_pageview_id) as bounce_pageview_id
From first_page_open
	left join website_pageviews
		on first_page_open.website_session_id = website_pageviews.website_session_id
Group by bounce_session_id, first_page_open.pageview_url
Having bounce_pageview_id = 1;


select * 
From page_bounce;

-- calculate the bounce rate
Select 
	first_page_open.pageview_url,
	Count(distinct first_page_open.website_session_id) as total_sessions,
    Count(distinct page_bounce.bounce_session_id) as bounce_sessions,
    Count(distinct page_bounce.bounce_session_id)/ Count(distinct first_page_open.website_session_id) as bounce_rate
From first_page_open 
	left join page_bounce
		on first_page_open.website_session_id = page_bounce.bounce_session_id
Group by first_page_open.pageview_url
Having first_page_open.pageview_url = '/lander-1' or first_page_open.pageview_url = '/home'
	
	