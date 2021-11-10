SELECT DISTINCT ri.name, 
{{ calc_age('dateadded') }} FROM restaurant_info ri 