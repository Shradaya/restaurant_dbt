SELECT * 
FROM dev.restaurant_division_age rda 
WHERE 
latitude < -91 OR 
latitude > 90 OR 
longitude < -180 OR 
longitude > 180