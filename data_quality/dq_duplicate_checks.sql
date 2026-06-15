-- ============================================================
-- RetailEdge Analytics | Data Quality
-- Duplicate Record Checks
-- ============================================================

-- Bronze: Duplicate customer emails
SELECT email, COUNT(*) AS duplicate_count
FROM bronze.raw_customers
GROUP BY email HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Bronze: Duplicate product IDs
SELECT product_id, COUNT(*) AS duplicate_count
FROM bronze.raw_products
GROUP BY product_id HAVING COUNT(*) > 1;

-- Bronze: Duplicate order IDs
SELECT order_id, COUNT(*) AS duplicate_count
FROM bronze.raw_orders
GROUP BY order_id HAVING COUNT(*) > 1;

-- Bronze: Duplicate region names (same name, different ID)
SELECT region_name, COUNT(DISTINCT region_id) AS id_count
FROM bronze.raw_regions
GROUP BY region_name HAVING COUNT(DISTINCT region_id) > 1;

-- Bronze: Duplicate sales channel names
SELECT channel_name, COUNT(*) AS cnt
FROM bronze.raw_sales_channels
GROUP BY channel_name HAVING COUNT(*) > 1;

-- Silver: Confirm no duplicates remain after cleaning
SELECT 'silver.customers'  AS tbl, COUNT(*) - COUNT(DISTINCT customer_id) AS dupes FROM silver.customers UNION ALL
SELECT 'silver.products',  COUNT(*) - COUNT(DISTINCT product_id)  FROM silver.products  UNION ALL
SELECT 'silver.orders',    COUNT(*) - COUNT(DISTINCT order_id)    FROM silver.orders;
