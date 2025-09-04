{% macro classify_performance_tier(
    column_name,
    tier_name,
    high_threshold=null,
    medium_threshold=null,
    high_label='high',
    medium_label='medium', 
    low_label='low',
    direction='higher_better'
) %}
    {%- if direction == 'higher_better' -%}
        case 
            when {{ column_name }} > {{ high_threshold }} then '{{ high_label }}'
            when {{ column_name }} > {{ medium_threshold }} then '{{ medium_label }}'
            else '{{ low_label }}'
        end as {{ tier_name }}
    {%- elif direction == 'lower_better' -%}
        case 
            when {{ column_name }} < {{ medium_threshold }} then '{{ high_label }}'
            when {{ column_name }} < {{ high_threshold }} then '{{ medium_label }}'
            else '{{ low_label }}'
        end as {{ tier_name }}
    {%- endif -%}
{% endmacro %}

{% macro classify_vs_target(
    actual_column,
    target_column,
    comparison_name,
    under_label='under_target',
    on_label='on_target',
    over_label='over_target'
) %}
    case 
        when {{ actual_column }} < {{ target_column }} then '{{ under_label }}'
        when {{ actual_column }} = {{ target_column }} then '{{ on_label }}'  
        else '{{ over_label }}'
    end as {{ comparison_name }}
{% endmacro %}

{% macro safe_divide(numerator, denominator, default_value='null') %}
    case 
        when {{ denominator }} > 0 then {{ numerator }} / {{ denominator }}
        else {{ default_value }} 
    end
{% endmacro %}

{% macro calculate_percentage_share(part_column, total_column, percentage_name) %}
    {{ safe_divide(part_column + ' * 100', total_column, '0') }} as {{ percentage_name }}
{% endmacro %}