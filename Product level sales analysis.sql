-- pull monthly trend to date for number of sales, total revenue, and total margin generated for the business

Use mavenfuzzyfactory;

Select 
	year(created_at) as yr,
    month(created_at) as mo,
    count(distinct order_id) as number_of_sales,
    sum(price_usd) as total_revenue,
    sum(price_usd - cogs_usd) as total_margin
From orders
Where created_at < '2013-01-04'
Group by 1, 2
;
