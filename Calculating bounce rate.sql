-- Can younced sessions, and % of ou pull bounce rate for traffic landing on the homepage? 
-- I would like to see three numbers... sessions, bounce sessions, and % of sessions which bounced( bounce rate) 


-- Business Context: we want to see landing page performance for a certain time period

-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identify the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing total sessions and bounced sessions, by landing page

-- Drop temporary table first_page;

-- find the first pageview_id of every session_id, and the url
USE mavenfuzzyfactory;

create temporary table first_page
Select 
	website_session_id,
    min(website_pageview_id) as first_pageview,
    pageview_url
From website_pageviews
where created_at < '2012-6-14'
group by website_session_id, pageview_url;
 
Select *
From first_page;
    

-- Find every bouced session that only view one page 
create temporary table bouce_session_table  
Select 
	first_page.website_session_id as bounce_session_id,
    first_page.pageview_url as bounce_url,
	count(distinct website_pageviews.website_pageview_id) as page_view_count
From first_page left join website_pageviews
on first_page.website_session_id = website_pageviews.website_session_id
Group by
	bounce_session_id, 
    bounce_url
Having page_view_count = 1;


Select *
From bouce_session_table  ;

Select 
	first_page.website_session_id,
    bouce_session_table.bounce_session_id
From first_page 
	left join bouce_session_table
		on first_page.website_session_id = bouce_session_table.bounce_session_id;
	

Select 
    Count(distinct first_page.website_session_id) as sessions,
    Count(distinct bouce_session_table.bounce_session_id) as bounced_sessions,
    Count(distinct bouce_session_table.bounce_session_id)/ Count(distinct first_page.website_session_id) as bounce_rate
From first_page 
	left join bouce_session_table
		on first_page.website_session_id = bouce_session_table.bounce_session_id;
    