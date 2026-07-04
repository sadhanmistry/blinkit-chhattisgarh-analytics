-- ============================================================================
-- Blinkit Chhattisgarh — Business Questions
-- ============================================================================

USE blinkit_gold;


-- 1. Monthly revenue trend across FY2025-26
-- (excludes cancelled orders -- they have no real revenue)
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    ROUND((SUM(total_amount)/10000000),2) AS total_revenue_cr,
    ROUND(AVG(total_amount), 2) AS avg_order_value_Rs
FROM fact_orders
WHERE order_status != 'Cancelled'
GROUP BY order_month
ORDER BY order_month;


-- 2. Store performance ranking by revenue
SELECT
    s.store_id, s.store_name, s.city,
    COUNT(f.order_id) AS total_orders,
    ROUND((SUM(f.total_amount)/10000000),2) AS total_revenue_cr,
    ROUND(AVG(f.total_amount), 2) AS avg_order_value_Rs
FROM fact_orders f
JOIN dim_stores s ON f.store_id = s.store_id
WHERE f.order_status != 'Cancelled'
GROUP BY s.store_id, s.store_name, s.city
ORDER BY total_revenue_cr DESC;


-- 3. Cancellation and return rate by store
-- (uses ALL orders, including cancelled/returned, since the rate is the point)
SELECT
    s.store_id, s.store_name,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN f.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN f.order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(SUM(CASE WHEN f.order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN f.order_status = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM fact_orders f
JOIN dim_stores s ON f.store_id = s.store_id
GROUP BY s.store_id, s.store_name
ORDER BY cancellation_rate_pct DESC;


-- 4. Top 10 products by revenue
SELECT
    p.product_id, p.product_name, p.category,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND((SUM(oi.line_total)/10000000),2) AS total_revenue_cr
FROM fact_order_items oi
JOIN dim_products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue_cr DESC
LIMIT 10;


-- 5. Revenue and quantity by product category
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id) AS orders_containing_category,
    SUM(oi.quantity) AS total_quantity,
    ROUND((SUM(oi.line_total)/10000000),2) AS total_revenue_cr
FROM fact_order_items oi
JOIN dim_products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue_cr DESC;


-- 6. Payment mode distribution
SELECT
    payment_mode,
    COUNT(*) AS total_orders,
    ROUND((SUM(total_amount)/10000000),2) AS total_revenue,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_orders), 2) AS pct_of_orders
FROM fact_orders
GROUP BY payment_mode
ORDER BY total_orders DESC;


-- 7. Revenue split: new vs returning vs premium customers
SELECT
    c.customer_segment,
    COUNT(DISTINCT f.customer_id) AS unique_customers,
    COUNT(f.order_id) AS total_orders,
    ROUND((SUM(f.total_amount)/10000000),2) AS total_revenue_cr,
    ROUND(AVG(f.total_amount), 2) AS avg_order_value_Rs
FROM fact_orders f
JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE f.order_status != 'Cancelled'
GROUP BY c.customer_segment
ORDER BY total_revenue_cr DESC;


-- 8. Customer repeat purchase rate (one-time vs repeat buyers)
SELECT
    CASE WHEN order_count = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM fact_orders
    WHERE order_status != 'Cancelled'
    GROUP BY customer_id
) t
GROUP BY customer_type;


-- 9. Delivery performance by store: promised vs actual time
-- (excludes cancelled deliveries -- there's no real delivery time to measure)
SELECT
    s.store_id, s.store_name,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(d.promised_time_minutes), 2) AS avg_promised_minutes,
    ROUND(AVG(d.actual_delivery_time_minutes), 2) AS avg_actual_minutes,
    ROUND(AVG(d.delay_minutes), 2) AS avg_delay_minutes,
    SUM(CASE WHEN d.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_count
FROM fact_deliveries d
JOIN dim_stores s ON d.store_id = s.store_id
WHERE d.delivery_status != 'Cancelled'
GROUP BY s.store_id, s.store_name
ORDER BY avg_delay_minutes DESC;


-- 10. Rider performance leaderboard (top 10 by delivery volume)
SELECT
    r.rider_id, r.rider_name, r.vehicle_type, r.rating,
    COUNT(d.delivery_id) AS deliveries_handled,
    ROUND(AVG(d.actual_delivery_time_minutes), 2) AS avg_delivery_time,
    SUM(CASE WHEN d.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_deliveries
FROM fact_deliveries d
JOIN dim_riders r ON d.rider_id = r.rider_id
WHERE d.delivery_status != 'Cancelled'
GROUP BY r.rider_id, r.rider_name, r.vehicle_type, r.rating
ORDER BY deliveries_handled DESC
LIMIT 10;


-- 11. Inventory stockout / low-stock frequency by store
SELECT
    s.store_id, s.store_name,
    COUNT(*) AS total_inventory_checks,
    SUM(CASE WHEN i.restock_flag = 'Yes' THEN 1 ELSE 0 END) AS low_stock_events,
    ROUND(SUM(CASE WHEN i.restock_flag = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS low_stock_pct
FROM fact_inventory i
JOIN dim_stores s ON i.store_id = s.store_id
GROUP BY s.store_id, s.store_name
ORDER BY low_stock_pct DESC;


-- 12. Weekday vs weekend order pattern
SELECT
    d.is_weekend,
    ROUND((COUNT(f.order_id)/100000),2) AS total_orders_lakhs,
    ROUND(((SUM(f.total_amount))/10000000),2) AS total_revenue_cr,
    ROUND(AVG(f.total_amount), 2) AS avg_order_value_Rs
FROM fact_orders f
JOIN dim_date d ON f.order_date = d.date_key
WHERE f.order_status != 'Cancelled'
GROUP BY d.is_weekend;


-- 13. Store ramp-up: average daily order volume since each store's opening date
SELECT
    s.store_id, s.store_name, s.opening_date,
    COUNT(f.order_id) AS total_orders,
    DATEDIFF(MAX(f.order_date), s.opening_date) + 1 AS days_active,
    ROUND(COUNT(f.order_id) * 1.0 / (DATEDIFF(MAX(f.order_date), s.opening_date) + 1), 2) AS avg_orders_per_day
FROM fact_orders f
JOIN dim_stores s ON f.store_id = s.store_id
WHERE f.order_status != 'Cancelled'
GROUP BY s.store_id, s.store_name, s.opening_date
ORDER BY avg_orders_per_day DESC;
