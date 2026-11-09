SELECT
    q.name AS customer_name
FROM quickbite.customers q
WHERE NOT EXISTS (
    SELECT 1
    FROM foodhub.customers f
    WHERE LOWER(TRIM(q.name)) = LOWER(TRIM(f.name))
)
ORDER BY customer_name;
