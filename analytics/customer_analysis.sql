-- ============================================================
-- RetailEdge Analytics | Customer Analysis
-- Top Customers · Customer Lifetime Value · Segments
-- ============================================================

-- 4. Top 10 Customers by Revenue
SELECT
    c.full_name, c.customer_segment, c.city, c.state,
    COUNT(DISTINCT f.order_id)        AS total_orders,
    SUM(f.quantity_sold)              AS total_units,
    ROUND(SUM(f.net_sales_amount), 2) AS lifetime_value,
    ROUND(SUM(f.net_sales_amount) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.full_name, c.customer_segment, c.city, c.state
ORDER BY lifetime_value DESC
LIMIT 10;

-- 10. Customer Lifetime Value (CLV) with first and last order
SELECT
    c.customer_key, c.full_name, c.customer_segment, c.age_band,
    MIN(d.full_date)                  AS first_order_date,
    MAX(d.full_date)                  AS last_order_date,
    COUNT(DISTINCT f.order_id)        AS total_orders,
    ROUND(SUM(f.net_sales_amount), 2) AS lifetime_value,
    ROUND(SUM(f.net_sales_amount) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_customer c ON f.customer_key = c.customer_key
JOIN gold.dim_date     d ON f.date_key     = d.date_key
GROUP BY c.customer_key, c.full_name, c.customer_segment, c.age_band
ORDER BY lifetime_value DESC;

-- Customer Segment Performance
SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_key)    AS customer_count,
    COUNT(DISTINCT f.order_id)        AS total_orders,
    ROUND(SUM(f.net_sales_amount), 2) AS total_revenue,
    ROUND(AVG(f.net_sales_amount), 2) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;

-- Customer Age Band Analysis
SELECT
    c.age_band,
    COUNT(DISTINCT c.customer_key)    AS customers,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    ROUND(AVG(f.net_sales_amount), 2) AS avg_sale
FROM gold.fact_sales f
JOIN gold.dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.age_band
ORDER BY revenue DESC;
