{% test uuid_format(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} is not null
  and not regexp_matches({{ column_name }}, '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')

{% endtest %}