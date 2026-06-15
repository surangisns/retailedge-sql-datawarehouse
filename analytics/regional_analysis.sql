-- ============================================================
-- RetailEdge Analytics | Regional Analysis
-- Sales by Region · Zone Performance
-- ============================================================

-- 5. Sales by Region
SELECT
    r.region_name, r.state, r.country, r.zone,
    COUNT(DISTINCT f.order_id)        AS orders,
    SUM(f.quantity_sold)              AS units_sold,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    ROUND(SUM(f.net_sales_amount) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_region r ON f.region_key = r.region_key
GROUP BY r.region_name, r.state, r.country, r.zone
ORDER BY revenue DESC;

-- Sales by Zone
SELECT
    COALESCE(r.zone, 'Unknown')       AS zone,
    COUNT(DISTINCT f.order_id)        AS orders,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue
FROM gold.fact_sales f
JOIN gold.dim_region r ON f.region_key = r.region_key
GROUP BY r.zone
ORDER BY revenue DESC;

-- Regional Monthly Trend (top 5 regions)
SELECT
    r.region_name, d.year, d.month_number, TRIM(d.month_name) AS month_name,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue
FROM gold.fact_sales f
JOIN gold.dim_region r ON f.region_key = r.region_key
JOIN gold.dim_date   d ON f.date_key   = d.date_key
GROUP BY r.region_name, d.year, d.month_number, d.month_name
ORDER BY r.region_name, d.year, d.month_number;
