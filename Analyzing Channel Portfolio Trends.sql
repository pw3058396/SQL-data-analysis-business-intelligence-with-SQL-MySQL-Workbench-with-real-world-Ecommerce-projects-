Select 
	Min(Date(created_at)) as week_start_date,
	Count(Distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as g_dtop_sessions,
    Count(Distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) as b_dtop_sessions,
    Count(Distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end)/
		Count(Distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as b_pct_of_g_dtop,
    Count(Distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as g_mob_sessions,
    Count(Distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) as b_mob_sessions,
	Count(Distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end)/
		Count(Distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as b_pct_of_g_mob
From website_sessions
Where created_at between '2012-11-04' and '2012-12-22'
and utm_campaign = 'nonbrand'
Group by yearweek(created_at)