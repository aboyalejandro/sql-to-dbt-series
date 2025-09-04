{% test currency_precision(model, column_name, max_decimal_places=2) %}

select *
from {{ model }}
where {{ column_name }} is not null
  and ({{ column_name }} * power(10, {{ max_decimal_places }})) != floor({{ column_name }} * power(10, {{ max_decimal_places }}))

{% endtest %}