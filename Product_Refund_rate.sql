-- Pull monthly product refund rates, by product, and confirm our qualiy=ty issue ar now fixed

Select * from order_item_refunds;
Select * from order_items;

-- Create temporary table order_refund_list
Select
	order_items.order_id,
    order_items.product_id,
    order_items.created_at,
    order_items.order_item_id,
    order_item_refunds.order_item_id as refund_order_item_id,
    order_item_refunds.order_id as refund_order_id
From order_items left join order_item_refunds
	on order_items.order_item_id = order_item_refunds.order_item_id
;


Select
year(created_at) as yr,
month(created_at) as mo,
count(distinct case when product_id = 1 then order_id else null end) as p1_orders,
count(distinct case when product_id = 1 then refund_order_id else null end)/
	count(distinct case when product_id = 1 then order_id else null end) as p1_refund_rt,
count(distinct case when product_id = 2 then order_id else null end) as p2_orders,
count(distinct case when product_id = 2 then refund_order_id else null end)/
	count(distinct case when product_id = 2 then order_id else null end) as p2_refund_rt,
count(distinct case when product_id = 3 then order_id else null end) as p3_orders,
count(distinct case when product_id = 3 then refund_order_id else null end)/
	count(distinct case when product_id = 3 then order_id else null end) as p3_refund_rt,
count(distinct case when product_id = 4 then order_id else null end) as p4_orders,
count(distinct case when product_id = 4 then refund_order_id else null end)/
	count(distinct case when product_id = 4 then order_id else null end)as p4_refund_rt
From order_refund_list
where created_at < '2014-10-15'
Group by 1,2;
