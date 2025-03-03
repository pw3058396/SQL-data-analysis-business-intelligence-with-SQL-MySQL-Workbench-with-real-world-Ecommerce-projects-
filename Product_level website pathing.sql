-- Look at sessions which hit the /product page and see where they went next.
-- pull clickthrough rates from /products since the new product launch on January 6 2013 by product, 
-- and compare to the 3 months leading up to launch a baseline

 Use mavenfuzzyfactory;
-- Step 1: find the relevant/ products pageviews with website_session_id
-- Step 2: find the next pageview id that occurs AFTER the product pageview
-- Step 3: find the pageview_url associated with any applicable next pageview id
-- Step 4: summarize the data and analyze the pre vs post period



-- Step 1: find the relevant/ products pageviews with website_session_id
-- Create temporary table product_pageviews
Select 
	website_session_id, 
    website_pageview_id,
    created_at,
    Case when created_at between '2012-10-6' and '2013-01-06' then 'A. Pre_Product_2'
		when created_at between '2012-01-06' and '2013-04-06' then 'B. Post_Product_2'
		Else 'check logic'  
		end as time_period
From website_pageviews
Where created_at < '2013-04-06' -- date of request
	and created_at > '2012-10-6' -- start of 3 mo before product 2 launch
    and pageview_url = '/products';
    
-- Step 2: find the next pageview id that occurs AFTER the product pageview    
-- Create temporary table session_w_next_pageview_id
Select 
	product_pageviews.time_period,
    product_pageviews.website_session_id,
    Min(website_pageviews.website_pageview_id) as min_next_pageview_id
From product_pageviews
	left join website_pageviews
		on website_pageviews.website_session_id = product_pageviews.website_session_id
        and website_pageviews.website_pageview_id > product_pageviews.website_pageview_id
Group by 1,2
;

Select * from session_w_next_pageview_id;
-- just to show the distinct next pageview urls


-- Step 3: find the pageview_url associated with any applicable pageview id
-- create temporary table sessions_w_next_pageview_url
Select 
	session_w_next_pageview_id.time_period,
    session_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url as next_page_view_url
From session_w_next_pageview_id left join website_pageviews
	on session_w_next_pageview_id.min_next_pageview_id = website_pageviews.website_pageview_id;
    
-- Step 4: summarize the data and analyze the pre vs post period
Select
	time_period,
    Count(distinct website_session_id) as sessions,
    Count(Distinct Case when next_page_view_url is not null then website_session_id else null end) as w_next_pg,
    Count(Distinct Case when next_page_view_url is not null then website_session_id else null end)
		/ Count(distinct website_session_id) as pct_w_next_pg,
    Count(Distinct Case when next_page_view_url ='/the-original-mr-fuzzy' then website_session_id else null end) as to_mrfuzzy,
    Count(Distinct Case when next_page_view_url ='/the-original-mr-fuzzy' then website_session_id else null end)
		/Count(distinct website_session_id) as pct_to_mrfuzzy,
	 Count(Distinct Case when next_page_view_url ='/the-forever-love-bear' then website_session_id else null end) as to_lovebear,
     Count(Distinct Case when next_page_view_url ='/the-forever-love-bear' then website_session_id else null end)
		/Count(distinct website_session_id) as pct_to_lovebear
From sessions_w_next_pageview_url
Group by 1;
		