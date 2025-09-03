{{ config(materialized='view') }}

select 
    visitor_id,
    first_value(campaign_id) over (partition by visitor_id order by event_timestamp) as first_campaign_id,
    first_value(event_channel) over (partition by visitor_id order by event_timestamp) as first_event_channel,
    first_value(campaign_name) over (partition by visitor_id order by event_timestamp) as first_campaign_name,
    first_value(ad_name) over (partition by visitor_id order by event_timestamp) as first_ad_name,
    first_value(ad_id) over (partition by visitor_id order by event_timestamp) as first_ad_id,
    first_value(event_timestamp) over (partition by visitor_id order by event_timestamp) as first_event_timestamp
from {{ ref('int_journey_events') }}
qualify row_number() over (partition by visitor_id order by event_timestamp) = 1