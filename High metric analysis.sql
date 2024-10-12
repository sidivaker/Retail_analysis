/*Define & calculate high-level metrics like (   Average order value or Average Bill Value,  
  , Transactions per Customer,     
, Average number of days between two transactions (if the customer has more than one transaction), percentage of profit, 
ercentage of discount, Repeat purchase rate,  ,  


Understand the retention of customers on month on month basis 
How the revenues from existing/new customers on monthly basis


 
*/

select * from Integrated_Table

-- number of orders
Select  (select count(distinct A.Order_id ) from Integrated_Table A) as Number_of_orders,
(select count(distinct A.Customer_id ) from Integrated_Table A) as Number_of_customers,
(select sum( A.Quantity) from Integrated_Table A) as Total_quantity,
(select count(distinct A.product_id ) from Integrated_Table A) as Total_products,
(select count(distinct A.Category ) from Integrated_Table A) as Total_categories,


(select count(distinct A.Delivered_StoreID ) from Integrated_Table A )as Total_stores,
(select count(distinct A.seller_state ) from Integrated_Table A )as Total_seller_locations,
(select count(distinct A.Region ) from Integrated_Table A ) as Total_Regions,
(select count(distinct A.Channel ) from Integrated_Table A) as Total_channels,


(select sum(A.Total_Amount) from  Integrated_Table A) as Total_Revenue,
(select sum(A.Cost_Per_Unit*A.Quantity) from  Integrated_Table A) as Total_Cost,
(select sum(A.Discount*A.Quantity) from  Integrated_Table A) as Total_discount,

(select sum(A.Total_Amount-(A.Cost_Per_Unit*A.Quantity)) from  Integrated_Table A) as Total_Profit,

(select count(distinct B.payment_type) from  NEW_ORDER_TABLE A inner join  Order_payment B on A.Order_id =B.order_ID) as Total_payment_methods,

(select (sum(A.Discount*A.Quantity))/count(distinct A.Customer_id) from  Integrated_Table A) as  Average_discount_per_customer,

(select(select avg(T.avg_)from (select avg(A.Discount*A.Quantity) as avg_ from  Integrated_Table A
group by A.Order_id)as T)) as  Average_discount_per_order 
,

(select sum(A.Total_Amount)/count(distinct A.Customer_id) from  Integrated_Table A) as Average_Sales_per_Customer,

(select sum(A.Total_Amount-(A.Cost_Per_Unit*A.Quantity))/count(distinct A.Customer_id) from  Integrated_Table A) as Average_profit_per_customer,

(select count(distinct A.Category)/count(distinct A.Order_id) from  Integrated_Table A) as Average_no_of_categories_per_order,
(select count(distinct A.product_id)/count(distinct A.Order_id) from  Integrated_Table A) as Average_no_of_items_per_order,


 (select ( (Select sum(T.count_) from (select distinct A.Customer_id,count(A.Customer_id) as count_ from Integrated_Table A
group by A.Customer_id
having count(A.Customer_id) =1) as T)*100)/count(distinct A.Customer_id) from Integrated_Table A) as One_time_buyers_percentage,

(select ( (Select sum(T.count_) from (select distinct A.Customer_id,count(A.Customer_id) as count_ from Integrated_Table A
group by A.Customer_id
having count(A.Customer_id) >1) as T)*100.0)/count(distinct A.Customer_id) from Integrated_Table A) as repeat_buyers_percentage,

 (select sum(A.Total_Amount-(A.Cost_Per_Unit*A.Quantity)) /count(distinct A.Order_id ) from Integrated_Table A) as profit_per_order


select count(distinct A.customer_state) from Integrated_Table A





-- Q Average Number of Categories per orders
select T.order_id, Avg(T.Category_cnt) as Avg_Category_cnt from(
Select it.order_id, Count(Category) as Category_cnt from Integrated_Table as it
group by it.order_id 
) as T
group by T.order_id
having  Avg(T.Category_cnt) >1



-- Q Avg no. of items in order
select avg(Avg_item_per_Order) from (select it.order_id,Avg(Quantity) as Avg_item_per_Order from Integrated_Table as it
group by it.order_id)as T 

-- Q Repeat Purchase rate
SELECT COUNT(T.Customer_id)*100.0/(Select Count(Distinct Customer_id) from Integrated_Table)  AS Repeat_Purchase_rate
FROM (
    SELECT Customer_id
    FROM Integrated_Table
    GROUP BY Customer_id
    HAVING COUNT(order_id) >= 2
) AS T


--Discount percentage :

select (sum(A.Total_Amount)-sum(A.Quantity*A.MRP))*100/sum(A.Quantity*A.MRP) from Integrated_Table A


--avg order  value:

select sum(A.Total_Amount)/count(distinct Order_id) from Integrated_Table A

--avg discount per customer 

select avg(T.discount_) from (select A.Customer_id, sum(A.Quantity*A.Discount) as discount_ from Integrated_Table A
group by A.Customer_id) as T

--avg transaction per customer

select avg(T.order_) from (select A.Customer_id, count(A.Order_id) as order_ from Integrated_Table A
group by A.Customer_id) as T

--sales by payment method:
select * into Integrated_payment from ( select A.*,B.payment_type,B.payment_value from Integrated_Table as A
 inner join Order_payment as B
 on A.Order_id =B.order_ID)as T

 select A.payment_type,sum(A.payment_value) as t_sale,(sum(A.payment_value)*100)/(select sum(A.payment_value) as sale_pct from Integrated_payment as A) from Integrated_payment as A
 group by A.payment_type







 -- top channel used for payment 

 select A.Channel,count(A.Channel) from Integrated_Table A
 group by A.Channel





 


-- List the top 10 most expensive products sorted by price and their contribution to sales


select T.*,B.Category from (select top 10 A.product_id, sum(A.Total_Amount) as contribution ,A.Cost_Per_Unit from Integrated_Table A
group by A.product_id ,A.Cost_Per_Unit
order by A.Cost_Per_Unit desc ,sum(A.Total_Amount) desc) as T inner join Product_Info B  on T.product_id =B.product_id

-- Top 10-performing & worst 10 performance stores in terms of sales

select top 10 A.Delivered_StoreID,A.seller_state,A.seller_city ,sum(A.Total_Amount) as Total_sales  from Integrated_Table A
group by A.Delivered_StoreID ,A.seller_state,A.seller_city
order by sum(A.Total_Amount) desc

select top 10  A.Delivered_StoreID ,A.seller_state,A.seller_city,sum(A.Total_Amount) as Total_sales from Integrated_Table A
group by A.Delivered_StoreID,A.seller_state,A.seller_city
order by sum(A.Total_Amount) asc  

--top categorgy:



--Understanding how many new customers acquired every month (who made transaction first time in the data) in each year per month

with First_Purchase as (select A.Customer_id,min(A.Bill_date_timestamp) as first_purchase_date from Integrated_Table A
group by A.Customer_id),
Year_month as (Select A.Customer_id,year(A.first_purchase_date) as first_year,format(A.first_purchase_date,'MMMM') as first_month  from First_Purchase A)

select A.first_year,A.first_month,count(A.Customer_id) as New_customers from Year_month A
group by A.first_year,A.first_month
order by A.first_year,A.first_month

-- understand sales trend by month and year.

 Select  year(A.Bill_date_timestamp) as year_,format(A.Bill_date_timestamp, 'MMMM') as month_,sum(A.Total_Amount) as total_sales  from Integrated_Table A

group by  year(A.Bill_date_timestamp),format(A.Bill_date_timestamp, 'MMMM')
order by year(A.Bill_date_timestamp),format(A.Bill_date_timestamp, 'MMMM')

--

select A.*, B.payment_type,B.payment_value from NEW_ORDER_TABLE A inner join Order_payment B on A.Order_id =B.order_ID

-- average duration between transaction for customer buying twice per customer

with Nextorder_column as( select A.Customer_id,A.Bill_date_timestamp, lead(A.Bill_date_timestamp) over(partition by Customer_id order by Bill_date_timestamp)as Next_Order_date from Integrated_Table A),

Duration as(select A.Customer_id, datediff(day,A.Bill_date_timestamp,A.Next_Order_date) as duration from  Nextorder_column A where A.Next_Order_date is not Null)

select A.Customer_id,avg(A.duration) average_days_between_transaction_per_cust from Duration A
group by A.Customer_id
order by  avg(A.duration)

-- average duration between transaction for customer buying twice --overall

with Nextorder_column as( select A.Customer_id,A.Bill_date_timestamp, lead(A.Bill_date_timestamp) over(partition by Customer_id order by Bill_date_timestamp)as Next_Order_date from Integrated_Table A),

Duration as(select A.Customer_id, datediff(day,A.Bill_date_timestamp,A.Next_Order_date) as duration from  Nextorder_column A where A.Next_Order_date is not Null),

Average_cal as (select A.Customer_id,avg(A.duration) average_days_between_transaction_per_cust from Duration A
group by A.Customer_id
)

select avg(A.average_days_between_transaction_per_cust) from Average_cal A


---sales by category and product
select T.*,B.Category from (select  distinct A.product_id, sum(A.Total_Amount) as contribution ,A.Cost_Per_Unit from Integrated_Table A
group by A.product_id ,A.Cost_Per_Unit
 ) as T inner join Product_Info B  on T.product_id =B.product_id
 order by T.Cost_Per_Unit desc

 -- expensive products 
 
  select A.product_id, A.Category, sum(A.Total_Amount) as t_sum from Integrated_Table A
  group by A.product_id ,A.Category
  order by sum(A.Total_Amount) desc


 --popular product during firt purchase by month


select T.Category,format(T.first_time,'MMMM') as month_,count(T.Category) as cat_count from  (select   A.Customer_id,A.Category,min(A.Bill_date_timestamp) first_time from Integrated_Table A
 group by A.Customer_id,A.Category) as T
 group by format(T.first_time,'MMMM'),T.Category
 order by format(T.first_time,'MMMM'), count(T.Category) desc
 

  --popular product during firt purchase by month


select T.Category,format(T.first_time,'MMMM') as month_,count(T.Category) as cat_count from  (select   A.Customer_id,A.Category,min(A.Bill_date_timestamp) first_time from Integrated_Table A
 group by A.Customer_id,A.Category) as T
 group by format(T.first_time,'MMMM'),T.Category
 order by format(T.first_time,'MMMM'), count(T.Category) desc


  --avg profit% 


  -- sales nd quantity  trend by state
  select A.seller_state,sum(A.Quantity)as Total_quantity,sum(A.Total_Amount) as Total_amount from Integrated_Table A
  group by A.seller_state

---- sales nd city count  trend by state
   select A.seller_state,count(distinct A.seller_city)as Total_cities,sum(A.Total_Amount) as Total_amount from Integrated_Table A
  group by A.seller_state

  --- popular categories by state
   select A.seller_state,A.Category,count(A.Category)as Total_category_count  from Integrated_Table A
  group by A.seller_state , A.Category
  order by A.seller_state

   select A.Region,A.Category,count(A.Category)as Total_category_count  from Integrated_Table A
  group by A.Region , A.Category
  order by A.Region


  -- sales by region and store 


  select A.Region, sum(A.Total_Amount) region_sales  from Integrated_Table A
  group by A.Region


  select A.Channel, sum(A.Total_Amount) channel_sales  from Integrated_Table A
  group by A.Channel



