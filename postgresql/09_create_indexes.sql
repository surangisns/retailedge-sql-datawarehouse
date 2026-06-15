-- ============================================================
-- RetailEdge Analytics | PostgreSQL
-- Script 09: Create Indexes
-- ============================================================

CREATE INDEX ix_fact_sales_date_key     ON gold.fact_sales (date_key);
CREATE INDEX ix_fact_sales_customer_key ON gold.fact_sales (customer_key);
CREATE INDEX ix_fact_sales_product_key  ON gold.fact_sales (product_key);
CREATE INDEX ix_fact_sales_region_key   ON gold.fact_sales (region_key);
CREATE INDEX ix_fact_sales_channel_key  ON gold.fact_sales (channel_key);
CREATE INDEX ix_fact_sales_status       ON gold.fact_sales (order_status);
CREATE INDEX ix_fact_returns_date_key   ON gold.fact_returns (date_key);
CREATE INDEX ix_fact_returns_product    ON gold.fact_returns (product_key);
CREATE INDEX ix_dim_customer_segment    ON gold.dim_customer (customer_segment);
CREATE INDEX ix_dim_product_category    ON gold.dim_product  (category);
CREATE INDEX ix_dim_date_year_month     ON gold.dim_date     (year, month_number);
