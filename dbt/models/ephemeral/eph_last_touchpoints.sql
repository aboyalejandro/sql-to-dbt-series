{{ config(materialized='ephemeral') }}

with journey_with_conversions as (
    select 
        journey_events.*,
        conv.conversion_time
    from {{ ref('int_journey_events') }} as journey_events
    inner join {{ ref('int_conversions') }} as conv 
        on journey_events.visitor_id = conv.visitor_id 
        and journey_events.event_timestamp <= conv.conversion_time
)

{{ get_touchpoint_attribution(
    source_table='journey_with_conversions',
    attribution_type='last',
    additional_partitions=['conversion_time']
) }}