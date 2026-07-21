# Project Overview

## Brazilian E-commerce Analysis using MySQL

---

## 1. Introduction

This project demonstrates an end-to-end SQL workflow using the **Brazilian E-commerce Public Dataset by Olist**. The project follows a structured ETL (Extract, Transform, Load) process to build a relational database in MySQL, assess data quality, prepare the data for analysis, enforce referential integrity, and finally perform business analysis.

This project emphasizes the practical responsibilities of a Data Analyst, including database design, data profiling, business rule validation, data preparation, documentation, and business-oriented SQL analysis

---

# 2. Project Objectives

The objectives of this project are to:

* Design a normalized relational database using MySQL.
* Import raw CSV files into relational tables.
* Profile every table to understand data quality and business characteristics.
* Identify missing values, duplicate records, structural inconsistencies, and business rule anomalies.
* Apply appropriate data preparation techniques while preserving the integrity of the source data.
* Enforce data integrity using primary and foreign key constraints wherever supported by the dataset.
* Perform business analysis using SQL to answer practical business questions.
* Document every stage of the workflow.

---

# 3. Dataset Description

The project uses the **Brazilian E-commerce Public Dataset by Olist**, which contains transactional data from a Brazilian online marketplace.

The dataset includes information about:

* Customers
* Sellers
* Products
* Product Categories
* Orders
* Order Items
* Payments
* Customer Reviews
* Geolocations

These tables collectively represent a complete e-commerce ecosystem, making the dataset well suited for practicing relational database design, ETL processes, data quality assessment, and analytical SQL.

---

# 4. ETL Workflow

The project follows a structured ETL pipeline.

```text
Raw CSV Files
        │
        ▼
01_create_tables.sql
        │
        ▼
02_load_data.sql
        │
        ▼
03_profile_data.sql
        │
        ▼
04_prepare_data.sql
        │
        ▼
05_add_constraints.sql
        │
        ▼
06_analysis.sql
```

Separating the workflow into individual stages improves readability, simplifies debugging, and clearly documents the purpose of each stage.

---

# 5. Database Design

The database was designed using normalized relational tables based on the structure of the source dataset.

The schema consists of dimension tables, transaction tables, and supporting lookup tables designed to support efficient storage, integrity, and analysis.

**Entity Relationship Diagram**

![ER Diagram](images/ER_Diagram.png)


## Database Tables

**Dimension Tables**

Customers
Sellers
Products
Category Translation

**Transaction Tables**

Orders
Order Items
Order Payments
Order Reviews

**Supporting Table**

Geolocation

Primary and foreign key constraints were added after data loading and data preparation to simplify bulk imports and ensure integrity only after the data had been validated.

---

# 6. Data Profiling Methodology

A dedicated profiling stage was created before any transformations were applied.

Each table was examined for:

* Record counts
* Duplicate records
* Missing values
* Basic descriptive statistics
* Candidate keys
* Business rule validation
* Relationship validation

Beyond standard profiling, cross-table investigations were performed to better understand the quality and consistency of the dataset.

Examples include:

* Verifying whether products with missing attributes participated in completed sales.
* Comparing payment totals against calculated order values.
* Validating timestamp consistency across order statuses.
* Investigating review relationships between orders and review identifiers.
* Examining geographical relationships within the geolocation table.

These investigations helped ensure that the SQL analysis was based on a well-understood dataset, reducing the risk of misleading conclusions caused by data quality issues.

---

# 7. Data Preparation Strategy

Data preparation focused on improving analytical usability while preserving the integrity of the original dataset.

Instead of attempting to "clean" every inconsistency, each observation was evaluated individually before deciding whether a transformation was justified.

Examples include:

* Creating quality flags for products with incomplete descriptive information.
* Preserving products with missing attributes because they participated in completed sales.
* Replacing missing product category values with 'Unknown' to improve analytical reporting while preserving the fact that the original category was unavailable.
* Retaining payment anomalies where supporting financial information was unavailable.
* Preserving timestamp inconsistencies that could not be corrected with certainty.
* Retaining review and geolocation characteristics that reflected the structure of the original dataset.

This approach minimizes the introduction of assumptions while maintaining analytical transparency.

---

# 8. Data Preparation Principles

The project follows the following principles throughout the ETL process.

**Preserve Source Data**

Original records are preserved whenever the correct value cannot be determined with confidence.

**Evidence-Based Transformations**

Transformations are applied only when supported by sufficient evidence from the dataset.

**Document Before Modifying**

Every anomaly is investigated and documented before deciding whether any action is required.

**Prefer Flags Over Fabrication**

Where appropriate, data quality flags are used instead of replacing unknown values or deleting records.

**Maintain Reproducibility**

Every transformation and design decision is documented to ensure that the workflow can be reproduced and audited.

---

# 9. Constraint Strategy

Primary keys and foreign keys were added only after the data preparation stage.

This approach offers several advantages:

* Simplifies bulk data loading.
* Allows profiling before enforcing integrity rules.
* Prevents unnecessary loading failures caused by temporary inconsistencies.
* Ensures that constraints reflect validated data.

Not every potential relationship was enforced.

For example, a foreign key between the `products` and `category_translation` tables was intentionally omitted because two valid product categories in the source dataset did not have corresponding translation records. Preserving the original data was prioritized over enforcing referential integrity for this lookup relationship.

---

# 10. Business Analysis

The prepared database was analyzed across multiple business themes to evaluate marketplace performance and customer behavior. The analysis includes sales performance, customer analysis, product performance, seller performance, delivery performance, payment analysis, order status, and customer reviews. Each section combines SQL queries with business interpretation to identify meaningful trends, customer behavior and operational insights.

The analytical queries make extensive use of joins, aggregate functions, Common Table Expressions (CTEs), and window functions to evaluate marketplace performance from multiple business perspectives.

---

# 11. Key Business Insights

* The marketplace generated around 13.59 million in revenue from product prices over the analysis period. (based on product prices).
* Sales and order volumes showed strong growth throughout 2017, reaching their highest levels in November 2017.
* Customer spending was highly concentrated among a relatively small number of high-value customers, while repeat purchasing remained comparatively low.
* Health & Beauty, Watches & Gifts, and Bed & Bath Table generated the highest product revenue.
* Seller performance varied significantly, with a relatively small group of sellers contributing a substantial share of marketplace revenue.
* Most deliveries were completed within two weeks, and faster deliveries were generally associated with higher customer review scores.
* Credit cards dominated payment behavior, with single-installment payments being the most common option.
* Approximately 97% of orders were successfully delivered, while cancellations remained below 1%, indicating strong overall fulfillment performance.

# 12. Opportunities for Further Analysis

Based on the analysis, several areas may warrant deeper business investigation:

* Understand the factors contributing to low customer repeat purchase rates.
* Investigate why a small number of sellers generate a disproportionately large share of revenue.
* Explore operational improvements for the relatively small number of long delivery times.
* Explore opportunities to expand or further optimize high-performing product categories.
* Analyze seasonal demand patterns to better prepare for peak sales periods.

# 13. Project Limitations

The insights presented in this project are based on the information available in the Olist dataset. Several limitations should be considered when interpreting the results:

* Revenue analysis is based on product prices, as the dataset does not allocate payment amounts to individual products within an order.
* Discounts, promotions, and refunds cannot be analyzed because detailed pricing adjustments are not available.
* The dataset represents a historical snapshot rather than a continuously updated marketplace, limiting long-term trend analysis.
* Business recommendations are intentionally limited to conclusions supported by the available data. Factors such as inventory levels, marketing campaigns, operational costs, and  profitability are outside the scope of this dataset.
Certain source data anomalies (such as payment inconsistencies and review relationships) were intentionally preserved and documented rather than corrected when the true values could not be determined