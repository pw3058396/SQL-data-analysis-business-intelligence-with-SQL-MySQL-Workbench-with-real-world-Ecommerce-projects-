-- help understand where the bulk of our website sessions are coming from, 
-- break dwon by UTM source, campaign and refering domain 

USE mavenfuzzyfactory;

Select Distinct 
	utm_source,
    utm_campaign,
    http_referer,
    count(Distinct website_session_id)  as number_of_sessions
From website_sessions
Where created_at <'2012-04-12'
GROUP BY utm_source, utm_campaign ,http_referer
Order by count(Distinct website_session_id) DESC;