-- pull organic search, direct type in, and paid brand search by month, 
-- and show those sessions as a % of paid search nonbrand
Select 
	website_session_id,
    created_at,
    Case 
		When utm_source is null and http_referer is not null then 'organic search'
        when utm_campaign = 'nonbrand' then 'nonbrand'
        when utm_campaign = 'brand' then 'brand'
        When utm_source is null and http_referer is null then 'Direct_type_in'
	End as channel_group
From website_sessions
Where created_at <'2012-12-23';
        


Select 
		year(created_at),
        month(created_at),
        Count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as nonbrand,
        Count(distinct case when utm_campaign = 'brand' then website_session_id else null end) as brand,
        Count(distinct case when utm_campaign = 'brand' then website_session_id else null end)/
			Count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as brand_pct_of_nonbrand,
        Count(distinct case when utm_source is null and http_referer is null then website_session_id else null end) as direct ,
        Count(distinct case when utm_source is null and http_referer is null then website_session_id else null end)/
			Count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as direct_pct_of_nonbrand,
		Count(distinct case when utm_source is null and http_referer is not null then website_session_id else null end) as organic,
        Count(distinct case when utm_source is null and http_referer is not null then website_session_id else null end)/
			Count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as organic_pct_of_nonbrand
From website_sessions
Where created_at < '2012-12-23'
Group by 1,2