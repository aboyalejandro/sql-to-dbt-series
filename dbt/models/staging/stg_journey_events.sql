select
    event_id,
    visitor_id,
    timestamp,
    event_type,
    channel,
    campaign_id,
    ad_id,
    session_id,
    page_url,
    event_value,
    touchpoint_order,
    metadata,
    platform
from {{ source('synthetic_data', 'journey_events') }}