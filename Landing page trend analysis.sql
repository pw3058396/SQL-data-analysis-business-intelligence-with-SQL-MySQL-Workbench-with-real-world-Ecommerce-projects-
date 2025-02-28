-- Pull the volume of paid search nonbrand traffic landing on /home and /lander-1, trended weekly since June 1st?
-- and pull the overall paid search bounce rate trended weekly




-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identify the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing total sessions and bounced sessions, by landing page

Select * from website_sessions;

-- Drop temporary table First_click, bounce_click;
-- Create table of first click url, session_id, pageview_id
Create temporary table First_click
Select 
	website_pageviews.pageview_url,
    website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id),
    website_pageviews.created_at
From website_pageviews inner join website_sessions
	on website_pageviews.website_session_id = website_sessions.website_session_id
	and website_pageviews.created_at > '2012-06-01' 
	and website_pageviews.created_at < '2012-08-31' 
    and website_pageviews.pageview_url in ('/home', '/lander-1') 
    and website_sessions.utm_campaign = 'nonbrand'
Group by 1, 2,4;


-- Create table url, session_id which have bounce click
Create temporary table bounce_click
Select 
	first_click.pageview_url as bounce_url,
    first_click.website_session_id as bounce_session_id,
    count(website_pageviews.website_pageview_id) as bounce_pv
From First_click 
	left join website_pageviews
		on First_click.website_session_id = website_pageviews.website_session_id
Group by 1, 2
having bounce_pv = 1 ;


Select * from bounce_click ;


-- 
Select 
		Min(date(First_click.created_at)) as week_start_date,
        count(distinct bounce_click.bounce_session_id)/count(distinct First_click.website_session_id) as bounce_rate,
        count(case when First_click.pageview_url = '/home' then First_click.website_session_id else null end ) as home_sessions,
        count(case when First_click.pageview_url = '/lander-1' then First_click.website_session_id else null end ) as lander_sessions
From  First_click left join  bounce_click
	on First_click.website_session_id = bounce_click.bounce_session_id
Group by week(First_click.created_at)

