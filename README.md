 ## The file structure of this repo:
```
data/             
  *.csv
macros/         
  *.sql    
models/
  dbt_table/
    *.sql
  dbt_view/
    *.sql
  *.yml
snapshots/
  *.sql
tests/
  *.sql
.yml
```

### Data used

`'type_code.csv'` is a CSV file containing the various divisions with regards to the state.

`'DataFiniti_Fast_food_restaurants.csv'` File containing information of restaurants. It is stored in data base through ETL pipeline.


### Macros
While creating schema through DBT, the schema name that we provide is appended to {{default_name}}_. In order to maintain the schema name as to an exact of what we want this macros has been defined. This macros overwrites the default generate_schema_name macros in DBT.

* `generate_schema_name.sql`


```
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
```

* `get_age_bucket.sql`

It is a function that takes date as a argument and returnes the corresponding category of age.

```
{% macro get_age_bucket(dateadded) %}
    CASE
      WHEN DATE_PART('year', (AGE(now()::date, {{ dateadded }}::date))) BETWEEN 1 AND 3 THEN 'New'
      WHEN DATE_PART('year', (AGE(now()::date, {{ dateadded }}::date))) BETWEEN 4 AND 6 THEN 'Old'
      WHEN DATE_PART('year', (AGE(now()::date, {{ dateadded }}::date))) BETWEEN 7 AND 10 THEN 'Older'
      WHEN DATE_PART('year', (AGE(now()::date, {{ dateadded }}::date))) BETWEEN 11 AND 13 THEN 'Oldest'
    END
{% endmacro %}
```

### Models

#### dbt_table
* `restaurant_division.sql`

It is the preliminary table obtained from the data obtained from ETL and the seed.

```
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
```

* `restaurant_division_age.sql`

This table uses the priliminary table and get_age_bucket macro to create a new table which includes the age category.

```
SELECT *, 
{{ get_age_bucket('dateadded') }} AS restaurant_age_group
FROM 
{{ ref('restaurant_division') }}
```

#### dbt_view

* `group_by_state_view.sql` 

This defines the view that uses grouping to be shown to the users.

```
SELECT  name , division, state, city, restaurant_age_group
FROM 
{{ ref('restaurant_division_age') }}
GROUP BY division, state, city, name, restaurant_age_group
```

* `schema.yml`

Provides validation cases for data.

```
version: 2

models:
  - name: restaurant_division
    columns:
      - name: client_id
        tests:
          - not_null
      - name: name
        tests:
          - not_null
    tests:
      - dbt_utils.equal_rowcount:
          compare_model: dev.restaurant_division_age
```

### Snapshots

* `restaurant_division_snapshot.sql`

It is used to create a type-2 SCD table for restaurant_division_age table.

```
{% snapshot restaurant_division_snapshot %}

    {{
        config(
          target_schema = 'snapshots',
          strategy = 'check',
          unique_key = 'client_id',
          check_cols = ['categories'],
          invalidate_hard_deletes = True,
        )
    }}
    -- ********************* USED FOR INITIAL INPUT FOR THIS DATASET ********************* --
    -- WITH cte as(
    -- SELECT ROW_NUMBER() OVER(ORDER BY client_id), * FROM dev.restaurant_division_age rda 
    -- )
    -- (SELECT * FROM cte WHERE row_number IN(
    -- SELECT min(row_number) as id FROM cte GROUP BY client_id))

    
    -- ***************** USED FOR INPUTS SECONDARY INPUTS FOR THIS DATASET **************** --
    -- WITH cte as(
    -- SELECT ROW_NUMBER() OVER(ORDER BY client_id), * FROM dev.restaurant_division_age rda 
    -- )
    -- SELECT * FROM cte WHERE row_number NOT IN(
    -- SELECT min(row_number) as id FROM cte GROUP BY client_id)

    
    -- ********************* USED FOR FURTHER NEW INPUTS *********************--
    -- select * from {{ source('dev', 'restaurant_division_age') }}
{% endsnapshot %}
```

### Tests

* `date_added_updated_test.sql` 

Tests whether the added date is smaller than the updated date or not.

```
SELECT * FROM restaurant_info ri  WHERE dateadded > dateupdated
```

