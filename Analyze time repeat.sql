-- pull the minimum, maximum and average time between the first and second session for customer who do come back

-- Step 1: pull first session

-- Create temporary table first_sessions
Select 
	user_id,
	website_session_id,
    created_at
From website_sessions
where created_at >= '2014-01-01'
	and created_at < '2014-11-03'
    and	is_repeat_session = 0
;


-- Step 2: find the second sessions created time and the time period for second visit
-- Create temporary table time_period
Select 
	first_sessions.user_id,
	first_sessions.website_session_id,
    first_sessions.created_at,
    min(website_sessions.website_session_id) as second_session,
    min(website_sessions.created_at) second_created_at,
    datediff( min(website_sessions.created_at), first_sessions.created_at) as first_second_dif
From first_sessions inner join website_sessions
	on first_s essions.user_id = website_sessions.user_id
    and website_sessions.is_repeat_session
    and website_sessions.created_at > first_sessions.created_at
Group by 1,2,3;


-- Step 3: Find the avg, min and max
Select 
	avg(first_second_dif) as avg_days_first_to_second,
    min(first_second_dif) as min_days_first_to_second,
    max(first_second_dif) as max_days_first_to_second
From time_period;
