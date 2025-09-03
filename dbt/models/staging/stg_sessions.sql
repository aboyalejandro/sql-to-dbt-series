select
    session_id,
    visitor_id,
    campaign_id,
    ad_id,
    source_medium,
    landing_page,
    session_start,
    session_end,
    pages_viewed,
    bounce,
    time_on_site_seconds,
    page_path_sequence,
    events_count,
    conversion_flag,
    device_type,
    browser
from {{ source('synthetic_data', 'sessions') }}