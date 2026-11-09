SELECT
	name AS 'Quickbite Exclusive Customers'
FROM quickbite.customers q
WHERE NOT EXISTS (
	SELECT *
	FROM foodhub.customers f
    WHERE f.name = q.name)
ORDER BY `Quickbite Exclusive Customers`
