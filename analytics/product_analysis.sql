-- ============================================================
-- RetailEdge Analytics | Product Analysis
-- Top Products · Return Rate · Category Performance
-- ============================================================

-- 3. Top 10 Products by Revenue
SELECT
    p.product_name, p.category, p.subcategory, p.brand,
    SUM(f.quantity_sold)              AS units_sold,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    ROUND(AVG(p.margin_pct), 2)       AS avg_margin_pct
FROM gold.fact_sales f
JOIN gold.dim_product p ON f.product_key = p.product_key
GROUP BY p.product_name, p.category, p.subcategory, p.brand
ORDER BY revenue DESC
LIMIT 10;

-- 8. Product Return Rate
SELECT
    p.product_name, p.category,
    COUNT(r.return_key)               AS total_returns,
    SUM(f.quantity_sold)              AS units_sold,
    ROUND(
        COUNT(r.return_key) * 100.0 / NULLIF(SUM(f.quantity_sold), 0), 2
    )                                 AS return_rate_pct,
    ROUND(SUM(r.refund_amount), 2)    AS total_refunded
FROM gold.fact_sales f
JOIN gold.dim_product p ON f.product_key = p.product_key
LEFT JOIN gold.fact_returns r ON f.product_key = r.product_key
GROUP BY p.product_name, p.category
ORDER BY return_rate_pct DESC;

-- 9. Product Category Performance
SELECT
    p.category,
    COUNT(DISTINCT p.product_key)     AS product_count,
    SUM(f.quantity_sold)              AS units_sold,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    ROUND(SUM(f.gross_sales_amount - f.net_sales_amount), 2) AS total_discounts,
    ROUND(AVG(p.margin_pct), 2)       AS avg_margin_pct
FROM gold.fact_sales f
JOIN gold.dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC;

-- Brand Performance
SELECT
    p.brand,
    COUNT(DISTINCT p.product_key)     AS products,
    ROUND(SUM(f.net_sales_amount), 2) AS revenue,
    SUM(f.quantity_sold)              AS units_sold
FROM gold.fact_sales f
JOIN gold.dim_product p ON f.product_key = p.product_key
GROUP BY p.brand
ORDER BY revenue DESC;
