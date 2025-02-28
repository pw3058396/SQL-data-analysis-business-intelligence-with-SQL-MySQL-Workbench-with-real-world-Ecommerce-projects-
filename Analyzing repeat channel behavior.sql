-- Comparing new vs. repeat sessions by channel

Select *
From website_sessions
where created_at >= '2014-01-01'
	and created_at < '2014-11-05'
;

-- Step 1: Find the each channel type  and sessions
Select 
	utm_source,
    utm_campaign,
    http_referer,
    count( case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
    count( case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
From website_sessions    
where created_at >= '2014-01-01'
	and created_at < '2014-11-05'
Group by 1,2,3
;

Select
	Case 
		When utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic search'
        When utm_campaign = 'nonbrand' then 'paid_nonbrand'
        When utm_campaign = 'brand' then 'paid_brand'
        When utm_source is null and http_referer is null then 'direct_type_in'
        when utm_source = 'socialbook' then 'paid_social'
	End as channel_group,
	count( case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
    count( case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
From website_sessions    
where created_at >= '2014-01-01'
	and created_at < '2014-11-05'
Group by 1
Order by 1;