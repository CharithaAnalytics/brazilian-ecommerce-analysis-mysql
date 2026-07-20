/* ===========================================================

 Project : Brazilian E-commerce Analysis
 04_prepare_data.sql

Purpose: Prepare the dataset for analysis by applying the necessary
data cleaning, transformations, and structural improvements
identified during the profiling stage.

Data Preparation Principles:

- Preserve original source data whenever the correct value cannot be determined.
- Apply transformations only when they improve data quality without altering business meaning.
- Document all identified anomalies and justify every preparation decision.
- Prefer flagging and documentation over deleting or fabricating data.

============================================================= */

/* ----------------------------------------------------------
Customers Table
-------------------------------------------------------------

Data Preparation Summary

- No duplicate customer_id values found.
- No missing values found.
- No transformations required.

customer_unique_id represents the same customer across
multiple orders and will be used for customer-level analysis.
customer_id will continue to be used for joins with
the orders table.

----------------------------------------------------------- */


/* ----------------------------------------------------------
Sellers Table
-------------------------------------------------------------

Data Preparation Summary

- No duplicate seller_id values found.
- No missing values found.
- No transformations required.

----------------------------------------------------------- */


/* ----------------------------------------------------------
Products Table
-------------------------------------------------------------

Data Preparation Summary

610 products with missing descriptive information
2 products with missing physical measurements
4 products with weight = 0
All of these products are referenced in the order_items table,
confirming that each product participated in at least one sale.

Objective:
Retain products with incomplete information while preserving
transactional integrity, replacing missing product category name with 'Unknown'
 and create data quality flags to identify
records with missing or invalid product attributes.

----------------------------------------------------------- */

/*
Products is a dimension table representing the product catalog.

Although some product attributes are missing or invalid,
these records are retained because:

1. They are valid product records.
2. Each product is referenced in the order_items table,
   indicating that it was sold at least once.
3. Removing or imputing these records could lead to loss of
   historical transaction information or introduce fabricated data.

Instead of modifying the original values, missing category name is replaced 
with 'Unknown', and data quality flag columns are added so analysts 
can identify these records when required.

Transformations:

1. Replace missing product categories with 'Unknown'.

Reason:
610 products have missing category names in the source data.
These products appear in 1,603 order items. Replacing missing
values with 'Unknown' preserves all sales records in category-
level analysis while clearly indicating that the original
category information was unavailable.

2. Add missing_description_flag
3. Add missing_dimension_flag
4. Add invalid_weight_flag
*/

-- Replacing missing categories with 'Unknown'
UPDATE products
SET category_name = 'Unknown'
WHERE category_name IS NULL;

-- adding columns for missing_description_flag, missing_dimension_flag, 
-- and invalid_weight_flag
ALTER TABLE products
ADD missing_description_flag BOOL NOT NULL DEFAULT 0,
ADD missing_dimension_flag BOOL NOT NULL DEFAULT 0,
ADD invalid_weight_flag BOOL NOT NULL DEFAULT 0;

-- Adding missing_description_flag
UPDATE products 
SET missing_description_flag = 1
WHERE name_length IS NULL
	OR description_length IS NULL
	OR photo_qty IS NULL;

-- Adding missing_dimension_flag    
UPDATE products
SET missing_dimension_flag = 1
WHERE weight_g IS NULL
		OR length_cm IS NULL
		OR height_cm IS NULL
		OR width_cm IS NULL;
        
-- Adding invalid_weight_flag
UPDATE products
SET invalid_weight_flag = 1
WHERE weight_g = 0;

-- Validation

SELECT COUNT(*)
FROM products
WHERE missing_description_flag = 1;

SELECT COUNT(*)
FROM products
WHERE missing_dimension_flag = 1;

SELECT COUNT(*)
FROM products
WHERE invalid_weight_flag = 1;
-- ----------------------------------------------------------


/* ----------------------------------------------------------
Category Translation Table
-------------------------------------------------------------

Data Preparation Summary

73 distinct product categories were identified in the products table,
while the category_translation table contains translations for only
71 categories.

The categories:
- pc_gamer
- portateis_cozinha_e_preparadores_de_alimentos

do not have corresponding English translations.

Objective:
Evaluate whether missing translations should be added or retained.

----------------------------------------------------------- */

/*
The missing translations are retained without modification.

Reasons:
1. The original Portuguese category names are valid source data.
2. Adding translations would require manual interpretation and
   introduce data that was not present in the original dataset.
3. During analysis, these categories will retain their original
   Portuguese names if no English translation is available.

No transformations were required.
*/


/* ----------------------------------------------------------
Orders Table
-------------------------------------------------------------

Data Preparation Summary

approved_at, carrier_at, and delivered_at contain missing values.
Most missing timestamps are consistent with the order status.

However, a small number of orders with status = 'delivered'
have missing timestamps:
- 14 missing approved_at
- 2 missing carrier_at
- 8 missing delivered_at

625 orders have a status of 'canceled'.
Among them:
- 619 orders have no delivery timestamp.
- 6 orders contain a delivery timestamp despite being marked as canceled.

Objective:
Determine whether these timestamps should be reconstructed
or retained.

----------------------------------------------------------- */

/*
The missing timestamps are retained without modification.

Reasons:
1. Timestamp values represent actual business events and
   cannot be inferred with certainty.
2. Estimating timestamps would introduce fabricated event data
   and could distort time-based analyses.
3. The affected records represent less than 0.02% of all orders
   and are therefore considered minor data quality anomalies.
   
The six canceled orders with delivery timestamps are retained
without modification.

Reason:
The dataset does not provide sufficient information to determine
whether these represent returned orders, late cancellations,
or data inconsistencies.

No transformations were applied.
*/


/* ----------------------------------------------------------
Order Items Table
-------------------------------------------------------------

Data Preparation Summary

- No duplicate records found.
- No missing values identified.
- Product price and freight values are valid.
- Relationship validation confirmed referential consistency
  with the orders and products tables.

No transformations required.

----------------------------------------------------------- */


/* ----------------------------------------------------------
Order Payments Table
-------------------------------------------------------------

Data Preparation Summary

Payment Attributes
------------------
- Payments were made using five payment methods.
- Three records have payment_type = 'not_defined'.
- Payment installments range from 0 to 24.
- Payment values range from 0.00 to 13,664.08.

Business Rule Validation
------------------------
- Nine payment records have a payment value of 0.00.
    • Three belong to canceled orders and have payment_type = 'not_defined'.
    • Six belong to voucher payments with payment_seq > 1.

- Two delivered orders contain a secondary credit card payment
  (payment_seq = 2) with installments = 0.

- 664 canceled orders have payment records.
  • 655 contain positive payment values.
  • 9 contain zero payment values.

- Some canceled orders contain completed payment records,
  including installment payments.

- After excluding insignificant rounding differences (≤ 0.01),
  303 orders remain where the total payment differs from the
  total value of ordered items plus freight.
    • 264 orders have payments greater than the calculated order total.
    • 39 orders have payments less than the calculated order total.
    • Only 17 of these orders contain multiple payment records,
      indicating that split payments are not the primary cause
      of the discrepancies.

- One delivered order has no corresponding record in the
  order_payments table.

Objective:
Evaluate whether payment anomalies require correction or
should be retained.

----------------------------------------------------------- */

/*
Data Preparation Decision

The payment records are retained without modification.

Reasons:

1. The table contains no missing values.

2. Payment-related anomalies cannot be resolved with certainty
   using the available data.

3. Positive payments associated with canceled orders may
   represent completed payments that were later refunded or
   canceled after payment. The dataset does not contain
   sufficient information to determine the final financial outcome.

4. Differences between payment totals and calculated order
   totals cannot be reliably corrected because the dataset
   does not provide supporting financial adjustment details
   such as refunds, credits, discounts, or reconciliation records.

5. The delivered order without a corresponding payment record
   represents a source data inconsistency and cannot be
   reconstructed without introducing fabricated data.

No transformations were applied.
During analysis, they can be excluded in the specific metrics where they distort the result.
*/


/* ----------------------------------------------------------
Order Reviews Table
-------------------------------------------------------------

Data Preparation Summary

- Some review_id values are associated with multiple orders.
  Records sharing the same review_id contain identical review
  titles, review messages, and timestamps, indicating that the
  same review has been linked to multiple orders.

- Some orders are associated with multiple review_id values.
  These reviews contain different titles and messages,
  representing separate review submissions rather than
  duplicated records.

- The dataset does not contain product-level review identifiers.
  Therefore, individual reviews cannot be associated with specific
  products within multi-item orders.

Objective:
Evaluate whether duplicate reviews require removal or
additional transformations.

----------------------------------------------------------- */

/*
Data Preparation Decision

The review records are retained without modification.

Reasons:

1. No duplicate rows were identified.

2. Repeated review_id values represent the same review linked
   to multiple orders rather than inconsistent review data.

3. Multiple reviews associated with a single order may represent
   distinct review submissions.

No transformations were applied.
*/


/* ----------------------------------------------------------
Geolocation Table
-------------------------------------------------------------

Data Preparation Summary

- The table contains 1,000,163 records, of which only 720,490
  are distinct row combinations.

- 131,546 groups of exact duplicate records were identified.

- Multiple geographic relationships exist within the data:
    • Coordinate pairs are associated with multiple
      zip_code_prefix values.
    • Coordinate pairs are associated with multiple cities.
    • zip_code_prefix values are associated with multiple
      cities and states.
    • Cities are associated with multiple states.

- No natural candidate key exists for this table.

Objective:
Determine whether duplicate records or inconsistent geographic
relationships require cleaning or normalization.

----------------------------------------------------------- */

/*
Data Preparation Decision

The geolocation records are retained without modification.

Reasons:

1. The dataset represents geolocation observations rather than
   a normalized geographic reference table.

2. Many-to-one and one-to-many relationships between
   zip_code_prefix, coordinates, cities, and states are
   characteristics of the source data rather than data errors.

3. Removing duplicate observations or enforcing a unique key
   could alter the original distribution of geographic records.
   
4. It will be treated as an independent lookup/observation table.

No transformations were applied.
*/


/* ===========================================================================

End of data preparation

Next step: 05_add_costraints

=========================================================================== */