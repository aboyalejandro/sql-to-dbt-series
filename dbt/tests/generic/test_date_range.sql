{% test date_range(model, column_name, min_date='2020-01-01', max_date='2030-12-31') %}

select *
from {{ model }}
where {{ column_name }} is not null
  and ({{ column_name }} < '{{ min_date }}'::date 
       or {{ column_name }} > '{{ max_date }}'::date)

{% endtest %}