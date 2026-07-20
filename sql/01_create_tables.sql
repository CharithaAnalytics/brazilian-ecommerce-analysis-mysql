/* =========================================================

Project : Brazilian E-commerce Analysis

Script  : 01_create_tables.sql

Purpose :
- Creating all the tables for the analytical database.
- No constraints or indexes are created in this script for quicker data loading.
  They will be created after profiling the data.

========================================================= */

CREATE DATABASE brazilian_ecommerce;
USE brazilian_ecommerce;

-- CUSTOMERS

CREATE TABLE customers
(
    customer_id CHAR(32),
    customer_unique_id CHAR(32),
    zip_code_prefix CHAR(5),
    city VARCHAR(100),
    state CHAR(2)
);

-- SELLERS

CREATE TABLE sellers
(
    seller_id CHAR(32),
    zip_code_prefix CHAR(5),
    city VARCHAR(100),
    state CHAR(2)
);

-- PRODUCTS

CREATE TABLE products
(
    product_id CHAR(32),
    category_name VARCHAR(60),
    name_length SMALLINT,
    description_length SMALLINT,
    photo_qty TINYINT,
    weight_g MEDIUMINT,
    length_cm SMALLINT,
    height_cm SMALLINT,
    width_cm SMALLINT
);

-- ORDERS

CREATE TABLE orders
(
    order_id CHAR(32),
    customer_id CHAR(32),
    status VARCHAR(20),
    purchased_at DATETIME,
    approved_at DATETIME,
    carrier_at DATETIME,
    delivered_at DATETIME,
    estimated_delivery DATETIME
);

-- ORDER ITEMS

CREATE TABLE order_items
(
    order_id CHAR(32),
    item_no TINYINT,
    product_id CHAR(32),
    seller_id CHAR(32),
    shipping_limit DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

-- PAYMENTS

CREATE TABLE order_payments
(
    order_id CHAR(32),
    payment_seq TINYINT,
    payment_type VARCHAR(20),
	installments TINYINT,
    payment_value DECIMAL(10,2)
);

-- REVIEWS

CREATE TABLE order_reviews
(
    review_id CHAR(32),
    order_id CHAR(32),
    score TINYINT,
    title VARCHAR(255),
    message TEXT,
    created_at DATETIME,
    answered_at DATETIME
);

-- GEOLOCATION

CREATE TABLE geolocation
(
    zip_code_prefix CHAR(5),
    latitude DOUBLE,
    longitude DOUBLE,
    city VARCHAR(100),
    state CHAR(2)
);

-- CATEGORY TRANSLATION

CREATE TABLE category_translation
(
    category VARCHAR(60),
    category_english VARCHAR(60)
);

/* ===========================================================================

End of creating tables

Next step: 02_load_data
- Loading the data from the Olist Brazilian E-commerce data set.

=========================================================================== */