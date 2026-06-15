-- ============================================================
-- RetailEdge Analytics | Data Quality
-- Referential Integrity Checks
-- ============================================================

-- Bronze: Orders with no matching customer
SELECT COUNT(*) AS orphaned_orders
FROM bronze.raw_orders o
LEFT JOIN bronze.raw_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Bronze: Order items with no matching order
SELECT COUNT(*) AS orphaned_items
FROM bronze.raw_order_items oi
LEFT JOIN bronze.raw_orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Bronze: Order items with no matching product
SELECT COUNT(*) AS items_with_no_product
FROM bronze.raw_order_items
WHERE product_id IS NULL OR TRIM(product_id) = '';

-- Bronze: Returns with no matching order
SELECT COUNT(*) AS returns_no_order
FROM bronze.raw_returns r
LEFT JOIN bronze.raw_orders o ON r.order_id = o.order_id
WHERE r.order_id IS NOT NULL AND o.order_id IS NULL;

-- Gold: fact_sales with no matching dim_customer (should be 0)
SELECT COUNT(*) AS unmatched_customers
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customer dc ON fs.customer_key = dc.customer_key
WHERE dc.customer_key IS NULL;

-- Gold: fact_sales with no matching dim_product (should be 0)
SELECT COUNT(*) AS unmatched_products
FROM gold.fact_sales fs
LEFT JOIN gold.dim_product dp ON fs.product_key = dp.product_key
WHERE dp.product_key IS NULL;
