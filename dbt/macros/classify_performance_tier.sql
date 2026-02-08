{% macro classify_performance_tier(column_name, tier_name, high_threshold, medium_threshold) %}
    case
        when {{ column_name }} > {{ high_threshold }} then 'high'
        when {{ column_name }} > {{ medium_threshold }} then 'medium'
        else 'low'
    end as {{ tier_name }}
{% endmacro %}

{% macro classify_vs_target(actual_column, target_column, comparison_name) %}
    case
        when {{ actual_column }} < {{ target_column }} then 'under_target'
        when {{ actual_column }} > {{ target_column }} then 'over_target'
        else 'on_target'
    end as {{ comparison_name }}
{% endmacro %}

{% macro safe_divide(numerator, denominator) %}
    case
        when {{ denominator }} > 0 then {{ numerator }} / {{ denominator }}
        else null
    end
{% endmacro %}

{% macro calculate_percentage_share(part_column, total_column, percentage_name) %}
    {{ safe_divide(part_column ~ ' * 100', total_column) }} as {{ percentage_name }}
{% endmacro %}
