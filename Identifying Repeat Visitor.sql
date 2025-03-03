-- pull data on how many of our website visitor come back for another session? 

Use mavenfuzzyfactory;

Select *
From website_sessions
Where created_at between '2014-01-01' and '2014-11-01'
order by user_id
;


Select 
	user_id,
    Count(distinct website_session_id) as count_sessions
From website_sessions
Where created_at between '2014-01-01' and '2014-11-01'
Group by 1
;



Select 
	Case when count_sessions = 1 then 0
		when count_sessions = 2 then 1
		when count_sessions = 3 then 2
        when count_sessions = 4 then 3
	else count_sessions -1 
    end as repeat_sessions,
    Count(user_id) as users
From (Select 
	user_id,
    Count(distinct website_session_id) as count_sessions
From website_sessions
Where created_at between '2014-01-01' and '2014-11-01'
Group by 1) as user_id_session_count
Group by 1;
    
-- correct solution


-- Create temporary table sessions_w_repeats
Select 
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    website_sessions.website_session_id as repeat_session_id

From(

Select
	user_id,
    website_session_id
From website_sessions
Where created_at between '2014-01-01' and '2014-11-01'
	and is_repeat_session = 0) as new_sessions
	Left join website_sessions
		on website_sessions.user_id = new_sessions.user_id
        and website_sessions.is_repeat_session = 1
        and website_sessions.website_session_id > new_sessions.website_session_id
        and created_at between '2014-01-01' and '2014-11-01';
        
	Select
		repeat_sessions,
        count(distinct user_id) as users
	From 
    (Select 
		user_id,
        count(distinct new_session_id) as new_sessions,
        count(distinct repeat_session_id) as repeat_sessions
	From sessions_w_repeats
    Group by 1
    order by 3 DESC
    ) as user_level
    
    Group by 1
    ;
