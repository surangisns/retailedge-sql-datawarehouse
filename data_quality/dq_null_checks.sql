-- ============================================================
-- RetailEdge Analytics | Data Quality
-- Null Value Checks
-- ============================================================

-- Bronze: Critical nulls in customers
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN customer_id   IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN email         IS NULL OR TRIM(email) = '' THEN 1 ELSE 0 END) AS null_email,
    SUM(CASE WHEN first_name    IS NULL THEN 1 ELSE 0 END) AS null_first_name,
    SUM(CASE WHEN dob           IS NULL THEN 1 ELSE 0 END) AS null_dob,
    SUM(CASE WHEN phone         IS NULL THEN 1 ELSE 0 END) AS null_phone
FROM bronze.raw_customers;

-- Bronze: Negative values in products and order_items
SELECT 'negative unit_cost' AS issue, COUNT(*) AS cnt
FROM bronze.raw_products WHERE CAST(unit_cost AS FLOAT) < 0
UNION ALL
SELECT 'negative quantity', COUNT(*)
FROM bronze.raw_order_items WHERE CAST(quantity AS FLOAT) < 0
UNION ALL
SELECT 'negative line_total', COUNT(*)
FROM bronze.raw_order_items WHERE CAST(line_total AS FLOAT) < 0;

-- Gold: Null foreign keys in fact_sales
SELECT
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS null_customer_key,
    SUM(CASE WHEN product_key  IS NULL THEN 1 ELSE 0 END) AS null_product_key,
    SUM(CASE WHEN date_key     IS NULL THEN 1 ELSE 0 END) AS null_date_key,
    SUM(CASE WHEN net_sales_amount IS NULL THEN 1 ELSE 0 END) AS null_sales_amount
FROM gold.fact_sales;
