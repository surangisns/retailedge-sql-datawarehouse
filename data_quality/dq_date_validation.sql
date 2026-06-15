-- ============================================================
-- RetailEdge Analytics | Data Quality
-- Date Validation Checks
-- ============================================================

-- Bronze: Delivery date before shipping date
SELECT order_id, shipping_date, delivery_date
FROM bronze.raw_orders
WHERE TRY_CAST(delivery_date AS DATE) < TRY_CAST(shipping_date AS DATE);

-- Bronze: Return date before order date
SELECT r.return_id, r.order_id, r.return_date, o.order_date
FROM bronze.raw_returns r
JOIN bronze.raw_orders  o ON r.order_id = o.order_id
WHERE TRY_CAST(r.return_date AS DATE) < TRY_CAST(o.order_date AS DATE);

-- Bronze: Promotion end before start
SELECT promo_id, promo_name, start_date, end_date
FROM bronze.raw_promotions
WHERE TRY_CAST(end_date AS DATE) < TRY_CAST(start_date AS DATE);

-- Silver: Confirm fixes applied (should return 0 rows)
SELECT COUNT(*) AS delivery_before_shipping_remaining
FROM silver.orders
WHERE delivery_date IS NOT NULL AND delivery_date < shipping_date;

-- Gold: Orders with date_key not in dim_date
SELECT COUNT(*) AS unmatched_date_keys
FROM gold.fact_sales fs
LEFT JOIN gold.dim_date d ON fs.date_key = d.date_key
WHERE d.date_key IS NULL;
