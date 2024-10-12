/*7. Perform analysis related to Sales Trends, patterns, and seasonality. 
"Which months have had the highest sales, what is the sales amount and contribution in percentage?
Which months have had the least sales, what is the sales amount and contribution in percentage?  
Sales trend by month   
Is there any seasonality in the sales (weekdays vs. weekends, months, days of week, weeks etc.)?
Total Sales by Week of the Day, Week, Month, Quarter, Weekdays vs. weekends etc."*/


select year(A.Bill_date_timestamp)  as yr_,format (A.Bill_date_timestamp,'MMMM') as month_, sum(A.Total_Amount) as total_amt,sum(A.Total_Amount)*100.0/(select sum(A.Total_Amount) from Integrated_Table A) as contr_pct from Integrated_Table A
group by  year(A.Bill_date_timestamp) ,format(A.Bill_date_timestamp,'MMMM')
order by year(A.Bill_date_timestamp) ,format(A.Bill_date_timestamp,'MMMM')

--seasonality 



with sales_info as (select year(A.Bill_date_timestamp)  as yr_,format (A.Bill_date_timestamp,'MMMM') as month_,datename(weekday,A.Bill_date_timestamp) as weekday_, sum(A.Total_Amount) as total_amt,sum(A.Total_Amount)*100.0/(select sum(A.Total_Amount) from Integrated_Table A) as contr_pct ,
case when datename(weekday,A.Bill_date_timestamp) in( 'Saturday','Sunday') then 'Weekend' else 'Weekday' end as label_


from Integrated_Table A
group by  year(A.Bill_date_timestamp) ,format(A.Bill_date_timestamp,'MMMM'),datename(weekday,A.Bill_date_timestamp)
)

select A.label_,sum(A.total_amt) day_ctr,sum(A.total_amt)*100/( select sum(B.total_amt) from sales_info B) as day_ctr_pct from sales_info A
group by A.label_

---by day
select format( A.Bill_date_timestamp , 'hh:mm tt') as time_,sum(A.Total_Amount)sum_ from Integrated_Table A
group by format( A.Bill_date_timestamp , 'hh:mm tt')
order by format ( A.Bill_date_timestamp , 'hh:mm tt') desc


--by quarter
select datepart(quarter,A.Bill_date_timestamp) as quarter_,year(A.Bill_date_timestamp) as yr_ ,sum(A.Total_Amount) as total_sales  from Integrated_Table A
group by year(A.Bill_date_timestamp),datepart(quarter,A.Bill_date_timestamp)


 