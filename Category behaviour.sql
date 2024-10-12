-- Total Sales & Percentage of sales by category  

select T.*,sum(sales_pct) over(partition by Category order by Total_Sales desc) as cumulative_pct   from  



with sales_percent as (select A.Category, sum(A.Total_Amount) as Total_sales,(sum(A.Total_Amount)*100)/(select sum(Integrated_Table.Total_Amount) from Integrated_Table) as sales_pct from Integrated_Table as A
group by A.Category

 )
 select A.*,sum(A.sales_pct) over( order by sales_pct desc ) as cumulative_pct    from  sales_percent A
 order by A.Total_sales desc

--Most profitable category and its contribution

select  A.Category, sum(A.Total_Amount) as contribution ,  sum(A.Total_Amount-(A.Cost_Per_Unit*A.Quantity))  as Total_Profit  from Integrated_Table A
group by A.Category
order by sum(A.Total_Amount) desc

--Category Penetration Analysis by month on month (Category Penetration = number of orders containing the category/number of orders)

 


 with Categories_in_order as (select A.Category,year(A.Bill_date_timestamp) as year_,format(A.Bill_date_timestamp,'MMMM') as month_,count(A.Order_id) as order_count  from Integrated_Table A group by A.Category,year(A.Bill_date_timestamp),format(A.Bill_date_timestamp,'MMMM'))
 select A.year_,A.month_,A.Category,A.order_count,(A.order_count*100.0)/(select count(A.Order_id) as order_countT from Integrated_Table A ) as cat_pen from  Categories_in_order A
 order by A.year_,A.month_,(A.order_count*100.0)/(select count(A.Order_id) as order_countT from Integrated_Table A ) desc

 -- --popular product during firt purchase  


select T.Category ,count(T.Category) as cat_count from  (select   A.Customer_id,A.Category,min(A.Bill_date_timestamp) first_time from Integrated_Table A
 group by A.Customer_id,A.Category) as T
 group by  T.Category
 order by   count(T.Category) desc
 

  --popular product during firt purchase by month


select T.Category,format(T.first_time,'MMMM') as month_,count(T.Category) as cat_count from  (select   A.Customer_id,A.Category,min(A.Bill_date_timestamp) first_time from Integrated_Table A
 group by A.Customer_id,A.Category) as T
 group by format(T.first_time,'MMMM'),T.Category
 order by format(T.first_time,'MMMM'), count(T.Category) desc


--count of products in categories
select A.Category,count(distinct A.product_id) product_count  from Integrated_Table A
group by A.Category
order by count(distinct A.product_id) desc
 