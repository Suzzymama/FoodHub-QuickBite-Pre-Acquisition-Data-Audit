
SELECT 
	f.name AS 'Restaurant Name',
    f.avg_rating AS 'Foodhub Rating',
    q.avg_rating AS 'Quickbite Rating',
    ABS(f.avg_rating - q.avg_rating) AS 'Rating Difference'
FROM foodhub.restaurants f
-- Join on restaurant name because restaurant_id values are assigned independently in each platform's database. The same
-- restaurant may have different IDs in FoodHub and QuickBite.
-- The restaurant name is used to identify matching restaurants across both platforms.
INNER JOIN quickbite.restaurants q
	ON q.name = f.name
ORDER BY `Rating Difference` DESC