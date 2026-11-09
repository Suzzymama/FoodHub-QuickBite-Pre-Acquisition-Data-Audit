--  Verified Foodhub Customers
SELECT 
    o.order_id,
    c.name AS customer_name,
    o.item_name,
    o.price
FROM foodhub.orders o
-- Using INNER JOIN because we only want to return orders that have a corresponding customer record.
-- A LEFT JOIN would include orphan orders with NULL customer names, which we want to exclude since we only need records with matching customers.
INNER JOIN foodhub.customers c 
	ON o.customer_id = c.customer_id
;
-- Verified QuickBite Customers
SELECT 
    o.order_id,
    c.name AS customer_name,
    o.item_name,
    o.price
FROM quickbite.orders o
INNER JOIN quickbite.customers c 
	ON o.customer_id = c.customer_id
;