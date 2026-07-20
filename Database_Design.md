# Database Design

## Overview

The Olist dataset consists of multiple CSV files representing different business entities and business processes. To reduce redundancy and maintain data integrity, the data was organized into a normalized relational database.

The schema closely follows the logical relationships present in the original dataset while applying relational database design principles.

---

# Database Schema Overview

The database was designed using normalized relational tables based on the structure of the Olist dataset. It consists of transaction, dimension, lookup, and supporting tables that together model the core entities of an e-commerce marketplace.

**Entity Relationship Diagram**

![ER Diagram](images/ER_Diagram.png)

---

# Table Design

The schema is organized into four logical groups:

• Dimension Tables
    - customers
    - sellers
    - products

• Transaction Tables
    - orders
    - order_items
    - order_payments
    - order_reviews

• Lookup Table
    - product_category_name_translation

• Supporting Table
    - geolocation

## customers

Stores customer identification and location information.

Primary Key

- customer_id

Key Attributes

- customer_unique_id
- customer_zip_code_prefix
- customer_city
- customer_state

---

## orders

Stores order lifecycle information.

Primary Key

- order_id

Foreign Key

- customer_id → customers.customer_id

Key Attributes

- purchase timestamp
- approved timestamp
- carrier delivery timestamp
- delivered timestamp
- estimated delivery timestamp

---

## order_items

Stores products belonging to each order.

Composite Primary Key

- order_id
- order_item_id

Foreign Keys

- order_id
- product_id
- seller_id

Key Attributes

- price
- freight_value

---

## order_payments

Stores payment information for each order.

Composite Primary Key

- order_id
- payment_sequential

Foreign Key

- order_id

Key Attributes

- payment_type
- payment_installments
- payment_value

---

## order_reviews

Stores customer review information.

Primary Key

- review_id

Foreign Key

- order_id

Key Attributes

- review score
- review title
- review message
- creation date
- answer timestamp

Note: A review may be associated with multiple orders in the source dataset, so review relationships were preserved as provided rather than modified.

---

## products

Stores product characteristics.

Primary Key

- product_id

Key Attributes

- category
- description length
- photos
- weight
- dimensions

---

## sellers

Stores seller location information.

Primary Key

- seller_id

Key Attributes

- ZIP code
- city
- state

---

## product_category_name_translation

Maps Portuguese category names to English names.

Primary Key

- product_category_name

Key Attributes

- product_category_name_english

---

## geolocation

Stores geographic coordinates for ZIP code prefixes.

Primary Key

- geolocation_id (surrogate key)

Key Attributes

- ZIP code prefix
- latitude
- longitude
- city
- state

Latitude and longitude are stored as DOUBLE to preserve precision.

The table does not have a primary key because the source data contains duplicate ZIP code prefixes and no reliable natural key could be identified.

---

# Relationships

customers (1) ---- (M) orders

orders (1) ---- (M) order_items

orders (1) ---- (M) order_payments

orders (1) ---- (1/M) order_reviews

products (1) ---- (M) order_items

sellers (1) ---- (M) order_items

Category translation is used as a lookup table during analysis but is not enforced through a foreign key because two valid product categories have no corresponding translation in the source dataset.

---

# Normalization

The database design follows normalization principles to reduce redundancy.

Key design decisions include:

- Separate lookup table for product category translations.
- Independent seller and customer tables.
- Product information stored only once.
- Payment and review information separated from order details.
- Geographic information isolated in a dedicated table.
- Transactional and master data were separated to support efficient querying and reduce redundancy.

The resulting schema minimizes duplicate data while maintaining logical relationships across business entities.

---

# ETL Considerations

Several design choices were made to improve the loading process:

- Primary and foreign key constraints were added after data loading and preparation to simplify bulk imports and validate data before enforcing referential integrity.
- Nullable fields were converted using NULLIF().
- Date values were converted during import using STR_TO_DATE().
- Latitude and longitude were stored as DOUBLE.
- Row counts were validated after every data load.

These decisions improve both data quality and import reliability.
