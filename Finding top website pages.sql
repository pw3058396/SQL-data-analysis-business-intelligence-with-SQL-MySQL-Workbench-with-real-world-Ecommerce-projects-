-- please pull the most viewed website pages, rank by session volume

Select 
	pageview_url,
    count(distinct website_session_id) as sessions
From website_pageviews 
Where created_at < '2012-06-09'
GROUP BY 1
Order by 2 DESC;