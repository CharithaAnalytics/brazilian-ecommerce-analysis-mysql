/* ===========================================================

 Project : Brazilian E-commerce Analysis
 02_load_data.sql

 - There are 9 raw CSV files from the Olist Brazilian E-commerce.
 - Each file is loaded into a single MySQL staging table.
 - Data is loaded as close to the source as possible.
 - No transformations are performed at this stage.

Note: 
- Before running this script, replace the file paths in each
LOAD DATA LOCAL INFILE statement with the location of your dataset.
______________________________________________________________

 Following issues were resolved while loading data from different csv's:
 
  - customer and seller files used LF ending and the of the files used CRLF line endings, 
	so the line termination part is specified accordingly in the loading query.
 - Empty values are converted to NULL using NULLIF().
 - Timestamps are converted using STR_TO_DATE() because
	the source format is DD-MM-YYYY HH.MM.
 
============================================================= */

USE brazilian_ecommerce;

-- --------------------------------------------------------------------------------

/* 
CUSTOMERS
Source file:
olist_customers_dataset.csv
 
Notes:
- Uses LF line endings.
- No nullable columns.
*/

LOAD DATA LOCAL INFILE "<path_to_dataset>/olist_customers_dataset.csv" 
INTO TABLE customers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- -------------------------------------------------------------------------------------

/* 
SELLERS
Source file:
olist_sellers_dataset.csv
 
Notes:
- Uses LF line endings.
- No nullable columns.
*/

LOAD DATA LOCAL INFILE '<path_to_dataset>/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    seller_id,
    zip_code_prefix,
    city,
    state
);

-- ----------------------------------------------------------------------------------

/*
PRODUCTS
Source file:
olist_products_dataset.csv

Notes:
- Uses CRLF line endings.
- Numeric columns may contain empty values.
*/

LOAD DATA LOCAL INFILE '<path_to_dataset>/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    product_id,
    @category_name,
    @name_length,
    @description_length,
    @photo_qty,
    @weight_g,
    @length_cm,
    @height_cm,
    @width_cm
)
SET
    category_name = NULLIF(@category_name, ''),
    name_length = NULLIF(@name_length, ''),
    description_length = NULLIF(@description_length, ''),
    photo_qty = NULLIF(@photo_qty, ''),
    weight_g = NULLIF(@weight_g, ''),
    length_cm = NULLIF(@length_cm, ''),
    height_cm = NULLIF(@height_cm, ''),
    width_cm = NULLIF(@width_cm, '');
    
-- checking if category_name has missing values

SELECT COUNT(*) AS missing_category
FROM products
WHERE category_name IS NULL;

-- checking the nullable numeric columns

SELECT
    SUM(name_length IS NULL) AS missing_name_length,
    SUM(description_length IS NULL) AS missing_description_length,
    SUM(photo_qty IS NULL) AS missing_photo_qty,
    SUM(weight_g IS NULL) AS missing_weight_g,
    SUM(length_cm IS NULL) AS missing_length_cm,
    SUM(height_cm IS NULL) AS missing_height_cm,
    SUM(width_cm IS NULL) AS missing_width_cm
FROM products;

-- -------------------------------------------------------------------------------

/* 
CATEGORY NAME TRANSLATIONS
Source file:
product_category_name_translation.csv
 
Notes:
- Uses CRLF line endings.
- No nullable columns.
*/

LOAD DATA LOCAL INFILE '<path_to_dataset>/product_category_name_translation.csv'
INTO TABLE category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    category,
    category_english
);

-- -------------------------------------------------------------------------------

/*
ORDERS
Source file:
olist_orders_dataset.csv

Notes:
- Uses CRLF line endings.
- Timestamps are stored as DD-MM-YYYY HH.MM in the source file
- Used STR_TO_DATE() function to convert them into MySQL DATETIME values.
*/

LOAD DATA LOCAL INFILE '<path_to_dataset>/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    status,
    @purchased_at,
    @approved_at,
    @carrier_at,
    @delivered_at,
    @estimated_delivery
)
SET
    purchased_at = STR_TO_DATE(@purchased_at, '%d-%m-%Y %H.%i'),
    approved_at = STR_TO_DATE(NULLIF(@approved_at, ''), '%d-%m-%Y %H.%i'),
    carrier_at = STR_TO_DATE(NULLIF(@carrier_at, ''), '%d-%m-%Y %H.%i'),
    delivered_at = STR_TO_DATE(NULLIF(@delivered_at, ''), '%d-%m-%Y %H.%i'),
    estimated_delivery = STR_TO_DATE(NULLIF(@estimated_delivery, ''), '%d-%m-%Y %H.%i');
    
-- ---------------------------------------------------------------------------------------

/*
ORDER ITEMS
Source file:
olist_order_items_dataset.csv

Notes:
- Uses CRLF line endings.
- Timestamps are stored as DD-MM-YYYY HH.MM in the source file
- Used STR_TO_DATE() function to convert them into MySQL DATETIME values.
*/

LOAD DATA LOCAL INFILE '<path_to_dataset>/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    order_id,
    item_no,
    product_id,
    seller_id,
    @shipping_limit,
    price,
    freight_value
)
SET
    shipping_limit = STR_TO_DATE(@shipping_limit, '%d-%m-%Y %H.%i');
-- -----------------------------------------------------------------------------------

/*
ORDER PAYMENTS
Source file:
olist_order_payments_dataset.csv

Notes:
- Uses CRLF line endings.
*/

LOAD DATA LOCAL INFILE '<path_to_dataset>/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    order_id,
    payment_seq,
    payment_type,
    installments,
    payment_value
);

-- -----------------------------------------------------------------------------------

/*
REVIEWS
Source file:
olist_order_reviews_dataset.csv

Notes:
- Uses CRLF line endings.
- Empty values from Title and message columns are converted to null using NULLIF()
- Timestamps created_at and answered_at columns are stored as DD-MM-YYYY HH.MM in the source file
- Used STR_TO_DATE() function to convert them into MySQL DATETIME values.
*/

LOAD DATA LOCAL INFILE '<path_to_dataset>/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    review_id,
    order_id,
    score,
    @title,
    @message,
    @created_at,
    @answered_at
)
SET
    title = NULLIF(@title, ''),
    message = NULLIF(@message, ''),
    created_at = STR_TO_DATE(NULLIF(@created_at, ''), '%d-%m-%Y %H.%i'),
    answered_at = STR_TO_DATE(NULLIF(@answered_at, ''), '%d-%m-%Y %H.%i');
    
-- -----------------------------------------------------------------------------

/*
GEO LOCATIONS
Source file:
olist_geolocation_dataset.csv

Notes:
- Uses CRLF line endings.
- Latitude and longitude are stored as DOUBLE, as the source data contains coordinates with 
  up to nine decimal places and one value expressed in scientific notation (e.g. -4.3674E-05).
*/

LOAD DATA LOCAL INFILE '<path_to_dataset>/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    zip_code_prefix,
    latitude,
    longitude,
    city,
    state
);

/* ===========================================================================

End of data loading.

Next step: 03_profile_data
-- Profile the loaded data before performing any cleaning or transformations.

=========================================================================== */