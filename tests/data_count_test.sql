SELECT * FROM restaurant_info ri WHERE 
ri.client_id NOT in 
(SELECT client_id FROM restaurant_division_info_view)