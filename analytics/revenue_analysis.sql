-- ============================================================
-- RetailEdge Analytics | Revenue Analysis
-- Total Revenue · Monthly Trend · Average Order Value
-- ============================================================

-- 1. Total Revenue (delivered orders only)
SELECT
    ROUND(SUM(net_sales_amount), 2)      AS total_revenue,
    COUNT(DISTINCT order_id)             AS total_orders,
    SUM(quantity_sold)                   AS total_units_sold,
    ROUND(AVG(net_sales_amount), 2)      AS avg_line_value
FROM gold.fact_sales
WHERE order_status = 'delivered';

-- 2. Monthly Sales Trend
SELECT
    d.year, d.month_number, TRIM(d.month_name) AS month_name,
    COUNT(DISTINCT f.order_id)           AS orders,
    SUM(f.quantity_sold)                 AS units_sold,
    ROUND(SUM(f.net_sales_amount), 2)    AS revenue,
    ROUND(SUM(f.gross_sales_amount - f.net_sales_amount), 2) AS total_discount
FROM gold.fact_sales f
JOIN gold.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month_number, d.month_name
ORDER BY d.year, d.month_number;

-- 3. Average Order Value (AOV) by Month
SELECT
    d.year, d.month_number, TRIM(d.month_name) AS month_name,
    COUNT(DISTINCT f.order_id)           AS orders,
    ROUND(SUM(f.net_sales_amount) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_date d ON f.date_key = d.date_key
WHERE f.order_status != 'cancelled'
GROUP BY d.year, d.month_number, d.month_name
ORDER BY d.year, d.month_number;

-- 4. Revenue by Quarter
SELECT
    d.year, d.quarter_name,
    ROUND(SUM(f.net_sales_amount), 2) AS quarterly_revenue,
    COUNT(DISTINCT f.order_id)        AS orders
FROM gold.fact_sales f
JOIN gold.dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.quarter, d.quarter_name
ORDER BY d.year, d.quarter;
