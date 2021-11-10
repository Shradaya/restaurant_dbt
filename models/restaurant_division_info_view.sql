SELECT ri.client_id, ri.dateadded, ri.dateupdated, ri.address, ri.categories, ri.city, 
ri.name, ri.postalcode, ri.province, tc.state, tc.division_code, tc.division, tc.country
FROM restaurant_info ri
LEFT JOIN 
type_code tc ON ri.province = tc.state_code AND ri.country = tc.country_code