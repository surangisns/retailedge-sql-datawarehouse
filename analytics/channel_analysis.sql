-- ============================================================
-- RetailEdge Analytics | Channel Analysis
-- Sales by Channel · Channel Trend
-- ============================================================

-- 6. Sales by Channel
SELECT
    sc.channel_name, sc.channel_type,
    COUNT(DISTINCT f.order_id)        AS orders,
    SUM(f.quantity_sold)              AS units_sold,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    ROUND(SUM(f.net_sales_amount) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS avg_order_value,
    ROUND(SUM(f.gross_sales_amount - f.net_sales_amount), 2) AS total_discount_given
FROM gold.fact_sales f
JOIN gold.dim_sales_channel sc ON f.channel_key = sc.channel_key
GROUP BY sc.channel_name, sc.channel_type
ORDER BY revenue DESC;

-- Channel Revenue Share %
SELECT
    sc.channel_name,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    ROUND(
        SUM(f.net_sales_amount) * 100.0 /
        NULLIF(SUM(SUM(f.net_sales_amount)) OVER (), 0), 2
    ) AS revenue_share_pct
FROM gold.fact_sales f
JOIN gold.dim_sales_channel sc ON f.channel_key = sc.channel_key
GROUP BY sc.channel_name
ORDER BY revenue DESC;

-- Channel Trend by Month
SELECT
    sc.channel_name, d.year, d.month_number, TRIM(d.month_name) AS month_name,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    COUNT(DISTINCT f.order_id)        AS orders
FROM gold.fact_sales f
JOIN gold.dim_sales_channel sc ON f.channel_key = sc.channel_key
JOIN gold.dim_date           d  ON f.date_key    = d.date_key
GROUP BY sc.channel_name, d.year, d.month_number, d.month_name
ORDER BY sc.channel_name, d.year, d.month_number;

-- Payment Method Breakdown
SELECT
    f.payment_method,
    COUNT(DISTINCT f.order_id)        AS orders,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    ROUND(SUM(f.net_sales_amount) * 100.0 / NULLIF(SUM(SUM(f.net_sales_amount)) OVER (), 0), 2) AS pct
FROM gold.fact_sales f
GROUP BY f.payment_method
ORDER BY revenue DESC;
