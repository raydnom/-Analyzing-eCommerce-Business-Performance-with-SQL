with revenue AS
(
SELECT 	DATE_PART('year', order_purchase_timestamp) AS year,
		ROUND (SUM( revenue) ) AS total_revenue
FROM(
	SELECT 
		order_id, 
		SUM(price+freight_value) AS revenue
	FROM order_item_dataset
	GROUP BY order_id
) sub1
JOIN orders_dataset o on sub1.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY year
ORDER BY year
),

cancelation AS
(
SELECT DATE_PART('year', order_purchase_timestamp) AS year,
COUNT(order_purchase_timestamp) AS canceled_orders
FROM orders_dataset
WHERE order_status = 'canceled'
GROUP BY year
),

top_product AS
(
SELECT year, 
		product_category_name, 
		revenue 
FROM (
		SELECT 
			DATE_PART('year', o.order_purchase_timestamp) AS year,
			p.product_category_name,
			ROUND(SUM(oi.price + oi.freight_value)) AS revenue,
			RANK() OVER(PARTITION BY DATE_PART('year', o.order_purchase_timestamp) 
				   ORDER BY SUM(oi.price + oi.freight_value) DESC) AS rank
		FROM order_item_dataset oi
		JOIN orders_dataset o on o.order_id = oi.order_id
		JOIN product_dataset p on p.product_id = oi.product_id
		WHERE o.order_status = 'delivered'
		GROUP BY year,product_category_name) sub2
WHERE rank = 1
),

top_cancel AS
(
SELECT 	year, 
		product_category_name, 
		total_cancelation 
FROM (
	  SELECT DATE_PART('year', o.order_purchase_timestamp) AS year,
			 p.product_category_name,
		   	 COUNT(order_purchase_timestamp) AS total_cancelation,
			 RANK() OVER(PARTITION BY DATE_PART('year', o.order_purchase_timestamp) 
			 		ORDER BY COUNT(order_purchase_timestamp) DESC) AS rank
FROM order_item_dataset oi
JOIN orders_dataset o ON o.order_id = oi.order_id
JOIN product_dataset p ON p.product_id = oi.product_id
WHERE o.order_status = 'canceled'
GROUP BY year,product_category_name) sub3
WHERE rank = 1
)

SELECT 
	top_product.year,
	top_product.product_category_name AS top_product_category,
	top_product.revenue AS category_revenue,
	revenue.total_revenue AS annual_total_revenue,
	top_cancel.product_category_name AS most_canceled_product,
	top_cancel.total_cancelation AS category_cancelation,
	cancelation.canceled_orders AS annual_total_cancelation
FROM top_product
JOIN revenue ON top_product.year = revenue.year 
JOIN cancelation ON cancelation.year = top_product.year
JOIN top_cancel ON top_product.year = top_cancel.year 

