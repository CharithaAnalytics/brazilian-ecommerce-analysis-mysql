/* ===========================================================

 Project : Brazilian E-commerce Analysis
 03_profile_data.sql

Purpose: To profile the source tables by validating,
1. Row counts 
2. Candidate key and Duplicate key checks
3. Missing values 
4. Basic data distribution and value ranges
5. Business rule consistency
6. Relationship  and referential integrity

This stage focuses on understanding the quality and structure
of the source data. No data cleaning or transformation decisions
are applied in this script. 

============================================================= */

USE brazilian_ecommerce;
SHOW TABLES;

-- -----------------------------------------------
-- Customers Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM customers; 
-- 99,441 records

-- Purpose: 
-- Verifying if there are duplicate primary keys
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM customers;
-- Total rows = 99,441
-- Distinct customer_id = 99,441
-- No duplicate customer_id values were found.

-- Purpose: 
-- Determining whether customer_unique_id uniquely identifies each customer record.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_unique_id) AS distinct_customer_unique_ids
FROM customers;
-- Total rows = 99,441
-- Distinct customer_unique_id = 96,096
-- Multiple customer_id values can be associated with the same customer_unique_id.
-- customer_unique_id will be used for customer-level analysis such as repeat customer analysis,
-- while customer_id remains the primary key for joins with the orders table.

-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(customer_unique_id IS NULL OR customer_unique_id = '') AS missing_unique_customer_id,
    SUM(city IS NULL OR city = '') AS missing_city,
    SUM(state IS NULL OR state = '') AS missing_state
FROM customers;
-- No missing values were found in the checked columns.

-- Purpose: 
-- Geographic distribution.
SELECT
	COUNT(DISTINCT city) total_cities,
    COUNT(DISTINCT state) total_states
FROM customers;
-- Brazilian E-Commerce has customers from 4,119 cities and 27 states


-- -----------------------------------------------
-- Sellers Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM sellers; 
-- 3,095 records

-- Purpose: 
-- Verifying if there are duplicate primary keys
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT seller_id) AS distinct_seller_ids
FROM sellers;
-- Total rows = 3,095
-- Distinct seller_id = 3,095
-- No duplicate seller_id values were found.

-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(city IS NULL OR city = '') AS missing_city,
    SUM(state IS NULL OR state = '') AS missing_state
FROM sellers;
-- No missing values were found in the checked columns.

-- Purpose: 
-- Geographic distribution.
SELECT
	COUNT(DISTINCT city) total_cities,
    COUNT(DISTINCT state) total_states
FROM sellers;
-- Brazilian E-Commerce has sellers from 610 cities and 23 states


-- -----------------------------------------------
-- Products Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM products; 
-- 32,951 records

-- Purpose: 
-- Verifying if there are duplicate primary keys
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS distinct_product_ids
FROM products;
-- Total rows = 32,951
-- Distinct product_id = 32,951
-- No duplicate product_id values were found.

-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(category_name IS NULL OR category_name = '') AS missing_category_name,
    SUM(name_length IS NULL) AS missing_name_length,
    SUM(description_length IS NULL) AS missing_description_length,
    SUM(photo_qty IS NULL) AS missing_photo_qty,
    SUM(weight_g IS NULL) AS missing_weight_g,
    SUM(length_cm IS NULL) AS missing_length_cm,
    SUM(height_cm IS NULL) AS missing_height_cm,
    SUM(width_cm IS NULL) AS missing_width_cm
FROM products;
-- category_name contains 610 missing values,
-- name_length contains 610 missing values,
-- description_length contains 610 missing values,
-- photo_qty contains 610 missing values,
-- weight_g contains 2 missing values,
-- length_cm contains 2 missing values,
-- height_cm contains 2 missing values,
-- width_cm contains 2 missing values

-- Purpose:
-- Observing records with missing descriptive information
SELECT
    *
FROM products
WHERE category_name IS NULL
  AND name_length IS NULL
  AND description_length IS NULL
  AND photo_qty IS NULL;
-- 610 products have missing descriptive information. 
-- The category_name field is stored as an empty string, 
-- while the remaining descriptive attributes are NULL.

-- Purpose:
-- Observing records with missing physical information
SELECT *
FROM products
WHERE weight_g IS NULL
	OR length_cm IS NULL
    OR height_cm IS NULL
    OR width_cm IS NULL;
-- Two records have all three dimensional (length, height, and width), 
-- and weight values missing, indicating incomplete physical measurement data.

-- Purpose: 
-- Finding number of categories
SELECT 
	COUNT(DISTINCT category_name) AS category_count
FROM products;
-- There are 73 categories of products

-- Purpose: 
-- Validate numeric attributes by checking their minimum values for unexpected or invalid entries.
SELECT 
	MIN(name_length) AS min_name_length,
    MIN(description_length) AS min_description_length,
    MIN(photo_qty) AS min_photo_qty,
    MIN(weight_g) AS min_weight,
    MIN(length_cm) AS min_length,
    MIN(height_cm) AS min_height,
    MIN(width_cm) AS min_width
FROM products;
-- The records have no abnormal minimum values, except for weight having minimum value of 0.  
SELECT * 
FROM products WHERE weight_g = 0;
-- Four products have a recorded weight of 0 grams while retaining valid dimension values. 
-- These records will be reviewed during data preparation to determine whether the zero values should be retained.

SELECT 
	MAX(name_length) AS MAX_name_length,
    MAX(description_length) AS MAX_description_length,
    MAX(photo_qty) AS MAX_photo_qty,
    MAX(weight_g) AS MAX_weight,
    MAX(length_cm) AS MAX_length,
    MAX(height_cm) AS MAX_height,
    MAX(width_cm) AS MAX_width
FROM products;
-- No unusually large or suspicious maximum values were observed.

-- Purpose: 
-- Checking if the products with missing descriptional data were referenced in order_items
SELECT p.product_id, COUNT(*)
FROM (
	SELECT
		product_id
	FROM products
	WHERE category_name IS NULL
	AND name_length IS NULL
	AND description_length IS NULL
	AND photo_qty IS NULL
) p
JOIN order_items o
	ON p.product_id = o.product_id
GROUP BY p.product_id;
-- All of the products were sold atleast once

-- Purpose: 
-- Checking if the products with missing physical data were referenced in order_items
SELECT p.product_id, COUNT(*)
FROM (
	SELECT *
	FROM products
	WHERE weight_g IS NULL
		OR length_cm IS NULL
		OR height_cm IS NULL
		OR width_cm IS NULL
) p
JOIN order_items o
	ON p.product_id = o.product_id
GROUP BY p.product_id;
-- All of the products were sold atleast once

-- Purpose: 
-- Checking if the products with weight value zero, were referenced in order_items
SELECT p.product_id, COUNT(*)
FROM (
	SELECT * 
	FROM products WHERE weight_g = 0
) p
JOIN order_items o
	ON p.product_id = o.product_id
GROUP BY p.product_id;
-- All of the products were sold atleast once


-- -----------------------------------------------
-- Category Translation Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM category_translation; 
-- 71 records

-- Purpose: 
-- Verifying if there are duplicate primary keys
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT category) AS distinct_category
FROM category_translation;
-- Total rows = 71
-- Distinct category = 71, whereas category count is 73 in the products table
-- No duplicate category values were found.

-- Purpose: 
-- Finding the categories in Product table which are not present in Translations
SELECT 
	DISTINCT p.category_name,
    ct.category,
    ct.category_english
FROM products p
LEFT JOIN category_translation ct
    ON p.category_name = ct.category
WHERE p.category_name <> ''
  AND ct.category IS NULL;
-- Two Portuguese categories have no corresponding English translation: 
-- 'pc_gamer', 'portateis_cozinha_e_preparadores_de_alimentos'


-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(category IS NULL OR category = '') AS missing_category,
    SUM(category_english IS NULL OR category_english = '') AS missing_category_english
FROM category_translation;
-- No missing values were found in the checked columns.


-- -----------------------------------------------
-- Orders Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM orders; 
-- 99,441 records
-- The number of records in orders matches the number of records in customers. 
-- This indicates a one-to-one relationship between orders and customer_id records in this dataset.

-- Purpose: 
-- Verifying if there are duplicate primary keys
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_order_ids
FROM orders;
-- Total rows = 99,441
-- Distinct order_id = 99,441
-- No duplicate order_id values were found.

-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(customer_id IS NULL OR customer_id = '') AS missing_customer_id,
    SUM(status IS NULL OR status = '') AS missing_status,
    SUM(purchased_at IS NULL) AS missing_purchased_at,
    SUM(approved_at IS NULL) AS missing_approved_at,
    SUM(carrier_at IS NULL) AS missing_carrier_at,
    SUM(delivered_at IS NULL) AS missing_delivered_at,
    SUM(estimated_delivery IS NULL) AS missing_estimated_delivery
FROM orders;
-- No missing values are present in customer_id, status, purchased_at, and estimated_delivery columns
-- approved_at, carrier_at, and delivered_at columns have missing values.
-- Some or all of these may be expected depending on status of the order.

-- Purpose:
-- Finding the status values, their distribution, and their association with missing timestamps.
SELECT 
	status, 
    count(*) as status_count,
    SUM(approved_at IS NULL) AS missing_approved_at,
    SUM(carrier_at IS NULL) AS missing_carrier_at,
    SUM(delivered_at IS NULL) AS missing_delivered_at,
    SUM(estimated_delivery IS NULL) AS missing_estimated_delivery
FROM orders 
GROUP BY status
ORDER BY status_count DESC; 
-- 8 statuses exist in total. 96,478 orders are delivered
-- Most missing timestamps are consistent with the order status. 
-- However, a small number of delivered orders have missing approval, carrier, or delivery timestamps. 
-- 625 orders have order_status = 'canceled'.
-- 619 of them have delivered_at as NULL.
-- 6 canceled orders have a non-NULL delivered_at timestamps.
-- These records will be investigated during data preparation.

-- Purpose
-- Finding the date ranges
SELECT 
	MIN(purchased_at) AS First_Purchase,
    MAX(purchased_at) AS Last_Purchase,
    MIN(approved_at) AS First_approved,
    MAX(approved_at) AS Last_approved,
    MIN(carrier_at) AS First_carrier,
    MAX(carrier_at) AS Last_carrier,
    MIN(delivered_at) AS First_delivered,
    MAX(delivered_at) AS Last_delivered,
    MIN(estimated_delivery) AS First_estimated_delivery,
    MAX(estimated_delivery) AS Last_estimated_delivery
FROM orders;
-- Note: each first or last date values may be associated with a different order record.
-- No abnormal or impossible dates are observed.    

-- Purpose:
-- Checking if there are Orphaned customer_ids
SELECT COUNT(*) AS orphan_customers
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- No orphan customer records were found.


-- -----------------------------------------------
-- Order items Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM order_items; 
-- 112,650 records

-- Purpose: 
-- Verifying if there are duplicate primary keys
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id, item_no) AS distinct_primary_key
FROM order_items;
-- Total rows = 112,650
-- Distinct primary key count = 112,650
-- No duplicate primary key values were found.

-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(product_id IS NULL OR product_id = '') AS missing_product_id,
    SUM(seller_id IS NULL OR seller_id = '') AS missing_seller_id,
    SUM(shipping_limit IS NULL) AS missing_shipping_limit,
    SUM(price IS NULL) AS missing_price,
    SUM(freight_value IS NULL) AS missing_freight_value
FROM order_items;
-- No missing values are present in the table

-- Purpose:
-- Validate the range of item sequence numbers.
SELECT 
	MIN(item_no) AS min_items_purchased,
    MAX(item_no) AS max_items_purchased
FROM order_items;
-- No negative values, and the maximum is 21

-- Purpose:
-- Finding the number of products that were ordered (atleast once)
SELECT 
	COUNT(DISTINCT product_id) AS ordered_product_count
FROM order_items;
-- 32,951 products were ordered

-- Purpose:
-- Finding the number of sellers who got orders (atleast once)
SELECT 
	COUNT(DISTINCT seller_id) AS sellers_count
FROM order_items;
-- 3095 sellers got orders

-- Purpose:
-- Checking the orders with multiple items
SELECT
    COUNT(*) AS multi_item_orders
FROM (
    SELECT order_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(*) > 1
) t;
-- 9,803 orders have multiple items

-- Purpose:
-- Finding date range of shipping_limit
SELECT 
	MIN(shipping_limit) as first_shipping_limit,
    MAX(shipping_limit) as last_shipping_limit
FROM order_items;
-- No abnormal timestamps were found. 

-- Purpose;
-- Checking shipping_limit timestamp consistency with purchased_at timestamps
SELECT 
	count(*) as abnormal_shipping_limit
FROM order_items oi
LEFT JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.purchased_at > oi.shipping_limit;
-- No records were found where the shipping deadline precedes the purchase timestamp.

-- Purpose:
-- Checking the values in numerical columns
SELECT
	MIN(price) AS min_price,
    MAX(price) AS max_price,
    MIN(freight_value) AS min_freight_value,
    MAX(freight_value) AS max_freight_value
FROM order_items;
-- No abnormal values were found.
-- All the price values are positive.
-- All the freight_value values are positive.

-- Purpose:
-- Checking for orphaned order_id's
SELECT 
	count(*) as orphan_order_ids
FROM order_items oi
LEFT JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
-- No orphan order_id's

-- Purpose:
-- Checking for orphaned product_id's 
SELECT 
	count(*) as orphan_product_ids
FROM order_items oi
LEFT JOIN products p
	ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
-- No orphan product_id's

-- Purpose:
-- Checking for orphaned seller_id's 
SELECT 
	count(*) as orphan_seller_ids
FROM order_items oi
LEFT JOIN sellers s
	ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;
-- No orphan seller_id's


-- -----------------------------------------------
-- Order payments Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM order_payments; 
-- 103,886 records

-- Purpose: 
-- Verifying if there are duplicate primary keys
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id, payment_seq) AS distinct_primary_key
FROM order_payments;
-- Total rows = 103,886
-- Distinct primary key count = 103,886
-- No duplicate primary key values were found.

-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(payment_type IS NULL OR payment_type = '') AS missing_payment_type,
    SUM(payment_seq IS NULL) AS missing_payment_seq,
    SUM(installments IS NULL) AS missing_installments,
    SUM(payment_value IS NULL) AS missing_payment_value
FROM order_payments;
-- No missing values are present in the table

-- Purpose:
-- Finding the number of orders that were recorded in payments (atleast once)
SELECT 
	COUNT(DISTINCT order_id) AS paid_order_count
FROM order_payments;
-- 99,440 orders were recorded in payments

-- Purpose:
-- Checking the orders with multiple payments
SELECT
    COUNT(*) AS multi_payment_orders
FROM (
    SELECT order_id
    FROM order_payments
    GROUP BY order_id
    HAVING COUNT(*) > 1
) t;
-- 2,961 orders have multiple payment records

-- Purpose:
-- Finding the existing payment_types and their distribution
SELECT 
	payment_type, 
    count(*) AS payment_count
FROM order_payments
GROUP BY payment_type
ORDER BY count(*) DESC;
-- Five payment methods are present in the dataset, and there are 3 records with payment_type, 'not_defined'.

-- Purpose:
-- Validate the range of payment sequence numbers.
SELECT 
	MIN(payment_seq) AS min_payment_seq,
    MAX(payment_seq) AS max_payment_seq
FROM order_payments;
-- No negative values, and the maximum is 29

-- Purpose:
-- Validate the range of numerical column values.
SELECT 
	MIN(installments) AS min_installments,
    MAX(installments) AS max_installments,
    MIN(payment_value) AS min_payment_value,
    MAX(payment_value) AS max_payment_value
FROM order_payments;
-- There are records with installments value 0, and the maximum is 24.
-- And there are records with payment value, 0. Max payment value is 13,664.08

-- Purpose:
-- Checking if the zero values in installments and payment_value are associated with canceled orders
SELECT 
	op.order_id,
    op.payment_seq,
    op.payment_type,
    op.installments,
    op.payment_value,
    o.status
FROM order_payments op
JOIN orders o
	ON op.order_id = o.order_id
WHERE installments = 0
OR payment_value = 0;
-- There are 9 records with zero payment value, out of which,
-- 3 records have status, 'canceled' and have the payment_type, 'not defined'. 
-- The 6 records with zero payment_values have the payment_type as 'voucher' and payment_seq greater than 1.  
-- Two delivered orders contain a secondary credit card payment (payment_seq = 2) with installments = 0. 
-- Since installment counts would normally be expected to be at least 1, 
-- these records will be reviewed during data preparation

-- Purpose: 
-- Finding payment records count with the order status as canceled.
SELECT 
	COUNT(*) AS canceled_order_payment_count
FROM order_payments op
JOIN orders o
	ON op.order_id = o.order_id
WHERE o.status = 'canceled';
-- 664 canceled orders exist in the payments table, out of which only 9 records have 0 payment value.
-- this indicates that 655 canceled orders have positive payment values.
-- The data is not available to indicate if these orders were refunded later.

-- Purpose:
-- Observing payment values for canceled orders
SELECT 
	op.*,
    o.status
FROM order_payments op
JOIN orders o
	ON op.order_id = o.order_id
WHERE o.status = 'canceled';
-- Some canceled orders contain completed payment records, including installment payments. 
-- The dataset does not provide sufficient information to determine whether 
-- these represent completed, refunded, or partially processed transactions.

-- Purpose:
-- checking if total payments made for each order are aligning with total prices of the order items
WITH totalpaid AS
(	SELECT 
		order_id,
		SUM(payment_value) as total_paid
	FROM order_payments
    GROUP BY order_id
),
totalprice AS
(	SELECT 
		order_id,
		SUM(price + freight_value) as total_price
	FROM order_items
    GROUP BY order_id
)
SELECT 
	tp.order_id,
    total_paid,
    total_price
FROM totalpaid tp
JOIN totalprice tpr
	ON tp.order_id = tpr.order_id
WHERE ABS(total_paid - total_price) > 0.01
ORDER BY total_paid DESC;
-- After excluding insignificant rounding differences (≤ 0.01), 303 orders remain 
-- where the total payment differs from the total value of order items plus freight. 
-- These discrepancies require further investigation to determine whether they represent 
-- legitimate business scenarios (such as vouchers, adjustments, or refunds) or data quality issues.

-- Purpose:
-- Classifying the payment mismatch records to over/under payments
WITH totalpaid AS
(
    SELECT
        order_id,
        SUM(payment_value) AS total_paid
    FROM order_payments
    GROUP BY order_id
),
totalprice AS
(
    SELECT
        order_id,
        SUM(price + freight_value) AS total_price
    FROM order_items
    GROUP BY order_id
)
SELECT
    CASE
		WHEN total_paid > total_price THEN 'Overpaid'
		WHEN total_paid < total_price THEN 'Underpaid'
	END AS difference,
    COUNT(*) AS order_count
FROM totalpaid tp
JOIN totalprice tpr
    ON tp.order_id = tpr.order_id
WHERE ABS(total_paid - total_price) > 0.01
GROUP BY 
	CASE
		WHEN total_paid > total_price THEN 'Overpaid'
		WHEN total_paid < total_price THEN 'Underpaid'
	END
ORDER BY difference;
-- 264 orders show total payments greater than the order total, 
-- while 39 show total payments less than the order total.

-- Purpose:
-- Finding the mismatched orders with multiple payment records 
WITH totalpaid AS
(
    SELECT
        order_id,
        SUM(payment_value) AS total_paid
    FROM order_payments
    GROUP BY order_id
),
totalprice AS
(
    SELECT
        order_id,
        SUM(price + freight_value) AS total_price
    FROM order_items
    GROUP BY order_id
),
mismatched_orders AS
(
    SELECT tp.order_id
    FROM totalpaid tp
    JOIN totalprice tpr
        ON tp.order_id = tpr.order_id
    WHERE ABS(total_paid - total_price) > 0.01
)
SELECT
    CASE
        WHEN payment_count = 1 THEN 'Single payment'
        ELSE 'Multiple payments'
    END AS payment_group,
    COUNT(*) AS order_count
FROM
(
    SELECT
        order_id,
        COUNT(*) AS payment_count
    FROM order_payments
    GROUP BY order_id
) p
JOIN mismatched_orders m
    ON p.order_id = m.order_id
GROUP BY payment_group;
-- Only 17 of the 303 orders have multiple payment records, 
-- indicating that split payments are not the primary cause of the mismatches.

-- Purpose:
-- Checking for orphaned order_id's
SELECT 
	count(*) as orphan_order_ids
FROM order_payments op
LEFT JOIN orders o
	ON op.order_id = o.order_id
WHERE o.order_id IS NULL;
-- No orphan order_id's

-- Purpose:
-- Checking for orders that are not in payments
SELECT 
	*
FROM orders o
LEFT JOIN order_payments op
	ON o.order_id = op.order_id
WHERE op.order_id IS NULL;
-- 1 Unpaid order_id

-- checking the details of the order
SELECT *
FROM order_items
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c';

SELECT *
FROM order_reviews
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c';
-- the order contains valid order items,
-- the order status is 'delivered',
-- a customer review exists stating that the product was not received.


-- -----------------------------------------------
-- Order reviews Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM order_reviews; 
-- 99,222 reviews

-- Purpose:
-- checking the uniqueness of the reviews and orders
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT review_id) AS distinct_review_count,
    COUNT(DISTINCT order_id) AS distinct_order_count,
    COUNT(DISTINCT review_id, order_id) AS distinct_composite_col_count
FROM order_reviews;
-- Both review_id and order_id contain repeated values.
-- However, the combination of review_id and order_id is unique,
-- confirming that they form the composite primary key.

-- Purpose:
-- Verifying if the review content is same across all the repeated records
SELECT
    review_id,
    COUNT(DISTINCT order_id) AS order_count,
    COUNT(DISTINCT title) AS title_count,
    COUNT(DISTINCT message) AS message_count
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY order_count DESC;
-- The distinct title count and message count do not exceed 1 for any repeated review_id.
-- This indicates that all records sharing the same review_id contain identical review titles and messages.

-- Purpose:
-- Observing the reviews with multiple records
SELECT 
	*
FROM order_reviews rs
JOIN (
	SELECT review_id
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
     ) r
ON rs.review_id = r.review_id
ORDER BY rs.review_id, rs.order_id;
-- All records sharing the same review_id contain identical review titles and messages. 
-- Repeated review_ids represent the same review content associated with multiple orders.

-- Purpose: 
-- Verifying if there are duplicate primary keys
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT review_id, order_id) AS distinct_primary_key
FROM order_reviews;
-- Total rows = 99,222
-- Distinct primary key count = 99,222
-- No duplicate primary key values were found.

-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(score IS NULL) AS missing_score,
    SUM(title IS NULL OR title = '') AS missing_title,
    SUM(message IS NULL OR message = '') AS missing_message,
    SUM(created_at IS NULL) AS missing_created_at,
    SUM(answered_at IS NULL) AS missing_answered_at
FROM order_reviews;
-- Missing values exist only in the review title and review message columns.
-- These are expected, as customers may submit ratings without written feedback.

-- Purpose:
-- Checking the oders with multiple reviews
SELECT 
	*
FROM order_reviews rs
JOIN (
	SELECT order_id
    FROM order_reviews
    GROUP BY order_id
    HAVING COUNT(*) > 1
     ) r
ON rs.order_id = r.order_id
ORDER BY rs.order_id, rs.review_id;
-- Multiple reviews associated with the same order contain different review content, 
-- indicating they are separate review submissions rather than duplicate records.
-- There isn't enough data to find which product each review belongs.

-- Purpose:
-- Finding the score values, and their distribution.
SELECT 
	score, 
    count(*) as score_count
FROM order_reviews 
GROUP BY score
ORDER BY score DESC; 
-- Ratings of 5 and 4 are the most frequently occurring review scores.

-- Purpose:
-- Checking for orphaned order_id's
SELECT 
	count(*) as orphan_order_ids
FROM order_reviews r
LEFT JOIN orders o
	ON r.order_id = o.order_id
WHERE o.order_id IS NULL;
-- No orphan order_id's

-- Purpose:
-- Verifying timestamps    
SELECT
    MIN(created_at),
    MAX(created_at),
    MIN(answered_at),
    MAX(answered_at)
FROM order_reviews;

SELECT COUNT(*)
FROM order_reviews
WHERE answered_at < created_at;
-- No impossible dates are present.
-- answered_at is consistent with created_at dates.

-- -----------------------------------------------
-- Geolocation Table
-- -----------------------------------------------

-- Purpose: 
-- Checking the number of records
SELECT 
	COUNT(*) AS total_rows
FROM geolocation; 
-- 1,000,163 records

-- Purpose:
-- checking the possible candidate key count
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT zip_code_prefix) AS distinct_zip_code,
    COUNT(DISTINCT latitude, longitude) AS distinct_coordinate_count,
    COUNT(DISTINCT city) AS distinct_city_count,
    COUNT(DISTINCT state) AS distinct_state_count,
    COUNT(DISTINCT zip_code_prefix, latitude, longitude, city, state) AS distinct_composite_col_count
FROM geolocation;
-- None of the individual columns contain unique values.
-- The table contains 19,015 zip code prefixes, 718,457 coordinate pairs,
-- 5,969 cities, and 27 states.

-- Purpose:
-- checking the unique row count
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT zip_code_prefix,
                    latitude,
                    longitude,
                    city,
                    state) AS distinct_rows
FROM geolocation;
-- Only 720,490 distinct row combinations exist.
-- This indicates that the table contains exact duplicate records.
                    
-- Purpose
-- Checking the number of groups with duplicate rows
SELECT COUNT(*) as rows_with_duplicates
FROM (
	SELECT
		1
	FROM geolocation
	GROUP BY zip_code_prefix, 
		latitude, 
		longitude, 
		city, 
		state
	HAVING COUNT(*) > 1
	) duplicate_count;
-- 131,546 groups contain duplicate rows.
-- The duplicate groups will be investigated further during data preparation.

-- Purpose: 
-- checking for missing values.
SELECT 
	COUNT(*) AS total_rows,
    SUM(zip_code_prefix IS NULL OR zip_code_prefix = '') AS missing_zip_code_prefix,
    SUM(latitude IS NULL) AS missing_latitude,
    SUM(longitude IS NULL) AS missing_longitude,
    SUM(city IS NULL OR city = '') AS missing_city,
    SUM(state IS NULL OR state = '') AS missing_state
FROM geolocation;
-- No missing values were found in the checked columns.

-- Purpose:
-- Checking relationship between the columns
-- checking if a coordinate pair has multiple zip_code_prefixes
SELECT 
	latitude, longitude, 
	COUNT(DISTINCT zip_code_prefix) as zip_code_prefix_count
FROM geolocation
GROUP BY latitude, longitude
HAVING COUNT(DISTINCT zip_code_prefix) > 1
ORDER BY zip_code_prefix_count;
-- Some coordinate pairs are associated with multiple zip code prefixes.
-- Therefore, a coordinate pair cannot uniquely identify a record.

-- Purpose
-- Checking if a coordinate pair has multiple cities
SELECT 
	latitude, longitude, 
	COUNT(DISTINCT city) as city_count
FROM geolocation
GROUP BY latitude, longitude
HAVING COUNT(DISTINCT city) > 1
ORDER BY city_count;
-- Some coordinate pairs are associated with multiple cities.
-- Therefore, coordinate pairs cannot be treated as unique locations.

-- Purpose
-- Checking if single zip_code_prefix has multiple cities
SELECT 
	zip_code_prefix, 
	COUNT(DISTINCT city) as city_count
FROM geolocation
GROUP BY zip_code_prefix
HAVING COUNT(DISTINCT city) > 1
ORDER BY city_count DESC;
-- zip prefixes are mapped with multiple cities
-- Therefore, zip_code_prefix is not a unique geographical identifier.

-- Purpose
-- Checking if single zip_code_prefix has multiple states
SELECT 
	zip_code_prefix, 
	COUNT(DISTINCT state) as state_count
FROM geolocation
GROUP BY zip_code_prefix
HAVING COUNT(DISTINCT state) > 1
ORDER BY state_count DESC;
-- zip prefixes are mapped with multiple states.
-- Therefore, zip_code_prefix alone cannot uniquely determine a state.

-- Purpose
-- Checking if single city has multiple states
SELECT 
	city, 
	COUNT(DISTINCT state) as state_count
FROM geolocation
GROUP BY city
HAVING COUNT(DISTINCT state) > 1
ORDER BY state_count DESC;
-- cities are mapped with multiple states.
-- Therefore, city alone cannot uniquely determine a state.

-- No natural candidate key was identified for the geolocation table.
-- Multiple many-to-one and one-to-many relationships exist between
-- zip_code_prefix, coordinates, cities, and states.
-- This table appears to represent geolocation observations rather than
-- a normalized geographical reference table.

/* ===========================================================================

End of profiling tables

Next step: 04_prepare_data

=========================================================================== */