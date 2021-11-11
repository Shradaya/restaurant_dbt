SELECT *, {{ get_age_bucket('dateadded') }} AS restaurant_age_group
FROM 
{{ ref('restaurant_division') }}