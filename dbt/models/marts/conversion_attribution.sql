select 
    -- conversion identifiers
    conversions.conversion_id,
    conversions.visitor_id,
    conversions.session_id,
    conversions.order_id,
    
    -- conversion details
    conversions.conversion_time,
    conversions.conversion_type,
    conversions.conversion_value,
    conversions.revenue,
    conversions.is_purchase,
    conversions.has_revenue,
    conversions.roas,
    
    -- session attribution
    conversions.source_medium as conversion_source_medium,
    conversions.landing_page as conversion_landing_page,
    conversions.device_type as conversion_device_type,
    
    -- campaign attribution
    conversions.campaign_name as conversion_campaign,
    conversions.campaign_channel as conversion_channel,
    conversions.campaign_objective as conversion_objective,
    
    -- ad attribution
    conversions.ad_name as conversion_ad,
    conversions.creative_type as conversion_creative_type,
    conversions.ad_platform as conversion_platform,
    
    -- journey context - first touchpoint
    first_touchpoint.first_event_channel as first_touch_channel,
    first_touchpoint.first_campaign_name as first_touch_campaign,
    first_touchpoint.first_ad_name as first_touch_ad,
    first_touchpoint.first_event_timestamp as first_touch_time,
    
    -- journey context - last touchpoint  
    last_touchpoint.last_event_channel as last_touch_channel,
    last_touchpoint.last_campaign_name as last_touch_campaign,
    last_touchpoint.last_ad_name as last_touch_ad,
    last_touchpoint.last_event_timestamp as last_touch_time,
    
    -- journey metrics
    journey_stats.total_touchpoints,
    journey_stats.total_sessions,
    journey_stats.journey_length_days,
    
    -- attribution model flags
    case 
        when first_touchpoint.first_campaign_id = conversions.campaign_id then true 
        else false 
    end as is_first_touch_conversion,
    
    case 
        when last_touchpoint.last_campaign_id = conversions.campaign_id then true 
        else false 
    end as is_last_touch_conversion,
    
    current_timestamp as date_transformed
    
from {{ ref('int_conversions') }} as conversions
left join {{ ref('int_first_touchpoints') }} as first_touchpoint
    on conversions.visitor_id = first_touchpoint.visitor_id
left join {{ ref('int_last_touchpoints') }} as last_touchpoint 
    on conversions.visitor_id = last_touchpoint.visitor_id 
    and conversions.conversion_time = last_touchpoint.conversion_time
left join {{ ref('int_journey_stats') }} as journey_stats 
    on conversions.visitor_id = journey_stats.visitor_id 
    and conversions.conversion_time = journey_stats.conversion_time