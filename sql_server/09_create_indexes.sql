-- ============================================================
-- RetailEdge Analytics | SQL Server
-- Script 09: Create Indexes
-- Improves Power BI and analytics query performance.
-- ============================================================

USE RetailEdgeWarehouse;
GO

-- fact_sales indexes
CREATE INDEX ix_fact_sales_date_key     ON gold.fact_sales (date_key);
CREATE INDEX ix_fact_sales_customer_key ON gold.fact_sales (customer_key);
CREATE INDEX ix_fact_sales_product_key  ON gold.fact_sales (product_key);
CREATE INDEX ix_fact_sales_region_key   ON gold.fact_sales (region_key);
CREATE INDEX ix_fact_sales_channel_key  ON gold.fact_sales (channel_key);
CREATE INDEX ix_fact_sales_status       ON gold.fact_sales (order_status);

-- fact_returns indexes
CREATE INDEX ix_fact_returns_date_key    ON gold.fact_returns (date_key);
CREATE INDEX ix_fact_returns_product_key ON gold.fact_returns (product_key);

-- dim indexes for lookups
CREATE INDEX ix_dim_customer_segment ON gold.dim_customer (customer_segment);
CREATE INDEX ix_dim_product_category ON gold.dim_product  (category);
CREATE INDEX ix_dim_date_year_month  ON gold.dim_date     (year, month_number);
CREATE INDEX ix_dim_region_country   ON gold.dim_region   (country, zone);
GO

PRINT 'All indexes created.';
