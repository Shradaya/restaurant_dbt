 ## The file structure of this repo:
```
data/             # Folder containing the datasets in different formats.
  *.csv
macros/          # Folder containing different DDL sql queries.
  *.sql    
models/
  *.sql
  *.yml
tests/
  *.sql
.yml
```

### Data used

`'type_code.csv'` is a CSV file containing the various divisions with regards to the state.

`'DataFiniti_Fast_food_restaurants.csv'` File containing information of restaurants. It is stored in data base through ETL pipeline.


### Macros

 * `calc_age.sql`

    It describes a function used to calculate age of the restaurant after its registration.

    ```
    {% macro calc_age(dateadded) %}
        (AGE(now()::date, {{ dateadded }}::date))
    {% endmacro %}
    ```

### Models

* `age_view.sql`

Creates a view with restaurant name and age.

```
SELECT DISTINCT ri.name, 
{{ calc_age('dateadded') }} FROM restaurant_info ri 
```

* `restaurant_division_info_view`

Provides overall info of the hotel with its location division.

```
SELECT ri.client_id, ri.dateadded, ri.dateupdated, ri.address, ri.categories, ri.city, 
ri.name, ri.postalcode, ri.province, tc.state, tc.division_code, tc.division, tc.country
FROM restaurant_info ri
LEFT JOIN 
type_code tc ON ri.province = tc.state_code AND ri.country = tc.country_code
```

* `schema.yml`

Provides validation cases for data.

```
version: 2

models:
  - name: restaurant_division_info_view
    columns:
      - name: client_id
        tests:
          - not_null
      - name: name
        tests:
          - not_null

    
  - name: restaurant_info
    tests:
      - dbt_utils.equal_rowcount:
          compare_model: ref('restaurant_info_raw')

  - name : age_of_restro_after_registration
    columns:
    - name : age
      tests:
        - not_null
```

### Tests

* `date_added_updated_test.sql` 

Tests whether the added date is smaller than the updated date or not.

```
SELECT * FROM restaurant_info ri  WHERE dateadded > dateupdated
```
