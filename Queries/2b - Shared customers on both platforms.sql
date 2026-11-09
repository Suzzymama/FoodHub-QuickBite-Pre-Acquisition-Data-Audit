SELECT DISTINCT
	name AS 'Shared Customers'
FROM quickbite.customers q
WHERE EXISTS (
	SELECT 1
	FROM foodhub.customers f
    WHERE q.name = f.name
        )
ORDER BY `Shared Customers`
