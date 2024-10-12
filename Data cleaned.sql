 

select * from Ordertable

-- some order had multiple customers , so we took total of total amount on basis of customer+ orderid and mapped it with payment table and got possible matches and saved it in a table. We aggregated sum value in both table , round it off and then matched
with   Cust_order as (select A.Customer_id, A.Order_id, round(sum(A.Total_Amount),0) as Total_amt from Ordertable A
group by A.Customer_id, A.Order_id),

Orderpayment_grouped as(select  A.order_ID, round(sum(A.payment_value),0) as pay_value_total from Order_payment A group by A.Order_id),

Match_order as (select A.*  from Cust_order as A left join Orderpayment_grouped as B on A.Order_id =B.order_ID and A.Total_amt=B.pay_value_total where B.pay_value_total is not Null)

select * from Match_order  


select * into Matched_order from Match_order

 

	 -- All the records that showed null , it had issues that need to be fixed in order to get more matches : 

	 WITH Cust_order AS (
    SELECT 
        A.Customer_id, 
        A.Order_id, 
        SUM(ROUND(A.Total_Amount, 0)) AS Total_amt 
    FROM 
        Ordertable A
    GROUP BY 
        A.Customer_id, 
        A.Order_id
),

Orderpayment_grouped AS (
    SELECT 
        A.Order_ID, 
        SUM(ROUND(A.payment_value, 0)) AS pay_value_total 
    FROM 
        Order_payment A
    GROUP BY 
        A.Order_ID
),

Null_list AS (
    SELECT 
        B.* 
    FROM 
        Cust_order AS A 
    RIGHT JOIN 
        Orderpayment_grouped AS B 
    ON 
        A.Order_id = B.Order_ID 
        AND A.Total_amt = B.pay_value_total
    WHERE 
        A.Customer_id IS NULL
) ,
Remaining_ids as (SELECT 
    B.Customer_id ,B.Order_id,A.pay_value_total
FROM 
    Null_list  A inner join Ordertable B on A.Order_ID =B.Order_id and  A.pay_value_total = round(B.Total_Amount,0))
	 

select * from Null_list A
 

-- check if null list has mostly customer buying multiple products 

select * from Null_list in  (select A.Order_id from Ordertable A
	group by A.Order_id
	 having count (distinct A.product_id) >1
	 )


------Data has been cleaned and all the matched data after removing incosistencies joined back together

	
 select * from Remaining_orders
	 
select * from Matched_order
	
	with T1 as (select B.* from Matched_order A inner join Ordertable B on A.Customer_id=B.Customer_id and A.Order_id =B.Order_id),
	T2 as (select B.* from Remaining_orders A inner join  Ordertable B on A.Customer_id=B.Customer_id and A.Order_id =B.Order_id and A.pay_value_total=round(B.Total_Amount,0) ),

	T as (select * from T1 
											union all 
											select * from T2 )

Select * into NEW_ORDER_TABLE from T

	 

	 --- creating an integrated table to access all column from other table easily:


	 Select * into Integrated_Table from (select A.*, D.Category ,C.Avg_rating,E.seller_city ,E.seller_state,E.Region,F.customer_city,F.customer_state,F.Gender from NEW_ORDER_TABLE A  
	inner join (select A.ORDER_id,avg(A.Customer_Satisfaction_Score) as Avg_rating from Rating A group by A.ORDER_id) as C on C.ORDER_id =A.Order_id 
	inner join Product_Info as D on A.product_id =D.product_id
	inner join (Select distinct * from Store) as E on A.Delivered_StoreID =E.StoreID
	inner join Customer as F on A.Customer_id =F.Custid) as T
 

 select * from Integrated_Table

 