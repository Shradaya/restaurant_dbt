{% macro get_age_bucket(dateadded) %}
    CASE
      WHEN DATE_PART('year', (AGE(now()::date, {{ dateadded }}::date))) BETWEEN 1 AND 3 THEN 'New'
      WHEN DATE_PART('year', (AGE(now()::date, {{ dateadded }}::date))) BETWEEN 4 AND 6 THEN 'Old'
      WHEN DATE_PART('year', (AGE(now()::date, {{ dateadded }}::date))) BETWEEN 7 AND 10 THEN 'Older'
      WHEN DATE_PART('year', (AGE(now()::date, {{ dateadded }}::date))) BETWEEN 11 AND 13 THEN 'Oldest'
    END
{% endmacro %}