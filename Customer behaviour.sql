--Gender count and percent:
select A.Gender,count(A.Gender) gender_count, sum(A.Total_Amount) t_amt , sum(A.Total_Amount)*100/(select sum(B.Total_Amount) from Integrated_Table B) as pct_ctr from Integrated_Table A
group by  A.Gender




/*--RFM segmentation


-- Step 1: Calculate RFM values
WITH RFM_Calculation AS (
    SELECT 
        Customer_id,
        DATEDIFF(day,max(Bill_date_timestamp) ,'2023-12-08 23:45:00.0000000') AS Recency,
        COUNT(Order_id) AS Frequency,
        SUM(Total_Amount) AS Monetary
    FROM 
        Integrated_Table
    GROUP BY 
        Customer_id
)

-- Step 2: Assign RFM scores
, RFM_Scoring AS (
    SELECT 
        Customer_id,
		Recency,Frequency,Monetary,


        NTILE(4) OVER (ORDER BY Recency desc ) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency  ) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary  ) AS M_Score
    FROM 
        RFM_Calculation
),

 
 


-- Step 3: Combine the scores to create RFM segments
 final_frm_t as (SELECT 
    Customer_id,
	Recency,Frequency,Monetary,
    R_Score,
    F_Score,
    M_Score,
    CASE 
        WHEN R_Score = 4 AND F_Score = 4 AND M_Score = 4 THEN 'Premium'
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Gold'
        WHEN R_Score >= 2 AND F_Score >= 2 AND M_Score >= 2 THEN 'Silver'
        ELSE 'Standard'
    END AS CustomerSegment
FROM 
    RFM_Scoring)*/

--tracking the RFM segments :


select A.CustomerSegment , sum(A.Monetary) as amt_ctr,(sum(A.Monetary)/(select sum (Integrated_Table.Total_Amount) from Integrated_Table))*100 as pct_ctr , count(A.CustomerSegment) as segment_count,count(A.CustomerSegment)*1.0*100/(select count(distinct A.Customer_id) from Integrated_Table A) as segment_count_pct from final_frm_t A
group by A.CustomerSegment

 

select CustomerSegment,count(CustomerSegment) from final_frm_t
group by CustomerSegment




select A.CustomerSegment ,avg(A.Recency) avg_recency,avg(A.Frequency) avg_frequency,avg(A.Monetary) avg_monetary from final_frm_t A
group by A.CustomerSegment




select A.CustomerSegment ,avg(A.Recency) avg_recency,avg(A.Frequency) avg_frequency,avg(A.Monetary) avg_monetary from final_frm_t A
group by A.CustomerSegment



/*---RFM cohort analysis:


 WITH RFM_Calculation AS (
    SELECT 
        Customer_id,
        DATEDIFF(day,max(Bill_date_timestamp) ,'2023-12-08 23:45:00.0000000') AS Recency,
        COUNT(Order_id) AS Frequency,
        SUM(Total_Amount) AS Monetary
    FROM 
        Integrated_Table
    GROUP BY 
        Customer_id
)

-- Step 2: Assign RFM scores
, RFM_Scoring AS (
    SELECT 
        Customer_id,
		Recency,Frequency,Monetary,


        NTILE(4) OVER (ORDER BY Recency desc ) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency  ) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary  ) AS M_Score
    FROM 
        RFM_Calculation
),

 
 


-- Step 3: Combine the scores to create RFM segments
 final_frm_t as (SELECT 
    Customer_id,
	Recency,Frequency,Monetary,
    R_Score,
    F_Score,
    M_Score,
    CASE 
        WHEN R_Score = 4 AND F_Score = 4 AND M_Score = 4 THEN 'Premium'
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Gold'
        WHEN R_Score >= 2 AND F_Score >= 2 AND M_Score >= 2 THEN 'Silver'
        ELSE 'Standard'
    END AS CustomerSegment
FROM 
    RFM_Scoring)

	 select   A.Customer_id,A.CustomerSegment ,year(B.Bill_date_timestamp)yr_, format(B.Bill_date_timestamp,'MMMM')as month_ ,B.Order_id,B.Total_Amount from final_frm_t A left join Integrated_Table B on A.Customer_id=B.Customer_id 


	 select   A.Customer_id,A.CustomerSegment,B.seller_state,B.Channel,B.Category from final_frm_t A left join Integrated_Table B on A.Customer_id=B.Customer_id */
	 




	-- Find out the number of customers who purchased in all the channels and find the key metrics.

	select A.Customer_id, count( distinct A.Channel) as no_channel from Integrated_Table as A
	group by A.Customer_id
	having count( distinct A.Channel)=3





	


 --Understand preferences of customers (preferred channel, Preferred payment method, preferred store, discount preference, preferred categories etc.)


 select A.Channel,count(A.Channel) as preferred_count from Integrated_Table A
 group by A.Channel

 
 select A.payment_type,count( A.Order_id) as preferred_count from Integrated_payment A
 group by A.payment_type


 select * from Integrated_payment A
 order by A.Customer_id


 
 select A.Delivered_StoreID,count(A.Delivered_StoreID) as preferred_count from Integrated_Table A
 group by A.Delivered_StoreID

 
 select A.Category,count(A.Category) as preferred_count from Integrated_Table A
 group by A.Category

 
 select count(month(A.Bill_date_timestamp)) month_count, format(A.Bill_date_timestamp,'MMMM') as preferred_count from Integrated_Table A
 group by format(A.Bill_date_timestamp,'MMMM')





 -- discount preference :
 with total_discount_amountpct as(select A.Quantity, ((A.Discount*A.Quantity)*100.0/ A.Total_Amount)  as T_discount_amount from  Integrated_Table A  ),
  bin_table as (select A.Quantity, case when A.T_discount_amount <10 THEN '0-10%'
                WHEN A.T_discount_amount >= 10 AND A.T_discount_amount < 20 THEN '10-20%'
                WHEN A.T_discount_amount >= 20 AND A.T_discount_amount   < 30 THEN '20-30%'
                WHEN A.T_discount_amount >= 30 AND A.T_discount_amount  < 40 THEN '30-40%'
				WHEN A.T_discount_amount >= 40 AND A.T_discount_amount   < 50 THEN '40-50%'
				WHEN A.T_discount_amount >= 50 AND A.T_discount_amount   < 60 THEN '50-60%'
                ELSE '60%+'
 end as bins
  from total_discount_amountpct A)

  select A.bins,count(A.bins) as discount_prefer, sum(A.Quantity) total_quantity_ordered from bin_table A
  group  by A.bins
  order by  A.bins 
 
 
 
 
 ) from total_discount_amount)


 


--repeat buuyer behaviour

with repeat_buy as (select A.Order_id,A.Customer_id,A.Bill_date_timestamp,A.Total_Amount from Integrated_Table A

where A.Customer_id in (select A.Customer_id from Integrated_Table A group by A.Customer_id having count(A.Order_id) >1)),

  behaviour as (select A.Customer_id, min(A.Bill_date_timestamp) first_time ,max(A.Bill_date_timestamp) las_time, count(A.Order_id) order_count , datediff(day,min(A.Bill_date_timestamp),max(A.Bill_date_timestamp)) as day_btw_fandltransaction from repeat_buy A group by A.Customer_id),
 
 days_btw_transc as (Select A.Customer_id, datediff(day,lag(A.Bill_date_timestamp) over(partition by Customer_id order by Bill_date_timestamp),A.Bill_date_timestamp)  as btwtransac_day  from repeat_buy A  )

 
 
 select avg(T.avg_) from (select A.Customer_id, avg(A.btwtransac_day) avg_ from  days_btw_transc A
 group  by A.Customer_id) as T



 --- sales by them over time
  with repeat_buy as (select A.Order_id,A.Customer_id,A.Bill_date_timestamp,A.Total_Amount,A.Quantity from Integrated_Table A 
where A.Customer_id in (select A.Customer_id from Integrated_Table A group by A.Customer_id having count(A.Order_id) >1)) ,

Datetime_table as  (select year(A.Bill_date_timestamp) year_, format(A.Bill_date_timestamp,'MMMM') as month_,datename(weekday,A.Bill_date_timestamp) as weekday_,sum(A.Total_Amount) as sale_ from repeat_buy A
group by year(A.Bill_date_timestamp)   , format(A.Bill_date_timestamp,'MMMM')  ,datename(weekday,A.Bill_date_timestamp) )

select *, case when  A.weekday_ in( 'Saturday','Sunday') then 'Weekend' else 'Weekday' end as label_ from Datetime_table A
 



-- total order and total quantity

  with repeat_buy as (select A.Order_id,A.Customer_id,A.Bill_date_timestamp,A.Total_Amount,A.Quantity from Integrated_Table A 
where A.Customer_id in (select A.Customer_id from Integrated_Table A group by A.Customer_id having count(A.Order_id) >1))
select count(A.Order_id) order_count, sum(A.Quantity) quantity_purchased from  repeat_buy A



--one time buyer sales 

  with repeat_buy as (select A.Order_id,A.Customer_id,A.Bill_date_timestamp,A.Total_Amount,A.Quantity from Integrated_Table A 
where A.Customer_id in (select A.Customer_id from Integrated_Table A group by A.Customer_id having count(A.Order_id) =1)) ,

Datetime_table as  (select year(A.Bill_date_timestamp) year_, format(A.Bill_date_timestamp,'MMMM') as month_,datename(weekday,A.Bill_date_timestamp) as weekday_,sum(A.Total_Amount) as sale_ from repeat_buy A
group by year(A.Bill_date_timestamp)   , format(A.Bill_date_timestamp,'MMMM')  ,datename(weekday,A.Bill_date_timestamp) )

select *, case when  A.weekday_ in( 'Saturday','Sunday') then 'Weekend' else 'Weekday' end as label_ from Datetime_table A
 

-- one time total order and total quantity

  with repeat_buy as (select A.Order_id,A.Customer_id,A.Bill_date_timestamp,A.Total_Amount,A.Quantity from Integrated_Table A 
where A.Customer_id in (select A.Customer_id from Integrated_Table A group by A.Customer_id having count(A.Order_id) =1))
select count(A.Order_id) order_count, sum(A.Quantity) quantity_purchased from  repeat_buy A

---customer retention per month

WITH monthly_purchases AS (
    SELECT 
        A.Customer_id,
        DATE_FORMAT(A.Bill_date_timestamp, '%Y-%m') AS purchase_month,
        MIN(DATE(A.Bill_date_timestamp)) AS first_purchase_date
    FROM 
        Integrated_Table A
    GROUP BY 
        A.Customer_id, DATE_FORMAT(A.Bill_date_timestamp, '%Y-%m')
),

monthly_retention AS (
    SELECT 
        mp1.purchase_month AS initial_month,
        mp1.customer_id,
        COUNT(DISTINCT mp2.purchase_month) AS retention_count
    FROM 
        monthly_purchases mp1
    LEFT JOIN 
        monthly_purchases mp2
    ON 
        mp1.customer_id = mp2.customer_id
        AND mp2.purchase_month > mp1.purchase_month
    GROUP BY 
        mp1.purchase_month, mp1.customer_id
)

SELECT 
    initial_month,
    COUNT(customer_id) AS total_customers,
    SUM(CASE WHEN retention_count > 0 THEN 1 ELSE 0 END) AS retained_customers,
    ROUND((SUM(CASE WHEN retention_count > 0 THEN 1 ELSE 0 END) / COUNT(customer_id)) * 100, 2) AS retention_rate
FROM 
    monthly_retention
GROUP BY 
    initial_month
ORDER BY 
    initial_month;



	Select A.Category,A.seller_state,A.Delivered_StoreID , A.Avg_rating  number_of_customers from Integrated_Table A
	 

--	 Rfm payment and channel


select * from Integrated_payment



WITH RFM_Calculation AS (
    SELECT 
        Customer_id,  Channel,
        DATEDIFF(day,max(Bill_date_timestamp) ,'2023-12-08 23:45:00.0000000') AS Recency,
        COUNT(Order_id) AS Frequency,
        SUM(Total_Amount) AS Monetary
    FROM 
        Integrated_payment
    GROUP BY 
        Customer_id, Channel
)

-- Step 2: Assign RFM scores
, RFM_Scoring AS (
    SELECT 
        Customer_id, Channel,
		 


        NTILE(4) OVER (ORDER BY Recency desc ) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency  ) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary  ) AS M_Score
    FROM 
        RFM_Calculation
),


 


-- Step 3: Combine the scores to create RFM segments
 final_frm_t as (SELECT 
    Customer_id,
	 Channel,
    R_Score,
    F_Score,
    M_Score,
    CASE 
        WHEN R_Score = 4 AND F_Score = 4 AND M_Score = 4 THEN 'Premium'
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Gold'
        WHEN R_Score >= 2 AND F_Score >= 2 AND M_Score >= 2 THEN 'Silver'
        ELSE 'Standard'
    END AS CustomerSegment
FROM 
    RFM_Scoring)


	select A.CustomerSegment,A.Channel,count(A.Customer_id) from final_frm_t A
	group by A.CustomerSegment,A.Channel
	order by A.CustomerSegment ,count(A.Customer_id)



	--- discount and non discount seekers 

	select count (A.Discount), A.Discount from Integrated_Table A
	where A.Discount= 0
	group by A.Discount


 
 select count (A.Discount)  from Integrated_Table A
	where A.Discount >0
	
	--- discount and non discount seekers --revenue

	select sum(A.Total_Amount) as non_discount_r  from Integrated_Table A
	where A.Discount= 0
	 


 
	select sum(A.Total_Amount) as discount_r  from Integrated_Table A
	where A.Discount>0

	--- discount and non discount seekers --orders

	select count(distinct A.Customer_id) as non_discount_order  from Integrated_Table A
	where A.Discount= 0
	 


 
	select count(distinct A.Customer_id) as discount_order  from Integrated_Table A
	where A.Discount>0


	 --- discount and non discount seekers --avg order value 

	select avg(T.non_discount_avg_order_value) as non_discount_avg_order_value from (select A.Customer_id,sum(A.Total_Amount) as non_discount_avg_order_value  from Integrated_Table A
	where A.Discount= 0
	group by A.Customer_id) as T 
	 


 
	select avg(T.discount_avg_order_value)  as discount_avg_order_value from (select A.Customer_id,sum(A.Total_Amount) as discount_avg_order_value   from Integrated_Table A
	where A.Discount>0
	group by A.Customer_id) as T 


	select A.Gender,sum(A.Total_Amount) from Integrated_Table as A 
	group by  A.Gender
	 

-------------------------------- RFM NEW
	 
	 WITH RFM_Calculation AS (
    SELECT 
        Customer_id,
        DATEDIFF(day,max(Bill_date_timestamp) ,'2023-12-08 23:45:00.0000000') AS Recency,
        COUNT(Order_id) AS Frequency,
        SUM(Total_Amount) AS Monetary
    FROM 
        Integrated_Table
    GROUP BY 
        Customer_id
)

-- Step 2: Assign RFM scores
, RFM_Scoring AS (
    SELECT 
        Customer_id,
		Recency,Frequency,Monetary,


        NTILE(4) OVER (ORDER BY Recency desc ) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency  ) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary  ) AS M_Score
    FROM 
        RFM_Calculation
),

 
 


-- Step 3: Combine the scores to create RFM segments
Total_scoring as (SELECT 
    Customer_id,
	Recency,Frequency,Monetary,
	
    R_Score, F_Score, M_Score,

    R_Score+ F_Score+ M_Score as Total_score
	 
     FROM 
    RFM_Scoring),

	



	customer_segment as (select *, case when Total_score>=11 then 'Premium'
	               when Total_score >=9 then 'Gold'
				   when Total_score >=6  then 'Silver'
				   when Total_score >=3 then 'Standard'
				   end as Customer_segments from Total_scoring)



select A.Customer_segments, count(A.Customer_segments) from customer_segment A
group by A.Customer_segments
order by count(A.Customer_segments)

select * from customer_segment A
where A.





select A.Customer_segments ,avg(A.Recency) avg_recency,avg(A.Frequency) avg_frequency,avg(A.Monetary) avg_monetary from customer_segment A
group by A.Customer_segments


select A.Customer_segments,sum(A.Monetary) as sales_ from customer_segment A
group by Customer_segments
order by sum(A.Monetary)


select A.Customer_segments, count(A.Customer_segments) from customer_segment A
group by A.Customer_segments
order by count(A.Customer_segments)


	select A.Total_score, count(A.Total_score) from  Total_scoring A
	group by A.Total_score
	order by  Total_score


	select A.Order_id , count(distinct A.Delivered_StoreID) as store, count(distinct A.Bill_date_timestamp) as time_  from Integrated_Table A
	group by A.Order_id
	having count(distinct A.Delivered_StoreID) >1 and count(distinct A.Bill_date_timestamp) >1




	RFM indepth :

Behavioral Patterns:
Examine the purchasing behavior within each segment, such as average order value, frequency of purchases, and preferred product categories.
Identify any trends or patterns that can help tailor marketing strategies to each segment.


Analyze the demographic breakdown (e.g., age, gender, location) of each segment to better understand your customers.


Assess how each segment responds to different types of promotions (e.g., discounts, 

Collect and analyze feedback from customers in each segment to understand their satisfaction levels and pain points.

--------------------------------------------------------------------------------------------------------------------------------------
	 WITH RFM_Calculation AS (
    SELECT 
        Customer_id,
        DATEDIFF(day,max(Bill_date_timestamp) ,'2023-12-08 23:45:00.0000000') AS Recency,
        COUNT(Order_id) AS Frequency,
        SUM(Total_Amount) AS Monetary
    FROM 
        Integrated_Table
    GROUP BY 
        Customer_id
)

-- Step 2: Assign RFM scores
, RFM_Scoring AS (
    SELECT 
        Customer_id,
		Recency,Frequency,Monetary,


        NTILE(4) OVER (ORDER BY Recency desc ) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency  ) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary  ) AS M_Score
    FROM 
        RFM_Calculation
),


-- Step 3: Combine the scores to create RFM segments
Total_scoring as (SELECT 
    Customer_id,
	Recency,Frequency,Monetary,
	
    R_Score, F_Score, M_Score,

    R_Score+ F_Score+ M_Score as Total_score
	 
     FROM 
    RFM_Scoring),

	customer_segment as (select *, case when Total_score>=11 then 'Premium'
	               when Total_score >=9 then 'Gold'
				   when Total_score >=6  then 'Silver'
				   when Total_score >=3 then 'Standard'
				   end as Customer_segments from Total_scoring)


				 analysis as   (select A.Customer_id , A. Customer_segments , B.customer_state,B.Gender, B.Channel, B.Category,B.Discount, ((B.Discount*B.Quantity)*100.0/ B.Total_Amount) as total_discount_pct, B.Avg_rating,B.Total_Amount  from  customer_segment A left join  Integrated_Table B 
				   on A.Customer_id =B.Customer_id)

				   select A.Customer_segments, A.Category, A.Total_Amount from analysis A
				   where A.Customer_segments ='Standard'  








