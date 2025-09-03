{{ config(materialized='ephemeral') }}

select 
    journey_events.visitor_id,
    conv.conversion_time,
    first_value(journey_events.campaign_id) over (
        partition by journey_events.visitor_id, conv.conversion_time 
        order by journey_events.event_timestamp desc
    ) as last_campaign_id,
    first_value(journey_events.event_channel) over (
        partition by journey_events.visitor_id, conv.conversion_time 
        order by journey_events.event_timestamp desc
    ) as last_event_channel,
    first_value(journey_events.campaign_name) over (
        partition by journey_events.visitor_id, conv.conversion_time 
        order by journey_events.event_timestamp desc
    ) as last_campaign_name,
    first_value(journey_events.ad_name) over (
        partition by journey_events.visitor_id, conv.conversion_time 
        order by journey_events.event_timestamp desc
    ) as last_ad_name,
    first_value(journey_events.event_timestamp) over (
        partition by journey_events.visitor_id, conv.conversion_time 
        order by journey_events.event_timestamp desc
    ) as last_event_timestamp
from {{ ref('int_journey_events') }} as journey_events
inner join {{ ref('int_conversions') }} as conv 
    on journey_events.visitor_id = conv.visitor_id 
    and journey_events.event_timestamp <= conv.conversion_time
qualify row_number() over (
    partition by journey_events.visitor_id, conv.conversion_time 
    order by journey_events.event_timestamp desc
) = 1