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

    -- ********************* USED FOR INITIAL INPUT ********************* --
    -- WITH cte as(
    -- SELECT ROW_NUMBER() OVER(ORDER BY client_id), * FROM dev.restaurant_division_age rda 
    -- )
    -- (SELECT * FROM cte WHERE row_number IN(
    -- SELECT min(row_number) as id FROM cte GROUP BY client_id))

    
    -- ********************* USED FOR INPUTS SECONDARY INPUTS *********************  --
    -- WITH cte as(
    -- SELECT ROW_NUMBER() OVER(ORDER BY client_id), * FROM dev.restaurant_division_age rda 
    -- )
    -- SELECT * FROM cte WHERE row_number NOT IN(
    -- SELECT min(row_number) as id FROM cte GROUP BY client_id)

    
    -- ********************* USED FOR FURTHER NEW INPUTS *********************--
    -- select * from {{ source('dev', 'restaurant_division_age') }}


{% endsnapshot %}