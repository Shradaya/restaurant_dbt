SELECT  name , division, state, city, restaurant_age_group
FROM 
{{ ref('restaurant_division_age') }}
GROUP BY division, state, city, name, restaurant_age_group
