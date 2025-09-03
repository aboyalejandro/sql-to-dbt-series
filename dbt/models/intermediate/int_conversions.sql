select 
    -- conversion identifiers
    conversions.conversion_id,
    conversions.session_id,
    conversions.visitor_id,
    conversions.order_id,
    conversions.campaign_id,
    conversions.ad_id,
    
    -- conversion details
    conversions.conversion_time::timestamp as conversion_time,
    conversions.conversion_type,
    conversions.conversion_value,
    conversions.revenue,
    conversions.attribution_model,
    conversions.attributed_spend,
    conversions.cpa,
    conversions.conversion_channel,
    conversions.is_revenue_confirmed::boolean as is_revenue_confirmed,
    
    -- session context
    sessions.source_medium,
    sessions.landing_page,
    sessions.device_type,
    sessions.browser,
    sessions.pages_viewed,
    sessions.time_on_site_seconds,
    
    -- campaign context
    campaigns.campaign_name,
    campaigns.channel as campaign_channel,
    campaigns.objective as campaign_objective,
    campaigns.campaign_manager,
    
    -- ad context
    ads.ad_name,
    ads.creative_type,
    ads.platform as ad_platform,
    ads.placement,
    ads.targeting,
    
    -- business logic flags
    case 
        when conversions.conversion_type = 'purchase' then true 
        else false 
    end as is_purchase,
    
    case 
        when conversions.revenue > 0 then true 
        else false 
    end as has_revenue,
    
    case 
        when conversions.attributed_spend > 0 then conversions.revenue / conversions.attributed_spend 
        else null 
    end as roas,
    
    current_timestamp as date_transformed
    
from {{ ref('stg_conversions') }} as conversions
left join {{ ref('stg_sessions') }} as sessions 
    on conversions.session_id = sessions.session_id
left join {{ ref('stg_campaigns') }} as campaigns 
    on conversions.campaign_id = campaigns.campaign_id  
left join {{ ref('stg_ads') }} as ads 
    on conversions.ad_id = ads.ad_id