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
SELECT t3.seller_id, SUM(payment_value) AS total_sell
FROM (
SELECT order_items.seller_id, order_items.order_id 
FROM order_items
JOIN sellers
ON order_items.seller_id = sellers.seller_id ) AS t3
LEFT JOIN order_payments
ON t3.order_id = order_payments.order_id
GROUP BY t3.seller_id
ORDER BY total_sell DESC LIMIT 10;

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
