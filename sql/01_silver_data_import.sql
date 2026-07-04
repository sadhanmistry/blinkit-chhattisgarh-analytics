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

