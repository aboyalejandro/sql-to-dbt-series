select
    conversion_id,
    session_id,
    visitor_id,
    campaign_id,
    ad_id,
    conversion_time,
    conversion_type,
    conversion_value,
    revenue,
    attribution_model,
    attributed_spend,
    cpa,
    conversion_channel,
    is_revenue_confirmed,
    order_id
from {{ source('synthetic_data', 'conversions') }}