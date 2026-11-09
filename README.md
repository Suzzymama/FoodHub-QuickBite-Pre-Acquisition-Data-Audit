# FoodHub × QuickBite: Pre-Acquisition Data Audit

**A SQL-driven due diligence analysis of two food delivery platforms ahead of a proposed acquisition.**

This project investigates customer records, customer overlap, restaurant rating discrepancies and combined revenue across FoodHub and QuickBite. Using MySQL, the analysis addresses four business questions raised by key stakeholders to support data validation and financial decision-making ahead of the proposed merger.

## 1\. Business Context

FoodHub is acquiring its biggest rival, QuickBite. Before the acquisition is finalised, the data team has been tasked with investigating the integrity and consistency of records across both platforms.

Four stakeholders have raised questions requiring investigation:

|Stakeholder|Business Question|
|-|-|
|Compliance|Which orders have a corresponding customer record?|
|Marketing|Which customers use both platforms, and which are exclusive to either platform?|
|Restaurant Partnerships|Are the same restaurants listed on both platforms with different ratings?|
|Finance|What is the combined revenue after accounting for duplicate orders?|

The objective is to use SQL to investigate these questions, identify potential data inconsistencies and provide actionable findings to support the acquisition process.



## 2\. Executive Summary

The analysis produced the following findings:

|#|Area of Investigation|Key Finding|
|-|-|-|
|1|Customer Verification|All 34 orders (20 FoodHub and 14 QuickBite) have corresponding customer records. No orphaned orders were identified in the reported LEFT JOIN check.|
|2|Customer Overlap|13 unique customers were identified across both platforms. Five customers appear on both platforms, five are exclusive to FoodHub, and three are exclusive to QuickBite.|
|3|Restaurant Ratings|Five restaurants appear on both platforms. The average absolute rating difference is 0.16 points.|
|4|Combined Revenue|Reported combined revenue is $875.50 across 34 orders, using UNION to eliminate identical order records. This figure is subject to the duplicate-identification assumptions discussed in Section 4.|

**Key takeaway:** The analysis identified a shared customer base, differences in restaurant ratings and a preliminary combined revenue figure. However, customer matching and order deduplication require stronger identifiers before the findings can be treated as definitive acquisition due diligence.

## 3\. Data Overview

The analysis uses six tables distributed across two MySQL databases.

|Database|Table|Key Columns|
|-|-|-|
|FoodHub|customers|customer\_id, name, city|
|FoodHub|orders|order\_id, customer\_id, restaurant\_id, item\_name, quantity, order\_date, price|
|FoodHub|restaurants|restaurant\_id, name, cuisine, avg\_rating|
|QuickBite|customers|customer\_id, name, city|
|QuickBite|orders|order\_id, customer\_id, restaurant\_id, item\_name, quantity, order\_date, price|
|QuickBite|restaurants|restaurant\_id, name, cuisine, avg\_rating|

**Data source:** ALX synthetic dataset.

**Tools:** MySQL.



## 4\. Approach and Findings

### Question 1: Customer Verification – Identifying Orphaned Orders

**Stakeholder:** Compliance

**Objective:** Identify orders that have a corresponding customer record and determine whether any orders exist without a matching customer.

**Methodology:**

An INNER JOIN was initially used to retrieve orders with matching customer records. However, an INNER JOIN excludes unmatched records, making it unsuitable for independently establishing whether orphaned orders exist.

A LEFT JOIN provides a more appropriate validation method because it retains every order, including those without a corresponding customer record.

**SQL approach:**

```sql
-- FoodHub: Check for orders without matching customers

SELECT
    o.order_id,
    o.customer_id,
    c.name AS customer_name
FROM foodhub.orders o
LEFT JOIN foodhub.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

The same validation should be performed against QuickBite:

```sql
-- QuickBite: Check for orders without matching customers

SELECT
    o.order_id,
    o.customer_id,
    c.name AS customer_name
FROM quickbite.orders o
LEFT JOIN quickbite.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

**Findings:**

The reported LEFT JOIN validation returned no NULL customer matches across either platform.

|Platform|Total Orders|Orders with Matching Customers|Orphaned Orders|
|-|-:|-:|-:|
|FoodHub|20|20|0|
|QuickBite|14|14|0|
|**Combined**|**34**|**34**|**0**|

**Business Interpretation:**

All 34 orders have corresponding customer records in their respective databases. No orphaned orders were identified.

This indicates that the order records satisfy the customer-reference check. However, the presence of a matching customer record does not independently verify the customer's identity or establish that the underlying transaction is legitimate.

**Recommendation:** Compliance should retain this validation as part of the acquisition audit and investigate any future unmatched records before integrating the databases.

### Question 2: Customer Overlap – Shared and Platform-Exclusive Customers

**Stakeholder:** Marketing

**Objective:** Identify customers who use both platforms and distinguish them from customers who appear exclusively on either platform.

**Methodology:**

The customer names from both databases were compared using SQL set operations and subqueries.

Three categories were investigated:

1. All unique customers across both platforms.
2. Customers appearing on both platforms.
3. Customers appearing exclusively on either platform.

The analysis used customer names as the matching key.

**SQL approach:**

```sql
-- All unique customers across both platforms

SELECT name
FROM quickbite.customers

UNION

SELECT name
FROM foodhub.customers

ORDER BY name;
```

```sql
-- Customers appearing on both platforms

SELECT DISTINCT
    q.name AS customer_name
FROM quickbite.customers q
WHERE EXISTS (
    SELECT 1
    FROM foodhub.customers f
    WHERE LOWER(TRIM(q.name)) = LOWER(TRIM(f.name))
)
ORDER BY customer_name;
```

```sql
-- QuickBite-exclusive customers

SELECT
    q.name AS customer_name
FROM quickbite.customers q
WHERE NOT EXISTS (
    SELECT 1
    FROM foodhub.customers f
    WHERE LOWER(TRIM(q.name)) = LOWER(TRIM(f.name))
)
ORDER BY customer_name;
```

```sql
-- FoodHub-exclusive customers

SELECT
    f.name AS customer_name
FROM foodhub.customers f
WHERE NOT EXISTS (
    SELECT 1
    FROM quickbite.customers q
    WHERE LOWER(TRIM(f.name)) = LOWER(TRIM(q.name))
)
ORDER BY customer_name;
```

*Note: LOWER() and TRIM() improve matching by removing case and leading/trailing whitespace differences.*

**Findings**

**A. Combined Customer Base**

|Customer Name|
|-|
|Aisha Conteh|
|Amara Osei|
|David Kimani|
|Emeka Eze|
|Fatima Al-Rashid|
|Kofi Mensah|
|Liam Okonkwo|
|Nadia Osei|
|Priya Nair|
|Sofia Andrade|
|Tariq Hassan|
|Yemi Adeyemi|
|Zanele Dube|

Total unique customers: **13**



**B. Shared Customers**

|Customer Name|
|-|
|Aisha Conteh|
|Fatima Al-Rashid|
|Liam Okonkwo|
|Priya Nair|
|Zanele Dube|

Total shared customers: **5**

**C. QuickBite-Exclusive Customers**

|Customer Name|
|-|
|Nadia Osei|
|Tariq Hassan|
|Yemi Adeyemi|

Total: **3**

**D. FoodHub-Exclusive Customers**

|Customer Name|
|-|
|Amara Osei|
|David Kimani|
|Emeka Eze|
|Kofi Mensah|
|Sofia Andrade|

Total: **5**

**Customer Overlap Analysis**

|Customer Category|Count|Percentage of Unique Customer Base|
|-|-:|-:|
|Shared customers|5|38.5%|
|FoodHub exclusive|5|38.5%|
|QuickBite exclusive|3|23.1%|
|**Total**|**13**|**100%**|

The percentage for shared customers is calculated as:

`(5 / 13) × 100 = 38.5%`

**Business Interpretation:**

Five customers appear in both databases, representing 38.5% of the combined unique customer base.

The remaining eight customers are exclusive to one platform: five to FoodHub and three to QuickBite.

This indicates an existing customer overlap that could support cross-platform marketing and customer retention initiatives following the acquisition.

**Recommendations:**

* Marketing can develop targeted campaigns for the eight platform-exclusive customers to encourage cross-platform engagement.
* Shared customers should be identified and consolidated into a unified customer database to prevent duplicate customer records and marketing communications.
* Customer matching should ideally be performed using a unique identifier, such as email address or phone number, rather than names alone. Where these are unavailable, combining names with other identifying fields, such as city, would provide a stronger matching approach.

\---

### Question 3: Restaurant Rating Comparison

**Stakeholder:** Restaurant Partnerships

**Objective:** Identify restaurants listed on both platforms and investigate differences in their average customer ratings.

**Methodology:**

An INNER JOIN was used to match restaurants across the two databases using their names.

Restaurant IDs were not used because they are independently generated within each platform. Consequently, the same restaurant may have different IDs in FoodHub and QuickBite.

The absolute difference between the two average ratings was calculated using the ABS() function.

**SQL Query:**

```sql
SELECT
    f.name AS restaurant_name,
    f.avg_rating AS foodhub_rating,
    q.avg_rating AS quickbite_rating,
    ABS(f.avg_rating - q.avg_rating)
        AS rating_difference
FROM foodhub.restaurants f
INNER JOIN quickbite.restaurants q
    ON q.name = f.name
ORDER BY rating_difference DESC;
```

**Findings:**

Five restaurants were identified on both platforms.

|Restaurant Name|FoodHub Rating|QuickBite Rating|Rating Difference|
|-|-:|-:|-:|
|Spice Route|4.2|4.0|0.2|
|Dragon Palace|3.9|4.1|0.2|
|The Jollof Kitchen|4.1|4.3|0.2|
|La Bella Italia|4.7|4.8|0.1|
|Sushi Sora|4.6|4.5|0.1|

**Average Absolute Rating Difference: 0.16 points**

Calculation:

`(0.2 + 0.2 + 0.2 + 0.1 + 0.1) / 5 = 0.16`

**Business Interpretation:**

The analysis identified small differences in the average ratings of the five restaurants appearing on both platforms.

The differences range from 0.1 to 0.2 points, with an average absolute difference of 0.16 points.

There is no consistent indication that one platform assigns higher ratings than the other:

* FoodHub has higher ratings for Spice Route and Sushi Sora.
* QuickBite has higher ratings for Dragon Palace, The Jollof Kitchen and La Bella Italia.

These discrepancies may reflect differences in customer preferences, the customer populations using each platform, rating volumes or the period over which ratings were collected.

However, the available data does not contain sufficient information to establish the actual cause of these differences.

**Recommendations:**

* Restaurant Partnerships should investigate the rating calculation methods used by both platforms.
* Customer rating volumes and review periods should be considered before consolidating restaurant ratings.
* A consistent rating methodology should be established before presenting unified ratings to customers following the acquisition.
* Restaurant matching should ideally include additional identifying information, such as location or address, to avoid incorrectly matching different restaurants with similar names.

\---

### Question 4: Combined Revenue – Eliminating Duplicate Orders

**Stakeholder:** Finance

**Objective:** Calculate the combined revenue generated by both platforms while avoiding double-counting of duplicate orders.

**Methodology:**

The UNION operator was used to combine the order records from both databases.

Unlike UNION ALL, which retains all records, UNION eliminates identical rows across the selected columns.

The combined result was then placed inside a subquery to calculate:

* Total number of unique order records.
* Total combined revenue, calculated as quantity multiplied by price.

**SQL Query:**

```sql
SELECT
    COUNT(*) AS total_orders,
    SUM(quantity * price) AS total_revenue
FROM (
    SELECT
        order_id,
        customer_id,
        restaurant_id,
        item_name,
        quantity,
        order_date,
        price
    FROM quickbite.orders

    UNION

    SELECT
        order_id,
        customer_id,
        restaurant_id,
        item_name,
        quantity,
        order_date,
        price
    FROM foodhub.orders
) AS orders_combined;
```

**Results:**

|Metric|Result|
|-|-:|
|Total Orders|34|
|Total Combined Revenue|$875.50|

**Business Interpretation:**

The combined order dataset returned 34 records using both UNION and UNION ALL. 
This indicates that there were no exact duplicate rows across the two platforms 
based on the selected columns.

Although UNION was used to account for potential duplicate records, no records 
were removed during the operation.

The combined revenue was calculated as $875.50 using SUM(quantity * price).

However, the absence of exact duplicate rows does not necessarily establish 
that there were no duplicate transactions. Two records could represent the 
same real-world transaction while having differences in one or more columns.

Therefore, the $875.50 represents the combined revenue from the 34 available 
order records, rather than a fully reconciled figure based on verified 
transaction-level deduplication.


**Important distinction:** UNION removes identical rows; it does not independently establish whether two records represent the same real-world transaction.

Consequently, the $875.50 figure should be treated as a preliminary deduplicated revenue estimate rather than a fully reconciled acquisition revenue figure.

**Recommendations:**

* Finance should establish a reliable cross-platform order-matching rule before finalising combined revenue.
* Where available, a shared transaction reference or payment identifier should be used to identify the same transaction across platforms.
* If no shared identifier exists, potential duplicates should be investigated using a combination of customer identity, restaurant, order details, timestamp and transaction amount.
* Revenue calculations should be reconciled against payment records before being used for acquisition valuation.

\---

## 5\. Key Assumptions and Limitations

The findings should be interpreted in light of the following assumptions:

|Area|Assumption / Limitation|
|-|-|
|Customer verification|A matching customer record indicates a valid database reference, not independently verified customer identity.|
|Customer matching|Customer names were used as the matching key. This may produce false matches or miss customers whose names are recorded differently.|
|Name normalization|The original matching queries used exact name comparisons. Case and whitespace normalization should be applied and results revalidated.|
|Restaurant matching|Restaurants were matched using exact names. Similar names may refer to different establishments.|
|Rating comparison|Only five matching restaurants were available. The analysis cannot establish the cause of rating differences or generalise the findings to all restaurants.|
|Duplicate orders|UNION removes identical records across selected columns. This does not guarantee that all duplicate transactions have been identified correctly.|
|Revenue calculation|The calculation assumes price represents the unit price and that quantity × price gives the order revenue.|
|Orphaned orders|The reported validation identified no orders without corresponding customer records.|
|Data source|The analysis uses a synthetic dataset and may not represent the complexity of actual commercial transaction systems.|

## 6\. Business Recommendations

Based on the findings, the following actions are recommended ahead of the acquisition:

|Stakeholder|Recommendation|
|-|-|
|Compliance|Retain the customer-reference validation as part of the acquisition audit. Investigate any unmatched orders identified during subsequent database checks.|
|Marketing|Prioritise cross-platform engagement campaigns for the eight exclusive customers while consolidating the five shared customer records to avoid duplicate communications.|
|Restaurant Partnerships|Investigate rating discrepancies and establish a consistent rating methodology before combining restaurant profiles.|
|Finance|Validate the duplicate-order identification rules and reconcile the $875.50 preliminary revenue figure against transaction records before using it for valuation.|

## 7\. Conclusion

This project demonstrates how SQL can be used to investigate data consistency and support business decisions during a proposed acquisition.

By combining customer records, validating order references, comparing restaurant ratings and consolidating transaction data, the analysis provides an initial picture of the relationship between FoodHub and QuickBite.

The findings reveal a shared customer base of five customers, eight platform-exclusive customers and an average absolute rating difference of 0.16 points across five shared restaurants.

The reported combined revenue is $875.50 across 34 order records. However, further transaction-level reconciliation is necessary to establish a reliable figure for financial due diligence.

Overall, the analysis highlights the importance of data integrity, appropriate matching keys and defensible deduplication rules when integrating databases from two independent business platforms.

## 8\. Tools and Technologies

* **MySQL:** Data retrieval, joining, filtering, aggregation and deduplication.
* **SQL concepts applied:** INNER JOIN, LEFT JOIN, UNION, DISTINCT, EXISTS, NOT EXISTS, subqueries, aggregate functions and string functions.

## 9\. Author

**Ejiro Suzzy Akpomedaye**

*Data Analytics Portfolio Project*

