create database retail_orders;
use retail_orders;
show tables;

select count(*) from orders;
select * from orders;

commit;
-- 1. find region and year wise revenue generated 
select region ,
		year(order_date) as year_order,
		round(sum(sale_price)) as revenue 
from orders
group by region ,year_order
order by revenue , region desc ; 

-------------------------------------------------------------------------------------------------------------------------------------------
-- 2. find top 10 highest reveue generating products 

select product_id ,
	round(sum(sale_price)) as revenue 
from orders
group by product_id
order by revenue desc
limit 10 ; 
		
-------------------------------------------------------------------------------------------------------------------------------------------
-- 3. state ,category and qty_sold vise comparision  

select  state,
		category,
		sum(quantity) as qty_sold
from orders
group by state ,category 
order by state,qty_sold desc ;

-------------------------------------------------------------------------------------------------------------------------------------------
-- 4. find top 5 highest selling products in each region

WITH CTE AS ( 
		select region ,
				product_id ,
				round(sum(sale_price)) as sales
		from orders
		group by region ,product_id
		order by region , sales desc )
SELECT * from  (
		select * , 
				row_number() over (partition by region order by sales desc) as rn
		from CTE )x
where x.rn <=5;
-------------------------------------------------------------------------------------------------------------------------------------------
 -- 5. region segment wise sales 
WITH CTE AS (
	select region,
			segment,
			round(sum(sale_price)) as sales
	from orders
	group by region , segment )
select * from CTE
Order by region , sales desc;

-------------------------------------------------------------------------------------------------------------------------------------------
-- 6 find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as (	
		select  year(order_date) as order_year,
				month(order_date) as order_month,
				round(sum(sale_price)) as sales
		 from orders
		 group by order_year , order_month )
select order_month ,
		sum(case when order_year = 2022 then sales else 0 end) as  sales_2022 ,
        sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month ; 
-------------------------------------------------------------------------------------------------------------------------------------------
-- 7.for each category which month had highest sales 

with cte as (
	select category,DATE_FORMAT(order_date, '%Y%m') as order_year_month
	, round(sum(sale_price)) as sales 
	from orders
	group by category,DATE_FORMAT(order_date, '%Y%m')
	-- order by category,DATE_FORMAT(order_date, '%Y%m')
)
select * from (
	select *,
	row_number() over(partition by category order by sales desc) as rn
	from cte
) a
where rn=1;

-------------------------------------------------------------------------------------------------------------------------------------------
-- 8. which sub category had highest growth by profit in 2023 compare to 2022

with cte as (
	select sub_category,year(order_date) as order_year,
	round(sum(sale_price)) as sales
	from orders
	group by sub_category,year(order_date)
	-- order by year(order_date),month(order_date)
		)
	, cte2 as (
	select sub_category
	, sum(case when order_year=2022 then sales else 0 end) as sales_2022
	, sum(case when order_year=2023 then sales else 0 end) as sales_2023
	from cte 
	group by sub_category
	)
select *,
	round((sales_2023-sales_2022)) AS difference_amount
	,round((sales_2023-sales_2022) * 100 / sales_2022) highest_growth_percentage
from  cte2
order by (sales_2023-sales_2022) desc
limit 1


