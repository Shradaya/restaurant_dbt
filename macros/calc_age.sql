{% macro calc_age(dateadded) %}
    (AGE(now()::date, {{ dateadded }}::date))
{% endmacro %}