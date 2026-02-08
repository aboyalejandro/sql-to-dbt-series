{% macro get_touchpoint_attribution(source_table, attribution_type='first', additional_partitions=[]) %}

{%- set order_direction = 'asc' if attribution_type == 'first' else 'desc' -%}
{%- set partition_cols = ['visitor_id'] + additional_partitions -%}

select distinct
    visitor_id,
    {% for col in additional_partitions %}
    {{ col }},
    {% endfor %}
    first_value(campaign_id) over (w) as {{ attribution_type }}_campaign_id,
    first_value(event_channel) over (w) as {{ attribution_type }}_event_channel,
    first_value(campaign_name) over (w) as {{ attribution_type }}_campaign_name,
    first_value(ad_name) over (w) as {{ attribution_type }}_ad_name,
    first_value(event_timestamp) over (w) as {{ attribution_type }}_event_timestamp
from {{ source_table }}
window w as (
    partition by {{ partition_cols | join(', ') }}
    order by event_timestamp {{ order_direction }}
)
qualify row_number() over (w) = 1

{% endmacro %}
