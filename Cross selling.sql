select B.Order_id from (select T.Order_id,count(distinct T.product_id), sum(T.Total_Amount)  from (select A.Order_id,A.product_id,A.Quantity, A.Total_Amount , dense_rank() over (partition by A.Order_id,A.product_id order by Quantity desc ) as rank_
from Ordertable  A
left join Product_Info B
on A.product_id = B.product_id) as T 
where rank_ =1
group by T.Order_id  

having count(distinct T.product_id)> 1 ) as B

left join Ordertable as C 
on B.Order_id=C.Order_id
 

 002f98c0f7efd42638ed6100ca699b42




 SELECT 
    M.Product_1,
    M.Product_2,
    CASE 
        WHEN C1.Category IS NOT NULL THEN C1.Category
        ELSE 'Unknown'
    END AS Category_1,
    CASE 
        WHEN C2.Category IS NOT NULL THEN C2.Category
        ELSE 'Unknown'
    END AS Category_2,
    COUNT(DISTINCT M.order_id) AS Frequency
FROM (
    SELECT A.order_id, A.product_id AS Product_1, B.product_id AS Product_2
    FROM Ordertable AS A
    LEFT JOIN Ordertable AS B
    ON A.order_id = B.order_id AND A.product_id <> B.product_id
	/*left join Product_Info as C
	on A.product_id = C.product_id*/
    WHERE B.product_id IS NOT NULL
) AS M


LEFT JOIN Product_Info AS C1 ON M.Product_1 = C1.product_id
LEFT JOIN Product_Info AS C2 ON M.Product_2 = C2.product_id
where c1.Category<>c2.Category
GROUP BY M.Product_1, M.Product_2, 
         CASE 
             WHEN C1.Category IS NOT NULL THEN C1.Category
             ELSE 'Unknown'
         END,
         CASE 
             WHEN C2.Category IS NOT NULL THEN C2.Category
             ELSE 'Unknown'
         END
ORDER BY COUNT(DISTINCT M.order_id) DESC;



----------------------------------------------------------------------------------

 SELECT 
    M.Product_1,
    M.Product_2,
    C1.Category as C1,C2.Category as C2,
    COUNT(DISTINCT M.order_id) AS Frequency
FROM (
    SELECT A.order_id, A.product_id AS Product_1, B.product_id AS Product_2
    FROM Ordertable AS A
    LEFT JOIN Ordertable AS B
    ON A.order_id = B.order_id AND A.product_id <> B.product_id
	/*left join Product_Info as C
	on A.product_id = C.product_id*/
    WHERE B.product_id IS NOT NULL
) AS M


LEFT JOIN Product_Info AS C1 ON M.Product_1 = C1.product_id
LEFT JOIN Product_Info AS C2 ON M.Product_2 = C2.product_id
/*where c1.Category<>c2.Category*/
GROUP BY M.Product_1, M.Product_2, 
         CASE 
             WHEN C1.Category IS NOT NULL THEN C1.Category
             ELSE 'Unknown'
         END,
         CASE 
             WHEN C2.Category IS NOT NULL THEN C2.Category
             ELSE 'Unknown'
         END
ORDER BY COUNT(DISTINCT M.order_id) DESC;