SELECT 
ri.client_id, 
ri.dateadded, 
ri.dateupdated, 
ri.address, 
ri.categories, 
ri.city, 
ri.name, 
ri.postalcode, 
ri.latitude,
ri.longitude, 
ri.province,
tc.state, 
tc.division_code, 
tc.division, 
tc.country
FROM public.restaurant_info ri
LEFT JOIN 
public.type_code tc ON ri.province = tc.state_code AND ri.country = tc.country_code



 