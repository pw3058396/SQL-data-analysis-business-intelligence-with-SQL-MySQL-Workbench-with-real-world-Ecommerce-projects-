-- pull a list of top entry pages, and rank them on entry volume

USE mavenfuzzyfactory;

-- Drop temporary table Entry_page;

Create temporary table Entry_page
Select 
	pageview_url as landing_page_url,
	website_session_id,
    Min(website_pageview_id) as first_pv_id
From website_pageviews
where created_at < '2012-06-12'
Group by 1,2;


Select * 
From  Entry_page;

Select 
	landing_page_url,
    Count(distinct website_session_id)
From Entry_page
Group by landing_page_url;
