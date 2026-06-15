-- ============================================================
-- RetailEdge Analytics | PostgreSQL
-- Script 04: Load CSV Data into Bronze Tables
-- Update file paths to match your local folder.
-- ============================================================

-- ⚠️  Update paths below to your local datasets folder

\COPY bronze.raw_customers    FROM '/path/to/datasets/customers.csv'     CSV HEADER;
\COPY bronze.raw_products     FROM '/path/to/datasets/products.csv'      CSV HEADER;
\COPY bronze.raw_regions      FROM '/path/to/datasets/regions.csv'       CSV HEADER;
\COPY bronze.raw_sales_channels FROM '/path/to/datasets/sales_channels.csv' CSV HEADER;
\COPY bronze.raw_promotions   FROM '/path/to/datasets/promotions.csv'    CSV HEADER;
\COPY bronze.raw_orders       FROM '/path/to/datasets/orders.csv'        CSV HEADER;
\COPY bronze.raw_order_items  FROM '/path/to/datasets/order_items.csv'   CSV HEADER;
\COPY bronze.raw_returns      FROM '/path/to/datasets/returns.csv'       CSV HEADER;

-- Verify row counts
SELECT 'raw_customers'     AS tbl, COUNT(*) FROM bronze.raw_customers      UNION ALL
SELECT 'raw_products',     COUNT(*) FROM bronze.raw_products                UNION ALL
SELECT 'raw_regions',      COUNT(*) FROM bronze.raw_regions                 UNION ALL
SELECT 'raw_sales_channels', COUNT(*) FROM bronze.raw_sales_channels        UNION ALL
SELECT 'raw_promotions',   COUNT(*) FROM bronze.raw_promotions              UNION ALL
SELECT 'raw_orders',       COUNT(*) FROM bronze.raw_orders                  UNION ALL
SELECT 'raw_order_items',  COUNT(*) FROM bronze.raw_order_items             UNION ALL
SELECT 'raw_returns',      COUNT(*) FROM bronze.raw_returns;
