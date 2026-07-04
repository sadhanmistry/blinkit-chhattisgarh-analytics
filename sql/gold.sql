-- ============================================================================
-- STEP 1: DATABASE CREATION:- blinkit_gold
-- ============================================================================
CREATE DATABASE blinkit_gold;

USE blinkit_gold;

SHOW DATABASES;

-- ============================================================================
-- STEP 2: Executer this i python notebook file:- 04_gold_layer_build.ipynb
-- it creates and load the final cleaned data into blinkit_gold database
-- ============================================================================

-- After this
-- Verify

SHOW TABLES;

DESCRIBE dim_date;
DESCRIBE dim_stores;
DESCRIBE dim_riders;
DESCRIBE dim_products;
DESCRIBE dim_customers;
DESCRIBE fact_orders;
DESCRIBE fact_order_items;
DESCRIBE fact_deliveries;
DESCRIBE fact_inventory;


-- ============================================================================
-- STEP 3: DATABASE CREATION:- blinkit_silver
-- ============================================================================

-- ============================================================================
-- STEP 4: Blinkit Gold — Primary Key & Foreign Key constraints
-- Run AFTER 04_gold_layer_build.ipynb completes successfully.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- STEP 4.1: Primary keys on every dimension and fact table
-- ----------------------------------------------------------------------------

ALTER TABLE dim_date        ADD PRIMARY KEY (date_key);
ALTER TABLE dim_stores      ADD PRIMARY KEY (store_id);
ALTER TABLE dim_customers   ADD PRIMARY KEY (customer_id);
ALTER TABLE dim_products    ADD PRIMARY KEY (product_id);
ALTER TABLE dim_riders      ADD PRIMARY KEY (rider_id);

ALTER TABLE fact_orders       ADD PRIMARY KEY (order_id);
ALTER TABLE fact_order_items  ADD PRIMARY KEY (order_item_id);
ALTER TABLE fact_deliveries   ADD PRIMARY KEY (delivery_id);
ALTER TABLE fact_inventory    ADD PRIMARY KEY (inventory_id);


-- ----------------------------------------------------------------------------
-- STEP 4.2: Foreign keys from fact tables to dimensions
-- ----------------------------------------------------------------------------

ALTER TABLE fact_orders
  ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
  ADD CONSTRAINT fk_orders_store    FOREIGN KEY (store_id)    REFERENCES dim_stores(store_id),
  ADD CONSTRAINT fk_orders_date     FOREIGN KEY (order_date)  REFERENCES dim_date(date_key);

ALTER TABLE fact_order_items
  ADD CONSTRAINT fk_items_order   FOREIGN KEY (order_id)   REFERENCES fact_orders(order_id),
  ADD CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES dim_products(product_id);

ALTER TABLE fact_deliveries
  ADD CONSTRAINT fk_deliveries_order FOREIGN KEY (order_id)    REFERENCES fact_orders(order_id),
  ADD CONSTRAINT fk_deliveries_rider FOREIGN KEY (rider_id)    REFERENCES dim_riders(rider_id),
  ADD CONSTRAINT fk_deliveries_store FOREIGN KEY (store_id)    REFERENCES dim_stores(store_id),
  ADD CONSTRAINT fk_deliveries_date  FOREIGN KEY (order_date)  REFERENCES dim_date(date_key);

ALTER TABLE fact_inventory
  ADD CONSTRAINT fk_inventory_store   FOREIGN KEY (store_id)      REFERENCES dim_stores(store_id),
  ADD CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)    REFERENCES dim_products(product_id),
  ADD CONSTRAINT fk_inventory_date    FOREIGN KEY (snapshot_date) REFERENCES dim_date(date_key);


-- ----------------------------------------------------------------------------
-- STEP 4.3: Confirm
-- ----------------------------------------------------------------------------
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'blinkit_gold' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;

