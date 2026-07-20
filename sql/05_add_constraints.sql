/* ===========================================================

 Project : Brazilian E-commerce Analysis
 05_add_constraints.sql

Purpose: Adding constraints to the tables

============================================================= */

USE brazilian_ecommerce;
SHOW TABLES;

-- Adding constraints to the customer table

ALTER TABLE customers
ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);


-- Adding constraints to the seller table

ALTER TABLE sellers
ADD CONSTRAINT pk_sellers PRIMARY KEY (seller_id);


-- Adding constraints to the category translation table

ALTER TABLE category_translation
ADD CONSTRAINT pk_translation PRIMARY KEY (category);


-- Adding constraints to the products table

ALTER TABLE products
ADD CONSTRAINT pk_products PRIMARY KEY (product_id);
/*
Foreign key between products.category_name and
category_translation.category was intentionally
not created because two valid product categories
do not have corresponding translation records.
*/


-- Adding constraints to the orders table

ALTER TABLE orders
ADD CONSTRAINT pk_orders PRIMARY KEY (order_id),
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);


-- Adding constraints to the order items table

ALTER TABLE order_items
ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, item_no),
ADD CONSTRAINT fk_order
FOREIGN KEY (order_id) REFERENCES orders(order_id),
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id) REFERENCES products(product_id),
ADD CONSTRAINT fk_seller
FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);


-- Adding constraints to the order payments table

ALTER TABLE order_payments
ADD CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_seq),
ADD CONSTRAINT fk_payments_order
FOREIGN KEY (order_id) REFERENCES orders(order_id);


-- Adding constraints to the order reviews table

ALTER TABLE order_reviews
ADD CONSTRAINT pk_order_reviews PRIMARY KEY (review_id, order_id),
ADD CONSTRAINT fk_reviews_order
FOREIGN KEY (order_id) REFERENCES orders(order_id);

/* ===========================================================================

End of add_constraints

Next step: 06_analysis.sql

=========================================================================== */

