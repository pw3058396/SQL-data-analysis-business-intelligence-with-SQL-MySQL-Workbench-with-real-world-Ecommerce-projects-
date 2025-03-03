-- analyze the average website session volume, by hour of day and by day week, 
-- and avoid the holiday time period and ise a date range of Sep 15- Nov15,2012

-- create a table with every created date ,hour, weekday and amount of seesions
Select 
	date(created_at) as created_date,
	hour(created_at) as hr,
    weekday(created_at) as wk,
    Count(distinct website_session_id) as sessions
From website_sessions
Where created_at between '2012-09-15' and '2012-11-15'
Group by 1,2,3
;



Select 
	hr,
    -- weekday 0 = Monday, weekday 2 = Tuesday
    ROUND(AVG(sessions),1) as avg_sessions,
	ROUND(AVG(Distinct Case when wk = 0 then sessions else null end),1) as mon,
	ROUND(AVG(Distinct Case when wk = 1 then sessions else null end),1) as tue,
	ROUND(AVG(Distinct Case when wk = 2 then sessions else null end),1) as wed,
	ROUND(AVG(Distinct Case when wk = 3 then sessions else null end),1) as thu,
	ROUND(AVG(Distinct Case when wk = 4 then sessions else null end),1) as fri,
	ROUND(AVG(Distinct Case when wk = 5 then sessions else null end),1) as sat,
	ROUND(AVG(Distinct Case when wk = 6 then sessions else null end),1) as sun	
From (   
Select 
	date(created_at) as created_date,
    weekday(created_at) as wk,
    hour(created_at) as hr,
    Count(distinct website_session_id) as sessions
From website_sessions
Where created_at between '2012-09-15' and '2012-11-15'
Group by 1,2,3
) as session_created_time
Group by 1;