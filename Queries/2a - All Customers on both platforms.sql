SELECT
	name AS 'All Customers'
FROM quickbite.customers
UNION
SELECT
	name AS 'All Customers'
FROM foodhub.customers
ORDER BY `All Customers`;

