-- 1. Показати кількість клієнтів у кожному штаті.
SELECT customer_state, COUNT(customer_id) AS count_customer
FROM customers
GROUP BY customer_state
ORDER BY count_customer ASC;

-- 2. Вивести 10 міст з найбільшою кількістю клієнтів.
SELECT customer_city, COUNT(customer_id) AS count_customer
FROM customers
GROUP BY customer_city
ORDER BY count_customer DESC LIMIT 10;

-- 3. Кількість замовлень по статусах
SELECT order_status, COUNT(order_status) AS count_order
FROM orders
GROUP BY order_status
ORDER BY count_order DESC;

-- 4. Середня ціна товару в замовленні
SELECT ROUND(AVG(price),2) AS avarage_price
FROM order_items;

-- 5. Найпопулярніші типи оплати
SELECT payment_type, COUNT(payment_type) AS count
FROM order_payments
GROUP BY payment_type
ORDER BY count DESC LIMIT 1;

-- 6. Топ-10 продавців за виручкою
SELECT seller_id, SUM(price) AS total_sell
FROM order_items
GROUP BY seller_id
ORDER BY total_sell DESC
LIMIT 10;

-- 7. Порахувати загальну кількість замовлень, та успішних замовлень з кожного штату
SELECT customers.customer_state,
COUNT(orders.order_id) AS total_orders,
COUNT(CASE WHEN order_status
NOT IN('canceled', 'unavailable') THEN 0 END
) AS successful_orders
FROM orders
JOIN customers
ON orders.customer_id = customers.customer_id
GROUP BY customers.customer_state
ORDER BY total_orders DESC;

-- 8. Середній рейтинг продавців
SELECT t3.seller_id, ROUND(AVG(order_reviews.review_score),2) AS avarage_score
FROM (
SELECT order_items.seller_id, order_items.order_id
FROM order_items
JOIN sellers
ON order_items.seller_id = sellers.seller_id
) AS t3
JOIN order_reviews
ON order_reviews.order_id = t3.order_id
GROUP BY t3.seller_id;

-- 9. Категорії товарів з найбільшими продажами
SELECT COALESCE(product_category_translation.product_category_name_english,t2.product_category_name)
AS category_name,
t2.sold_products
FROM (
SELECT t1.product_category_name,
COUNT(CASE WHEN orders.order_status NOT IN ('canceled','unavailable')
THEN 0 END) AS sold_products
FROM(
SELECT products.product_category_name, order_items.order_id
FROM order_items
JOIN products
ON order_items.product_id = products.product_id
) t1
JOIN orders
ON t1.order_id = orders.order_id
GROUP BY t1.product_category_name
ORDER BY sold_products DESC
) t2
LEFT JOIN product_category_translation
ON t2.product_category_name = product_category_translation.product_category_name;

-- 10. Топ-10 категорій за виручкою
SELECT COALESCE(product_category_translation.product_category_name_english,t2.product_category_name),
t2.sum_sales
FROM (
SELECT t1.product_category_name,
SUM(payment_value) AS sum_sales
FROM (
SELECT products.product_category_name, order_items.order_id
FROM order_items
JOIN products
ON order_items.product_id = products.product_id
) t1
JOIN order_payments
ON t1.order_id = order_payments.order_id
GROUP BY t1.product_category_name
ORDER BY sum_sales DESC LIMIT 10
) t2
LEFT JOIN product_category_translation
ON t2.product_category_name = product_category_translation.product_category_name;

-- 11. Середній чек по типах оплати
SELECT payment_type, ROUND(AVG(payment_value),2) AS avarage_price
FROM order_payments
GROUP BY payment_type;

-- 12. Відсоток скасованих замовлень
SELECT
ROUND(COUNT(CASE WHEN order_status = 'canceled' THEN 1 END)*100.0
/ COUNT(*),2) AS canceled_percent
FROM orders;

-- 13. Середній час доставки по штатах
SELECT c.customer_state,
AVG(o.order_delivered_customer_date - o.order_delivered_carrier_date)
AS average_time_of_delivered
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state;

-- 14. Місячна динаміка продажів по продавцях
SELECT oi.seller_id,
DATE_TRUNC('month', o.order_purchase_timestamp) AS year_month,
COUNT(DISTINCT o.order_id) AS orders_count,
SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id                        
GROUP BY oi.seller_id, DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY oi.seller_id, year_month;

-- 15. Клієнти з найбільшою кількістю замовлень
SELECT o.customer_id,
COUNT(o.order_id) AS count_orders
FROM orders o
JOIN customers c
ON c.customer_id = o.customer_id
GROUP BY o.customer_id
ORDER BY count_orders DESC;

-- 16. Рейтинг продавців за виручкою
SELECT t1.seller_id, t1.revenue,
RANK() OVER (ORDER BY revenue DESC ) AS rank
FROM(
SELECT seller_id, SUM(price) AS revenue
FROM order_items
GROUP BY seller_id
) t1;
