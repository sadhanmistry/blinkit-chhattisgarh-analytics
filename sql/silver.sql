
-- ============================================================================
-- STEP 1: DATABASE CREATION:- blinkit_silver
-- ============================================================================
CREATE DATABASE blinkit_silver;

USE blinkit_silver;

SHOW DATABASES;


-- ============================================================================
-- STEP 2: TABLE CREATION:- Exact from blinkit_bronze
-- ============================================================================

CREATE TABLE blinkit_silver.stores LIKE blinkit_bronze.stores;

CREATE TABLE blinkit_silver.customers LIKE blinkit_bronze.customers;

CREATE TABLE blinkit_silver.products LIKE blinkit_bronze.products;

CREATE TABLE blinkit_silver.orders LIKE blinkit_bronze.orders;

CREATE TABLE blinkit_silver.order_items LIKE blinkit_bronze.order_items;

CREATE TABLE blinkit_silver.deliveries LIKE blinkit_bronze.deliveries;

CREATE TABLE blinkit_silver.inventory LIKE blinkit_bronze.inventory;

CREATE TABLE blinkit_silver.riders LIKE blinkit_bronze.riders;

-- Verifying
SHOW TABLES;


-- ============================================================================
-- STEP 3: DATA INSERTION:- FROM blinkit_bronze
-- ============================================================================

INSERT INTO blinkit_silver.stores
SELECT * FROM blinkit_bronze.stores;

INSERT INTO blinkit_silver.customers
SELECT * FROM blinkit_bronze.customers;

INSERT INTO blinkit_silver.products
SELECT * FROM blinkit_bronze.products;

INSERT INTO blinkit_silver.orders
SELECT * FROM blinkit_bronze.orders;

INSERT INTO blinkit_silver.order_items
SELECT * FROM blinkit_bronze.order_items;

INSERT INTO blinkit_silver.deliveries
SELECT * FROM blinkit_bronze.deliveries;

INSERT INTO blinkit_silver.inventory
SELECT * FROM blinkit_bronze.inventory;

INSERT INTO blinkit_silver.riders
SELECT * FROM blinkit_bronze.riders;


-- ===========================================================================================
-- STEP 4: VERIFYING both database have same data:- blinkit_bronze = blinkit_silver
-- ===========================================================================================

SELECT COUNT(*) FROM blinkit_bronze.customers;
SELECT COUNT(*) FROM blinkit_silver.customers;

SELECT COUNT(*) FROM blinkit_bronze.deliveries;
SELECT COUNT(*) FROM blinkit_silver.deliveries;

SELECT COUNT(*) FROM blinkit_bronze.inventory;
SELECT COUNT(*) FROM blinkit_silver.inventory;

SELECT COUNT(*) FROM blinkit_bronze.order_items;
SELECT COUNT(*) FROM blinkit_silver.order_items;

SELECT COUNT(*) FROM blinkit_bronze.orders;
SELECT COUNT(*) FROM blinkit_silver.orders;

SELECT COUNT(*) FROM blinkit_bronze.products;
SELECT COUNT(*) FROM blinkit_silver.products;

SELECT COUNT(*) FROM blinkit_bronze.riders;
SELECT COUNT(*) FROM blinkit_silver.riders;

SELECT COUNT(*) FROM blinkit_bronze.stores;
SELECT COUNT(*) FROM blinkit_silver.stores;



select * from stores;
-- here, we do not need the base_weight column, so we can drop this
ALTER TABLE stores DROP COLUMN base_weight;



-- ============================================================================
-- STEP 5: Pre-checks -- run these first to confirm no string column exceeds
-- the VARCHAR size used in the ALTER statements below.
-- ============================================================================

DESCRIBE stores;
DESCRIBE riders;
DESCRIBE products;
DESCRIBE customers;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE deliveries;
DESCRIBE inventory;


SELECT MAX(LENGTH(store_id)) store_id, MAX(LENGTH(store_name)) store_name,
       MAX(LENGTH(city)) city, MAX(LENGTH(area)) area,
       MAX(LENGTH(store_status)) store_status, MAX(LENGTH(manager_name)) manager_name,
       MAX(LENGTH(state)) state
FROM stores;

SELECT MAX(LENGTH(rider_id)) rider_id, MAX(LENGTH(rider_name)) rider_name,
       MAX(LENGTH(gender)) gender, MAX(LENGTH(vehicle_type)) vehicle_type,
       MAX(LENGTH(assigned_store_id)) assigned_store_id
FROM riders;

SELECT MAX(LENGTH(customer_id)) customer_id, MAX(LENGTH(customer_name)) customer_name,
       MAX(LENGTH(gender)) gender, MAX(LENGTH(city)) city, MAX(LENGTH(area)) area,
       MAX(LENGTH(customer_segment)) customer_segment,
       MAX(LENGTH(preferred_payment_mode)) preferred_payment_mode
FROM customers;

SELECT MAX(LENGTH(product_id)) product_id, MAX(LENGTH(product_name)) product_name,
       MAX(LENGTH(category)) category, MAX(LENGTH(sub_category)) sub_category,
       MAX(LENGTH(brand)) brand, MAX(LENGTH(unit)) unit
FROM products;

SELECT MAX(LENGTH(order_id)) order_id, MAX(LENGTH(customer_id)) customer_id,
       MAX(LENGTH(store_id)) store_id, MAX(LENGTH(payment_mode)) payment_mode,
       MAX(LENGTH(order_status)) order_status, MAX(LENGTH(order_time)) order_time
FROM orders;

SELECT MAX(LENGTH(order_item_id)) order_item_id, MAX(LENGTH(order_id)) order_id,
       MAX(LENGTH(product_id)) product_id
FROM order_items;

SELECT MAX(LENGTH(delivery_id)) delivery_id, MAX(LENGTH(order_id)) order_id,
       MAX(LENGTH(rider_id)) rider_id, MAX(LENGTH(store_id)) store_id,
       MAX(LENGTH(delivery_status)) delivery_status
FROM deliveries;

SELECT MAX(LENGTH(inventory_id)) inventory_id, MAX(LENGTH(store_id)) store_id,
       MAX(LENGTH(product_id)) product_id, MAX(LENGTH(restock_flag)) restock_flag
FROM inventory;


DESCRIBE stores;
DESCRIBE riders;
DESCRIBE products;
DESCRIBE customers;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE deliveries;
DESCRIBE inventory;



-- ============================================================================
-- STEP 6: ALTER TABLE -- Restructring columns data types
-- ============================================================================

ALTER TABLE stores
  MODIFY COLUMN store_id VARCHAR(10),
  MODIFY COLUMN store_name VARCHAR(100),
  MODIFY COLUMN city VARCHAR(50),
  MODIFY COLUMN area VARCHAR(50),
  MODIFY COLUMN latitude DECIMAL(9,6),
  MODIFY COLUMN longitude DECIMAL(9,6),
  MODIFY COLUMN store_size_sqft INT,
  MODIFY COLUMN opening_date DATE,
  MODIFY COLUMN store_status VARCHAR(20),
  MODIFY COLUMN manager_name VARCHAR(100),
  MODIFY COLUMN state VARCHAR(50);

ALTER TABLE riders
  MODIFY COLUMN rider_id VARCHAR(10),
  MODIFY COLUMN rider_name VARCHAR(100),
  MODIFY COLUMN gender VARCHAR(10),
  MODIFY COLUMN age INT,
  MODIFY COLUMN vehicle_type VARCHAR(20),
  MODIFY COLUMN assigned_store_id VARCHAR(10),
  MODIFY COLUMN rating DECIMAL(3,1),
  MODIFY COLUMN total_deliveries_lifetime INT,
  MODIFY COLUMN joining_date DATE;

ALTER TABLE customers
  MODIFY COLUMN customer_id VARCHAR(10),
  MODIFY COLUMN customer_name VARCHAR(100),
  MODIFY COLUMN gender VARCHAR(10),
  MODIFY COLUMN age INT,
  MODIFY COLUMN city VARCHAR(50),
  MODIFY COLUMN area VARCHAR(50),
  MODIFY COLUMN registered_date DATE,
  MODIFY COLUMN customer_segment VARCHAR(20),
  MODIFY COLUMN preferred_payment_mode VARCHAR(30);

ALTER TABLE products
  MODIFY COLUMN product_id VARCHAR(10),
  MODIFY COLUMN product_name VARCHAR(150),
  MODIFY COLUMN category VARCHAR(50),
  MODIFY COLUMN sub_category VARCHAR(50),
  MODIFY COLUMN brand VARCHAR(50),
  MODIFY COLUMN unit VARCHAR(10),
  MODIFY COLUMN mrp DECIMAL(10,2),
  MODIFY COLUMN selling_price DECIMAL(10,2),
  MODIFY COLUMN discount_pct INT,
  MODIFY COLUMN shelf_life_days INT;

ALTER TABLE orders
  MODIFY COLUMN order_id VARCHAR(15),
  MODIFY COLUMN customer_id VARCHAR(10),
  MODIFY COLUMN store_id VARCHAR(10),
  MODIFY COLUMN order_date DATE,
  MODIFY COLUMN order_time TIME,
  MODIFY COLUMN payment_mode VARCHAR(30),
  MODIFY COLUMN order_status VARCHAR(20),
  MODIFY COLUMN discount_amount DECIMAL(10,2),
  MODIFY COLUMN total_amount DECIMAL(10,2);

ALTER TABLE order_items
  MODIFY COLUMN order_item_id VARCHAR(15),
  MODIFY COLUMN order_id VARCHAR(15),
  MODIFY COLUMN product_id VARCHAR(10),
  MODIFY COLUMN quantity INT,
  MODIFY COLUMN unit_price DECIMAL(10,2),
  MODIFY COLUMN line_total DECIMAL(10,2);

ALTER TABLE deliveries
  MODIFY COLUMN delivery_id VARCHAR(15),
  MODIFY COLUMN order_id VARCHAR(15),
  MODIFY COLUMN rider_id VARCHAR(10) NULL,
  MODIFY COLUMN store_id VARCHAR(10),
  MODIFY COLUMN promised_time_minutes INT,
  MODIFY COLUMN actual_delivery_time_minutes DECIMAL(6,1) NULL,
  MODIFY COLUMN distance_km DECIMAL(5,2),
  MODIFY COLUMN delivery_status VARCHAR(20);


ALTER TABLE inventory
  MODIFY COLUMN inventory_id VARCHAR(15),
  MODIFY COLUMN store_id VARCHAR(10),
  MODIFY COLUMN product_id VARCHAR(10),
  MODIFY COLUMN snapshot_date DATE,
  MODIFY COLUMN stock_quantity INT,
  MODIFY COLUMN reorder_level INT,
  MODIFY COLUMN restock_flag VARCHAR(5);


-- ============================================================================
-- STEP 7: Confirm
-- ============================================================================

DESCRIBE stores;
DESCRIBE riders;
DESCRIBE products;
DESCRIBE customers;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE deliveries;
DESCRIBE inventory;


SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
FROM information_schema.columns
WHERE TABLE_SCHEMA = 'blinkit_silver'
ORDER BY TABLE_NAME, ORDINAL_POSITION;



-- When we import this table as pandas dataframe, the order_date column convert into deltatime, which convert the date_time column
-- So keep this column as TEXT for pandas
ALTER TABLE orders  MODIFY COLUMN order_time TEXT;




