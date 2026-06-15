-- ============================================================
-- RetailEdge Analytics | SQL Server
-- Script 08: Create and Load Gold Fact Tables
-- ============================================================

USE RetailEdgeWarehouse;
GO

-- ── fact_sales ───────────────────────────────────────────────
DROP TABLE IF EXISTS gold.fact_sales;
CREATE TABLE gold.fact_sales (
    sale_key            BIGINT IDENTITY(1,1) NOT NULL,
    order_id            INT,
    item_id             INT,
    date_key            INT,
    customer_key        BIGINT,
    product_key         BIGINT,
    region_key          BIGINT,
    channel_key         BIGINT,
    quantity_sold       INT,
    unit_price          DECIMAL(10,2),
    discount_amount     DECIMAL(10,2),
    gross_sales_amount  DECIMAL(10,2),
    net_sales_amount    DECIMAL(10,2),
    order_status        NVARCHAR(30),
    payment_method      NVARCHAR(50),
    dwh_load_ts         DATETIME DEFAULT GETDATE(),
    CONSTRAINT pk_fact_sales PRIMARY KEY (sale_key),
    CONSTRAINT fk_fs_date     FOREIGN KEY (date_key)     REFERENCES gold.dim_date(date_key),
    CONSTRAINT fk_fs_customer FOREIGN KEY (customer_key) REFERENCES gold.dim_customer(customer_key),
    CONSTRAINT fk_fs_product  FOREIGN KEY (product_key)  REFERENCES gold.dim_product(product_key),
    CONSTRAINT fk_fs_region   FOREIGN KEY (region_key)   REFERENCES gold.dim_region(region_key),
    CONSTRAINT fk_fs_channel  FOREIGN KEY (channel_key)  REFERENCES gold.dim_sales_channel(channel_key)
);

INSERT INTO gold.fact_sales (
    order_id, item_id, date_key, customer_key, product_key,
    region_key, channel_key, quantity_sold, unit_price, discount_amount,
    gross_sales_amount, net_sales_amount, order_status, payment_method
)
SELECT
    o.order_id, oi.item_id,
    CAST(FORMAT(o.order_date,'yyyyMMdd') AS INT),
    dc.customer_key,
    dp.product_key,
    dr.region_key,
    dsc.channel_key,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    oi.quantity * oi.unit_price,
    oi.line_total,
    o.order_status,
    o.payment_method
FROM silver.order_items oi
JOIN silver.orders       o   ON oi.order_id   = o.order_id
JOIN gold.dim_customer   dc  ON o.customer_id  = dc.customer_id
JOIN gold.dim_product    dp  ON oi.product_id  = dp.product_id
LEFT JOIN gold.dim_region    dr  ON o.region_id   = dr.region_id
LEFT JOIN gold.dim_sales_channel dsc ON o.channel_id = dsc.channel_id
WHERE o.order_date IS NOT NULL;
GO

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' rows loaded into fact_sales.';

-- ── fact_returns ─────────────────────────────────────────────
DROP TABLE IF EXISTS gold.fact_returns;
CREATE TABLE gold.fact_returns (
    return_key          BIGINT IDENTITY(1,1) NOT NULL,
    return_id           INT,
    order_id            INT,
    date_key            INT,
    product_key         BIGINT,
    return_reason       NVARCHAR(300),
    refund_amount       DECIMAL(10,2),
    return_status       NVARCHAR(30),
    dwh_load_ts         DATETIME DEFAULT GETDATE(),
    CONSTRAINT pk_fact_returns PRIMARY KEY (return_key),
    CONSTRAINT fk_fr_date    FOREIGN KEY (date_key)    REFERENCES gold.dim_date(date_key),
    CONSTRAINT fk_fr_product FOREIGN KEY (product_key) REFERENCES gold.dim_product(product_key)
);

INSERT INTO gold.fact_returns (
    return_id, order_id, date_key, product_key,
    return_reason, refund_amount, return_status
)
SELECT
    r.return_id, r.order_id,
    CAST(FORMAT(r.return_date,'yyyyMMdd') AS INT),
    dp.product_key,
    r.return_reason, r.refund_amount, r.return_status
FROM silver.returns r
JOIN gold.dim_product dp ON r.product_id = dp.product_id
WHERE r.return_date IS NOT NULL;
GO

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' rows loaded into fact_returns.';
