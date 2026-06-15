-- ============================================================
-- RetailEdge Analytics | Data Quality
-- Row Count and Sales Total Reconciliation
-- ============================================================

-- Row count reconciliation across all layers
SELECT 'CUSTOMERS'   AS entity,
    (SELECT COUNT(*) FROM bronze.raw_customers)  AS bronze_rows,
    (SELECT COUNT(*) FROM silver.customers)      AS silver_rows,
    (SELECT COUNT(*) FROM gold.dim_customer)     AS gold_rows
UNION ALL
SELECT 'PRODUCTS',
    (SELECT COUNT(*) FROM bronze.raw_products),
    (SELECT COUNT(*) FROM silver.products),
    (SELECT COUNT(*) FROM gold.dim_product)
UNION ALL
SELECT 'ORDERS',
    (SELECT COUNT(*) FROM bronze.raw_orders),
    (SELECT COUNT(*) FROM silver.orders),
    (SELECT COUNT(*) FROM gold.fact_sales)
UNION ALL
SELECT 'ORDER ITEMS',
    (SELECT COUNT(*) FROM bronze.raw_order_items),
    (SELECT COUNT(*) FROM silver.order_items),
    NULL
UNION ALL
SELECT 'RETURNS',
    (SELECT COUNT(*) FROM bronze.raw_returns),
    (SELECT COUNT(*) FROM silver.returns),
    (SELECT COUNT(*) FROM gold.fact_returns);

-- Sales total reconciliation: Silver vs Gold
SELECT
    'Silver total'                          AS source,
    ROUND(SUM(line_total), 2)               AS total_sales
FROM silver.order_items
UNION ALL
SELECT 'Gold fact_sales total',
    ROUND(SUM(net_sales_amount), 2)
FROM gold.fact_sales;

-- Line total mismatch check in Silver
SELECT order_id, item_id,
    quantity * unit_price - discount_amount AS calculated_total,
    line_total                              AS stored_total,
    ABS((quantity * unit_price - discount_amount) - line_total) AS variance
FROM silver.order_items
WHERE ABS((quantity * unit_price - discount_amount) - line_total) > 0.01;
