WITH mau AS
(	
SELECT year, FLOOR(AVG(au)) AS avg_mau
FROM (
	 SELECT date_part ('year', order_purchase_timestamp) AS year,
			date_part ('month', order_purchase_timestamp) AS month,
			COUNT(DISTINCT c.customer_unique_id) AS au
	 FROM orders_dataset o
	 JOIN customers_dataset c ON c.customer_id = o.customer_id
	 GROUP BY year, month
	) sub1
GROUP BY year
),

new_c AS
(
SELECT date_part('year', first_buy) AS year,
	   COUNT (first_buy) AS new_customers
FROM(
	 SELECT c.customer_unique_id,
	 		MIN(order_purchase_timestamp) AS first_buy
	 FROM orders_dataset o
	 JOIN customers_dataset c ON c.customer_id = o.customer_id
	 GROUP BY c.customer_unique_id
	) sub2
GROUP BY year
),

repeat_o AS
(
SELECT	year,
		COUNT(customer_unique_id) AS rep_customer
FROM(
	 SELECT 
	 	date_part('year', order_purchase_timestamp) AS year,
		c.customer_unique_id,
		COUNT(order_purchase_timestamp) AS buy_freq
	FROM orders_dataset o
	JOIN customers_dataset c ON c.customer_id = o.customer_id
	GROUP BY year,customer_unique_id
	HAVING COUNT (order_purchase_timestamp) > 1
	) sub3
GROUP BY year
),

o_freq AS
(
SELECT 	year,
		FLOOR(AVG(order_freq)) AS avg_order_freq
FROM(
	SELECT 	date_part('year', order_purchase_timestamp) AS year,
		   	c.customer_unique_id,
		   	COUNT (order_purchase_timestamp) AS order_freq
	FROM orders_dataset o
	JOIN customers_dataset c ON c.customer_id = o.customer_id
	GROUP BY year, c.customer_unique_id
	) AS sub4
GROUP BY year
)

SELECT 	mau.year,
		mau.avg_mau,
		new_c.new_customers,
		repeat_o.rep_customer,
		o_freq.avg_order_freq
FROM mau
JOIN new_c ON new_c.year = mau.year
JOIN repeat_o ON repeat_o.year = mau.year
JOIN o_freq ON o_freq.year = mau.year
