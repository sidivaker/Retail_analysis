




 
 -- creating cohort 


with cohort_data as	(SELECT 
    Customer_id, 
    YEAR ( MIN(Bill_date_timestamp)) AS Cohort_Year, 
    format(MIN(Bill_date_timestamp),'MMMM') AS Cohort_Month,
	month(MIN(Bill_date_timestamp)) as month_number,
	sum(Total_Amount) as total_revenue
FROM Integrated_Table
GROUP BY Customer_id),


cohort_total as (SELECT  
      Cohort_Year, 
     Cohort_Month,
	 month_number,
	COUNT(DISTINCT Customer_id) AS Total_Customers,
	sum(total_revenue) as cohort_revenue
FROM cohort_data
GROUP BY Cohort_Year,  Cohort_Month ,month_number ),

integrated_data as (select A.Customer_id,A.Total_Amount, year(Bill_date_timestamp) as order_year, 
	format(Bill_date_timestamp,'MMMM') as order_month , month(Bill_date_timestamp) as order_month_n from Integrated_Table A),



	cohort_retention as (
SELECT 
    cohort_data.Cohort_Year, 
    cohort_data.Cohort_Month, 
	cohort_data.month_number,
     order_year, 
	 order_month,
	 order_month_n,
	COUNT(DISTINCT integrated_data.Customer_id) AS Retained_Customer
FROM 
    integrated_data 
JOIN 
    cohort_data 
ON 
    integrated_data.Customer_id = cohort_data.Customer_id
GROUP BY 
    cohort_data.Cohort_Year, cohort_data.Cohort_Month,cohort_data.month_number,   order_year, order_month,order_month_n
 )
 SELECT 
    cohort_retention.Cohort_Year, 
    cohort_retention.Cohort_Month, 
	 cohort_retention.month_number,
    cohort_retention.Order_Year, 
    cohort_retention.Order_Month,
	cohort_retention.order_month_n,
	cohort_retention.Retained_Customer,
	cohort_total.Total_Customers,
	(cohort_retention.Retained_Customer *1.0/ cohort_total.Total_Customers) * 100 AS Retention_Rate
    
FROM 
    cohort_retention
JOIN 
    cohort_total
ON 
    cohort_retention.Cohort_Year = cohort_total.Cohort_Year 
    AND cohort_retention.Cohort_Month = cohort_total.Cohort_Month

	where  cohort_retention.Cohort_Year >2021
ORDER BY 
    cohort_retention.Cohort_Year, cohort_retention.month_number ,cohort_retention.Order_Year,cohort_retention.order_month_n
 




/*
 ---customer count and custome retention rate 
 
with cohort_data as	(SELECT 
    Customer_id, 
    YEAR ( MIN(Bill_date_timestamp)) AS Cohort_Year, 
    format(MIN(Bill_date_timestamp),'MMMM') AS Cohort_Month,
	sum(Total_Amount) as total_revenue
FROM Integrated_Table
GROUP BY Customer_id),


cohort_total as (SELECT  
      Cohort_Year, 
     Cohort_Month,
	COUNT(DISTINCT Customer_id) AS Total_Customers,
	sum(total_revenue) as cohort_revenue
FROM cohort_data
GROUP BY Cohort_Year,  Cohort_Month  ),

integrated_data as (select A.Customer_id,A.Total_Amount, year(Bill_date_timestamp) as order_year, 
	format(Bill_date_timestamp,'MMMM') as order_month  from Integrated_Table A),



	cohort_retention as (
SELECT 
    cohort_data.Cohort_Year, 
    cohort_data.Cohort_Month, 
     order_year, 
	 order_month,
	COUNT(DISTINCT integrated_data.Customer_id) AS Retained_Customer
FROM 
    integrated_data 
JOIN 
    cohort_data 
ON 
    integrated_data.Customer_id = cohort_data.Customer_id
GROUP BY 
    cohort_data.Cohort_Year, cohort_data.Cohort_Month,   order_year, order_month
 )
 SELECT 
    cohort_retention.Cohort_Year, 
    cohort_retention.Cohort_Month, 
    cohort_retention.Order_Year, 
    cohort_retention.Order_Month,
	cohort_retention.Retained_Customer,
	cohort_total.Total_Customers,
    (cohort_retention.Retained_Customer *1.0/ cohort_total.Total_Customers) * 100 AS Retention_Rate
FROM 
    cohort_retention
JOIN 
    cohort_total
ON 
    cohort_retention.Cohort_Year = cohort_total.Cohort_Year 
    AND cohort_retention.Cohort_Month = cohort_total.Cohort_Month
ORDER BY 
    cohort_retention.Cohort_Year, cohort_retention.Cohort_Month, cohort_retention.Order_Year, cohort_retention.Order_Month 


	SELECT 
    Customer_id, 
    YEAR ( MIN(Bill_date_timestamp)) AS Cohort_Year, 
    format(MIN(Bill_date_timestamp),'MMMM') AS Cohort_Month,
	sum(Total_Amount)
FROM Integrated_Table
GROUP BY Customer_id