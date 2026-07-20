/* ===========================================================
 Project : Brazilian E-commerce Analysis
 File    : 06_analysis.sql

 Purpose:
 Business analysis using the prepared Olist dataset.

 Each section answers a business question using SQL
 and includes brief business insights.

=========================================================== */

USE brazilian_ecommerce;

-- ==========================================================
-- A. Sales Performance
-- ==========================================================

-- A1. Total revenue
SELECT 
	ROUND(SUM(price), 2) AS total_revenue
FROM order_items;
-- The marketplace generated total sales revenue of 13.59 million 
-- (based on product prices) during the available analysis period.

-- A2. Monthly sales trend and sales growth (MoM)
WITH sales_per_month AS
(	SELECT
		YEAR(o.purchased_at) AS year,
		MONTH(o.purchased_at) AS month,
		SUM(price) AS sales_by_month,
		LAG(SUM(price), 1) OVER
			(ORDER BY YEAR(o.purchased_at), MONTH(o.purchased_at)) AS previous_month_sales
	FROM order_items i
	JOIN orders o
		ON i.order_id = o.order_id
	GROUP BY year, month
)
SELECT  
	year,
	month,
    sales_by_month AS current_month_sales,
	previous_month_sales,
	ROUND( 
		(sales_by_month - previous_month_sales) * 100 
			/ previous_month_sales, 2
	)  AS MoM_growth
FROM sales_per_month;
-- Monthly sales revenue showed steady growth throughout 2017, peaking 
-- in November 2017 before stabilizing during 2018. The unusually large 
-- month-over-month fluctuations at the beginning and end of the dataset are 
-- due to partial-month data and should not be interpreted as actual business trends.

-- A3. Average, highest and lowest order values
SELECT
	ROUND(AVG(o.order_value), 2) AS avg_order_value,
    MAX(o.order_value) AS max_order_value,
    MIN(o.order_value) AS min_order_value
FROM (
	SELECT
		order_id,
		SUM(price) AS order_value
	FROM order_items
	GROUP BY order_id
) o;
-- Order values varied widely, ranging from less than 1 currency 
-- unit to over 13,000, while the average order value was 137.75. 
-- This indicates that although most purchases were relatively modest, 
-- a small number of high-value orders contributed disproportionately 
-- to overall sales revenue.

-- A4. Order growth (MoM)
WITH orders_per_month AS
(	SELECT
		YEAR(purchased_at) AS year,
		MONTH(purchased_at) AS month,
        COUNT(order_id) AS order_cnt,
		LAG(COUNT(order_id), 1) OVER(ORDER BY YEAR(purchased_at), MONTH(purchased_at)) AS previous_month_orders
	FROM orders
    GROUP BY year, month
)
SELECT  
	year,
	month,
    order_cnt AS current_month_orders,
    previous_month_orders,
	ROUND( 
		(order_cnt - previous_month_orders) * 100 
			/ previous_month_orders, 2
	)  AS MoM_growth
FROM orders_per_month;
-- Order volumes followed a pattern similar to sales revenue, growing 
-- consistently throughout 2017 and reaching their highest level in 
-- November 2017. The exceptionally high growth rates in the first months 
-- and sharp declines in the final months are attributable to incomplete monthly data.

-- A5. Orders by state
SELECT 
	c.state,
	COUNT(o.order_id) AS orders
FROM orders o 
JOIN customers c
	ON o.customer_id = c.customer_id
GROUP BY c.state
ORDER BY orders DESC;
-- São Paulo (SP) accounted for the highest number of orders by a wide margin, 
-- followed by Rio de Janeiro (RJ) and Minas Gerais (MG). Together, 
-- these states represented a substantial share of marketplace demand, 
-- while the remaining states contributed progressively smaller order volumes.

-- A6. Revenue by state
SELECT 
	c.state,
    SUM(price) AS state_revenue
FROM order_items i
JOIN orders o
	ON i.order_id = o.order_id
JOIN customers c
	ON o.customer_id = c.customer_id
GROUP BY c.state
ORDER BY state_revenue DESC;
-- Sales revenue closely followed the order distribution across states. 
-- São Paulo generated the highest revenue, followed by Rio de Janeiro 
-- and Minas Gerais, indicating that the states with the largest 
-- customer base also contributed the greatest share of sales.

-- ----------------------------------------------------------


-- ==========================================================
-- B. Customer Analysis
-- ==========================================================

-- B1. Top customers by spending, with the order counts
SELECT 
	c.customer_unique_id,
    SUM(i.price) AS total_spent,
    COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items i
	ON o.order_id = i.order_id
GROUP BY customer_unique_id
ORDER BY total_spent DESC, order_count DESC
LIMIT 10;
-- Customer spending was highly concentrated. The highest-spending customer 
-- generated 13,440 in sales from a single order, while most of the remaining 
-- top customers also achieved their lifetime spending through only one or 
-- two purchases. This suggests that exceptionally high customer value was 
-- driven more by large order sizes than by frequent purchases.

-- B2. Top customers by orders, with the total spent
SELECT 
	c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(i.price) AS total_spent
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items i
	ON o.order_id = i.order_id
GROUP BY customer_unique_id
ORDER BY order_count DESC, total_spent DESC
LIMIT 10;
-- Customers with the highest purchase frequency were not necessarily 
-- the highest spenders. The most active customer placed 16 orders but 
-- spent only 729.62 in total, highlighting that frequent purchasing did 
-- not always translate into the greatest customer lifetime value.

-- B3. Average customer spend
SELECT 
	ROUND(AVG(total_spent), 2) AS avg_cust_spend
FROM 
(	SELECT 
		c.customer_unique_id,
		SUM(i.price) AS total_spent
	FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	JOIN order_items i
		ON o.order_id = i.order_id
	GROUP BY customer_unique_id
) cs;
-- The average customer lifetime spend was 142.44, considerably lower 
-- than the spending of the top customers. This indicates that a 
-- relatively small number of high-value customers contributed 
-- disproportionately to total sales revenue.

-- B4. New vs repeat customers
WITH first_purchases AS
(	SELECT
		c.customer_unique_id,
		MIN(o.purchased_at) AS first_purchase
	FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	GROUP BY c.customer_unique_id
)
SELECT 
	YEAR(purchased_at) year,
    MONTH(purchased_at) month,
    SUM(CASE 
			WHEN o.purchased_at = first_purchase
            THEN 1
            ELSE 0
		END
		) AS new_customers,
    SUM(CASE 
			WHEN o.purchased_at > first_purchase
            THEN 1
            ELSE 0
		END
		) AS repeat_customers
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
JOIN first_purchases fp
	ON c.customer_unique_id = fp.customer_unique_id
GROUP BY year, month
ORDER BY year, month;
-- New customers consistently outnumbered repeat customers throughout 
-- the analysis period. Although the number of repeat purchases gradually 
-- increased over time, they remained a relatively small proportion of 
-- monthly customers, indicating that most orders came from first-time buyers..

-- B5. Customers by state
SELECT 
	state,
    COUNT(DISTINCT customer_unique_id) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;
-- Customer distribution closely mirrored the order distribution, 
-- with São Paulo having the largest customer base. Most states 
-- exhibited similar rankings for both customers and orders, 
-- suggesting that higher sales volumes were primarily driven by 
-- a larger number of customers rather than unusually high purchasing frequency.

-- ----------------------------------------------------------


-- ==========================================================
-- C. Product Analysis
-- ==========================================================

-- C1. Best-selling categories
SELECT 
	COALESCE(t.category_english, p.category_name) AS product_category,
    COUNT(o.product_id) AS items_sold
FROM products p
LEFT JOIN category_translation t
	ON p.category_name = t.category
JOIN order_items o
	ON p.product_id = o.product_id
GROUP BY product_category
ORDER BY items_sold DESC, product_category
LIMIT 10;
-- Bed, Bath & Table is the most frequently purchased category, 
-- followed by Health & Beauty and Sports & Leisure. 
-- These categories account for a significant share of item sales, 
-- indicating consistently high customer demand for household and lifestyle products.

-- C2. Highest revenue categories, with order volumes
SELECT 
	COALESCE(t.category_english, p.category_name) AS product_category,
    SUM(o.price) AS revenue,
    COUNT(o.product_id) AS items_sold
FROM products p
LEFT JOIN category_translation t
	ON p.category_name = t.category
JOIN order_items o
	ON p.product_id = o.product_id
GROUP BY product_category
ORDER BY revenue DESC, product_category
LIMIT 10;
-- Health & Beauty generated the highest revenue despite ranking second in
-- items sold, indicating a higher average selling price than the top-selling
-- Watches & Gifts also outperformed several higher-volume categories,
-- suggesting that higher-priced products contribute significantly to revenue.

-- C3. Highest revenue products
SELECT 
	p.product_id,
    SUM(o.price) AS product_sales
FROM products p
JOIN order_items o
	ON p.product_id = o.product_id
GROUP BY product_id
ORDER BY product_sales DESC
LIMIT 10;
-- A small number of individual products contribute disproportionately to total revenue. 
-- Identifying these products can help prioritize inventory management, 
-- supplier relationships, and promotional strategies.

-- C4. Average product price
SELECT 
    ROUND(AVG(price), 2) AS avg_product_price
FROM order_items;
-- The average selling price per ordered product is 120.65.
-- Compared with the average order value of 137.75, this suggests 
-- that many orders contained only a single product or a small 
-- number of moderately priced items.

-- C5. Freight by product category
SELECT 
	COALESCE(t.category_english, p.category_name) AS product_category,
    ROUND(AVG(o.freight_value), 2) AS avg_freight_value
FROM products p
LEFT JOIN category_translation t
	ON p.category_name = t.category
JOIN order_items o
	ON p.product_id = o.product_id
GROUP BY product_category
ORDER BY avg_freight_value DESC; 
-- Furniture, large appliances, and computer-related categories have the 
-- highest average freight costs, likely reflecting larger or heavier products. 
-- Understanding freight-intensive categories can support pricing and logistics optimization.
	
-- ----------------------------------------------------------


-- ==========================================================
-- D. Seller performance
-- ==========================================================

-- D1. Top sellers by revenue, with products sold
SELECT 
	seller_id,
    SUM(price) AS revenue,
    COUNT(product_id) AS items_sold
FROM order_items
GROUP BY seller_id
ORDER BY revenue DESC, items_sold DESC
LIMIT 10;
-- Revenue is concentrated among a relatively small number of sellers. 
-- While some sellers generate high revenue through large sales volumes, 
-- others achieve comparable revenue with fewer sales, 
-- indicating differences in average product prices.

-- D2. Top sellers by products sold, with revenues
SELECT 
	seller_id,
    COUNT(product_id) AS items_sold,
    SUM(price) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY items_sold DESC, revenue DESC
LIMIT 10;
-- High sales volume does not necessarily translate into the highest revenue. 
-- Some sellers achieve strong revenue despite selling fewer items, 
-- suggesting they specialize in higher-priced products.

-- D3. Average orders per seller, and average revenue per seller
SELECT
	ROUND(AVG(so.seller_orders)) AS avg_orders_per_seller,
	ROUND(AVG(so.revenue), 2) AS avg_revenue_per_seller
FROM (
	SELECT 
		seller_id,
		SUM(price) AS revenue,
		COUNT(product_id) AS seller_orders
	FROM order_items
	GROUP BY seller_id
) so;
-- On average, each seller sold approximately 36 items and generated 
-- about 4,391 in product revenue during the observed period. 
-- Comparing these averages with the top sellers highlights 
-- the significant variation in seller performance across the marketplace.

-- D4. Sellers by state
SELECT 
	state,
    COUNT(DISTINCT seller_id) AS seller_count
FROM sellers
GROUP BY state
ORDER BY seller_count DESC;
-- Seller locations were far more concentrated than customer locations. 
-- São Paulo alone accounted for nearly 60% of all sellers, while over 
-- 90% of sellers were located in just five states (SP, PR, MG, SC, and RJ). 
-- This indicates that the marketplace's seller network was heavily 
-- concentrated in Brazil's southeastern and southern regions.

-- ----------------------------------------------------------


-- ==========================================================
-- E. Delivery Performance
-- ==========================================================

-- E1. Average, shortest and longest delivery times
SELECT 
	ROUND(AVG(DATEDIFF(delivered_at, purchased_at))) AS avg_delivery_time,
	MIN(DATEDIFF(delivered_at, purchased_at)) AS min_delivery_time,
	MAX(DATEDIFF(delivered_at, purchased_at)) AS max_delivery_time
FROM orders
WHERE delivered_at IS NOT NULL;
-- The average delivery time was 12 days, with deliveries ranging from 
-- the same day to 210 days. The large gap between the average and 
-- maximum delivery times suggests the presence of a small number of 
-- unusually long deliveries, warranting a closer look at the distribution.

-- E2. Delivery time distribution
SELECT 
    CASE 
        WHEN DATEDIFF(delivered_at, purchased_at) = 0 THEN '01. Same Day          '
        WHEN DATEDIFF(delivered_at, purchased_at) BETWEEN 1 AND 3 THEN '02. 1-3 Days'
        WHEN DATEDIFF(delivered_at, purchased_at) BETWEEN 4 AND 7 THEN '03. 4-7 Days'
        WHEN DATEDIFF(delivered_at, purchased_at) BETWEEN 8 AND 14 THEN '04. 8-14 Days'
        WHEN DATEDIFF(delivered_at, purchased_at) BETWEEN 15 AND 30 THEN '05. 15-30 Days'
        WHEN DATEDIFF(delivered_at, purchased_at) BETWEEN 31 AND 60 THEN '06. 1-2 Months'
        WHEN DATEDIFF(delivered_at, purchased_at) BETWEEN 61 AND 90 THEN '07. 2-3 Months'
        ELSE '08. Over 3 Months'
    END AS delivery_window,
    COUNT(*) AS order_count
FROM orders
WHERE delivered_at IS NOT NULL
GROUP BY 
    delivery_window
ORDER BY 1;
-- Despite an average delivery time of 12 days, most orders were delivered 
-- within 8–14 days, followed by 4–7 days. Deliveries taking longer than 30 days 
-- were relatively uncommon, while only 77 orders exceeded 90 days, indicating that 
-- the average delivery time is influenced by a small number of exceptionally long deliveries.

-- E3. Delayed deliveries
SELECT 
	COUNT(order_id) AS total_orders,
	SUM(
		CASE WHEN delivered_at > estimated_delivery THEN 1 
        ELSE 0 
        END
        ) AS delayed_deliveries,
	SUM(
		CASE WHEN delivered_at <= estimated_delivery THEN 1 
        ELSE 0 
        END
        ) AS delivered_on_time,
	SUM(
		CASE WHEN delivered_at IS NULL THEN 1
        ELSE 0
        END
        ) AS delivery_info_unavailable
FROM orders;
-- Among orders with recorded delivery dates, approximately 92% were delivered 
-- on or before the estimated delivery date, while only 8% experienced delays. 
-- Delivery information was unavailable for 2,965 orders, which were excluded from 
-- the delivery performance comparison because they could not be classified as either on-time or delayed.

-- E4. Carrier pickup time
SELECT 
	ROUND(AVG(DATEDIFF(carrier_at, purchased_at))) AS avg_carrier_pickup_time,
    MAX(DATEDIFF(carrier_at, purchased_at)) AS max_carrier_pickup_time
FROM orders
WHERE carrier_at IS NOT NULL
AND carrier_at >= purchased_at;
-- Orders were handed over to shipping carriers within an average of 3 days after purchase. 
-- Some orders were dispatched on the same day, while 
-- a small number experienced substantially longer pickup delays.
-- with the maximum reaching 126 days after excluding anomalous negative timestamps.

-- ----------------------------------------------------------

-- ==========================================================
-- F. Payment Analysis
-- ==========================================================

-- F1. Payment type distribution
SELECT 
	payment_type,
    count(*) AS transactions
FROM order_payments
WHERE payment_value > 0
GROUP BY payment_type
ORDER BY transactions DESC;
-- Credit cards dominated the payment methods, accounting 
-- for the vast majority of payment transactions. 
-- Boleto was the second most frequently used payment method, while 
-- voucher and debit card payments represented a much smaller share.

-- F2. Installment usage
SELECT 
	installments,
    COUNT(order_id) AS transactions
FROM order_payments
WHERE payment_value > 0
GROUP BY installments
ORDER BY transactions DESC;
-- Single-payment transactions were by far the most common, with 
-- installment usage declining steadily as the number of installments 
-- increased. Although installment plans of up to 24 payments 
-- were available, they were used only rarely.

-- F3. Orders with multiple payment methods
SELECT 
	COUNT(*) multiple_payment_orders
FROM (
	SELECT 
		order_id,
		COUNT(DISTINCT payment_type) AS payment_types
	FROM order_payments
    WHERE payment_value > 0
	GROUP BY order_id
	HAVING payment_types > 1
) p;
-- Most orders were paid using a single payment method. 
-- Only about 2% of orders combined multiple payment methods, 
-- indicating that split payments were relatively uncommon

-- F4. Average payment value by payment type
SELECT 
	payment_type,
    ROUND(AVG(payment_value), 2) AS avg_payment
FROM order_payments
WHERE payment_value > 0
GROUP BY payment_type
ORDER BY avg_payment;
-- Credit card transactions had the highest average payment value, 
-- while voucher payments were typically used for smaller purchases. 
-- Debit card and boleto transactions showed similar average payment values.	

-- ----------------------------------------------------------

-- ==========================================================
-- G. Order Status Analysis
-- ==========================================================

-- G1. Order status distribution
SELECT 
	status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count DESC;
-- The vast majority of orders (97.0%) reached the 'delivered' status. 
-- Orders remaining in intermediate statuses such as 'processing', 'shipped', 
-- or 'approved' accounted for only a small proportion of the dataset, while 
-- cancelled and unavailable orders together represented approximately 1.2% of all orders.

-- G2. Cancellation rate
SELECT
	ROUND(AVG(status = 'canceled') * 100, 2) AS cancellation_rate
FROM orders;
-- Only 0.63% of orders were cancelled, indicating a very low cancellation rate.

-- G3. Delivery success rate
SELECT
	ROUND(AVG(status = 'delivered') * 100, 2) AS delivered_rate
FROM orders;
-- Approximately 97% of orders were successfully completed and reached the 
-- 'delivered' status, indicating a high order fulfillment rate.

-- ----------------------------------------------------------


-- ==========================================================
-- H. Customer Reviews
-- ==========================================================

-- H1. Review score distribution
SELECT
	score,
    COUNT(*) AS review_count
FROM order_reviews
GROUP BY score
ORDER BY review_count DESC;
-- Five-star reviews were the most common, accounting for more than half 
-- of all review records. Four-star reviews were the second most frequent, 
-- while low ratings (1–2 stars) represented a considerably smaller 
-- proportion, indicating generally positive customer feedback.

-- H2. Average review score
SELECT 
	ROUND(AVG(score), 2) AS average_score
FROM order_reviews;
-- The average review score was 4.09 out of 5, suggesting a 
-- generally positive customer experience across the marketplace.

-- H3. Review vs delivery time
SELECT
	score,
    ROUND(AVG(DATEDIFF(delivered_at, purchased_at)), 2) AS average_delivery_time
FROM order_reviews r
JOIN orders o
	ON r.order_id = o.order_id
GROUP BY score
ORDER BY average_delivery_time DESC;
-- Lower review scores were associated with longer delivery times. 
-- Orders receiving five-star reviews were delivered in approximately 
-- 11 days on average, whereas one-star reviews corresponded to an 
-- average delivery time of over 21 days, suggesting a  
-- relationship between delivery speed and customer satisfaction.
	
-- -----------------------------------------------------------


/* ===========================================================
Key Business Insights
--------------------------------------------------------------

1. The marketplace generated total sales revenue of 13.59 million
   (based on product prices) during the analysis period.

2. Sales revenue and order volumes grew steadily throughout 2017,
   peaking in November 2017 before stabilizing in 2018.

3. Customer spending was highly concentrated, with the highest
   lifetime value reaching 13,440, while most customers placed
   only a single order.

4. New customers consistently outnumbered repeat customers,
   indicating that repeat purchasing represented only a small
   proportion of monthly orders.

5. Health & Beauty, Watches & Gifts, Bed & Bath Table, and
   Sports & Leisure were among the strongest-performing
   product categories by sales revenue.

6. Seller performance varied considerably, with a small number
   of sellers generating substantially higher sales than the
   marketplace average.

7. Most deliveries were completed within two weeks, while
   delayed deliveries accounted for less than 8% of all orders.
   Longer delivery times were associated with lower customer
   review scores.

8. Credit cards were the dominant payment method, and
   single-installment payments were the most common.

9. Approximately 97% of orders were successfully delivered,
   while the cancellation rate remained below 1%.

10. Customer reviews were generally positive, with an average
    rating of 4.09 out of 5, indicating a high overall level of
    customer satisfaction.

=========================================================== */

/* ===========================================================
Notes

- Revenue analysis is based on product prices (order_items.price)
  rather than payment values because payment records may include
  multiple transactions, vouchers, installments, refunds, or
  other payment-related adjustments.

- Customer-level analysis uses customer_unique_id to represent
  unique customers across multiple orders.

- Review analysis is based on review records. During data
  profiling, the dataset was found to contain review anomalies,
  including review IDs associated with multiple orders and
  multiple reviews linked to a single order.

=========================================================== */
