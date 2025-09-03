select 
    -- event identifiers
    journey_events.event_id,
    journey_events.visitor_id,
    journey_events.session_id,
    journey_events.campaign_id,
    journey_events.ad_id,
    
    -- event details
    journey_events.timestamp::timestamp as event_timestamp,
    journey_events.event_type,
    journey_events.channel as event_channel,
    journey_events.page_url,
    journey_events.event_value,
    journey_events.touchpoint_order,
    journey_events.platform as event_platform,
    journey_events.metadata as event_metadata,
    
    -- session context
    sessions.session_start::timestamp as session_start,
    sessions.source_medium,
    sessions.landing_page,
    sessions.device_type,
    sessions.browser,
    sessions.conversion_flag::boolean as session_has_conversion,
    
    -- campaign context
    campaigns.campaign_name,
    campaigns.channel as campaign_channel,
    campaigns.objective as campaign_objective,
    campaigns.status as campaign_status,
    
    -- ad context
    ads.ad_name,
    ads.creative_type,
    ads.platform as ad_platform,
    ads.placement,
    ads.ad_status,
    
    -- business logic flags
    case 
        when journey_events.event_type in ('purchase', 'conversion', 'lead') then true 
        else false 
    end as is_conversion_event,
    
    case 
        when journey_events.touchpoint_order = 1 then true 
        else false 
    end as is_first_touchpoint,
    
    case 
        when journey_events.event_type in ('page_view', 'click') then 'engagement'
        when journey_events.event_type in ('purchase', 'conversion', 'lead') then 'conversion'
        when journey_events.event_type in ('signup', 'subscribe') then 'acquisition'
        else 'other'
    end as event_category,
    
    case 
        when journey_events.channel = campaigns.channel then true 
        else false 
    end as channel_alignment,
    
    current_timestamp as date_transformed
    
from {{ ref('stg_journey_events') }} as journey_events
left join {{ ref('stg_sessions') }} as sessions 
    on journey_events.session_id = sessions.session_id
left join {{ ref('stg_campaigns') }} as campaigns 
    on journey_events.campaign_id = campaigns.campaign_id
left join {{ ref('stg_ads') }} as ads 
    on journey_events.ad_id = ads.ad_id