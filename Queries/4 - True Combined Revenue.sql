
SELECT
	COUNT(*) AS total_orders,
    SUM(price*quantity) AS total_revenue
FROM (
		SELECT *
		FROM quickbite.orders
		UNION -- Eliminates Duplicate Records
		SELECT *
		FROM foodhub.orders
	  ) as orders_combined