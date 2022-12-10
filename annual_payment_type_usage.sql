SELECT	payment_type,
    	COUNT (payment_type) AS total_usage
FROM order_payments_dataset 
GROUP BY payment_type
ORDER BY total_usage desc;

with payment AS(
SELECT
        date_part('year',o.order_purchase_timestamp) as year,
        op.payment_type,
        COUNT (order_purchase_timestamp) as payment_used
FROM order_payments_dataset op
JOIN orders_dataset o ON o.order_id = op.order_id
GROUP BY year,payment_type
ORDER BY year
)
SELECT
     payment_type,
     SUM(CASE WHEN year = '2016' THEN payment_used ELSE 0 END) AS yr_2016,
     SUM(CASE WHEN year = '2017' THEN payment_used ELSE 0 END) AS yr_2017,
     SUM(CASE WHEN year = '2018' THEN payment_used ELSE 0 END) AS yr_2018
FROM payment
GROUP BY payment_type
ORDER BY payment_type;

