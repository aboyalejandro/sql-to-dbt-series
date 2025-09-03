select 
    -- session identifiers
    sessions.session_id,
    sessions.visitor_id,
    sessions.campaign_id,
    sessions.ad_id,
    
    -- session timing
    sessions.session_start::timestamp as session_start,
    sessions.session_end::timestamp as session_end,
    sessions.time_on_site_seconds,
    
    -- session behavior
    sessions.source_medium,
    sessions.landing_page,
    sessions.pages_viewed,
    sessions.bounce::boolean as is_bounce,
    sessions.events_count as session_events_count,
    sessions.conversion_flag::boolean as has_conversion,
    sessions.device_type,
    sessions.browser,
    
    -- campaign context
    campaigns.campaign_name,
    campaigns.channel as campaign_channel,
    campaigns.budget as campaign_budget,
    campaigns.status as campaign_status,
    campaigns.objective as campaign_objective,
    campaigns.campaign_manager,
    
    -- ad context  
    ads.ad_name,
    ads.creative_type,
    ads.platform as ad_platform,
    ads.placement,
    ads.impressions as ad_impressions,
    ads.clicks as ad_clicks,
    ads.ctr as ad_ctr,
    ads.spend as ad_spend,
    ads.avg_cpc,
    ads.targeting,
    
    -- business logic flags
    case 
        when sessions.pages_viewed = 1 then true 
        else false 
    end as is_single_page_session,
    
    case 
        when sessions.time_on_site_seconds > 180 then true 
        else false 
    end as is_engaged_session,
    
    case 
        when sessions.source_medium in ('organic', 'referral') then 'organic'
        when sessions.source_medium in ('cpc', 'paid') then 'paid'
        when sessions.source_medium = 'email' then 'email'
        when sessions.source_medium = 'social' then 'social'
        else 'other'
    end as traffic_category,
    
    current_timestamp as date_transformed
    
from {{ ref('stg_sessions') }} as sessions
left join {{ ref('stg_campaigns') }} as campaigns 
    on sessions.campaign_id = campaigns.campaign_id
left join {{ ref('stg_ads') }} as ads 
    on sessions.ad_id = ads.ad_id