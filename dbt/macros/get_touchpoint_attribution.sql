{% macro get_touchpoint_attribution(
    source_table,
    partition_column='visitor_id',
    order_column='event_timestamp',
    attribution_type='first',
    additional_partitions=[]
) %}
    {%- set direction = 'asc' if attribution_type == 'first' else 'desc' -%}
    {%- set partition_cols = [partition_column] + additional_partitions -%}
    {%- set partition_by = partition_cols | join(', ') -%}
    
select 
    {{ partition_column }},
    {% if additional_partitions %}
    {%- for col in additional_partitions -%}
    {{ col }},
    {% endfor -%}
    {% endif %}
    first_value(campaign_id) over (
        partition by {{ partition_by }}
        order by {{ order_column }} {{ direction }}
    ) as {{ attribution_type }}_campaign_id,
    
    first_value(event_channel) over (
        partition by {{ partition_by }}
        order by {{ order_column }} {{ direction }}
    ) as {{ attribution_type }}_event_channel,
    
    first_value(campaign_name) over (
        partition by {{ partition_by }}
        order by {{ order_column }} {{ direction }}
    ) as {{ attribution_type }}_campaign_name,
    
    first_value(ad_name) over (
        partition by {{ partition_by }}
        order by {{ order_column }} {{ direction }}
    ) as {{ attribution_type }}_ad_name,
    
    first_value({{ order_column }}) over (
        partition by {{ partition_by }}
        order by {{ order_column }} {{ direction }}
    ) as {{ attribution_type }}_event_timestamp
    
from {{ source_table }}
qualify row_number() over (
    partition by {{ partition_by }}
    order by {{ order_column }} {{ direction }}
) = 1

{% endmacro %}