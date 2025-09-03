select 
    -- campaign identifiers
    campaign_ads.campaign_id,
    campaign_ads.campaign_name,
    campaign_ads.campaign_channel,
    campaign_ads.campaign_objective,
    campaign_ads.campaign_manager,
    campaign_ads.campaign_status,
    
    -- campaign metadata
    campaign_ads.campaign_start_date,
    campaign_ads.campaign_end_date,
    campaign_ads.campaign_budget,
    campaign_ads.campaign_target_cpa,
    
    -- aggregated ad metrics
    count(distinct campaign_ads.ad_id) as total_ads,
    sum(campaign_ads.impressions) as total_impressions,
    sum(campaign_ads.clicks) as total_clicks,
    avg(campaign_ads.ctr) as avg_ctr,
    sum(campaign_ads.ad_spend) as total_ad_spend,
    avg(campaign_ads.avg_cpc) as avg_cpc,
    
    -- session metrics
    count(distinct visitor_sessions.session_id) as total_sessions,
    count(distinct visitor_sessions.visitor_id) as total_visitors,
    sum(visitor_sessions.pages_viewed) as total_page_views,
    sum(visitor_sessions.session_events_count) as total_events,
    avg(visitor_sessions.time_on_site_seconds) as avg_time_on_site,
    
    -- engagement metrics
    sum(case when visitor_sessions.is_engaged_session then 1 else 0 end) as engaged_sessions,
    sum(case when visitor_sessions.is_bounce then 1 else 0 end) as bounced_sessions,
    sum(case when visitor_sessions.has_conversion then 1 else 0 end) as converting_sessions,
    
    -- conversion metrics
    count(distinct conversions.conversion_id) as total_conversions,
    sum(conversions.conversion_value) as total_conversion_value,
    sum(conversions.revenue) as total_revenue,
    sum(conversions.attributed_spend) as total_attributed_spend,
    
    -- calculated metrics
    case 
        when sum(campaign_ads.ad_spend) > 0 then sum(conversions.revenue) / sum(campaign_ads.ad_spend)
        else null 
    end as roas,
    
    case 
        when count(distinct visitor_sessions.session_id) > 0 then 
            (count(distinct conversions.conversion_id) * 100.0) / count(distinct visitor_sessions.session_id)
        else 0 
    end as conversion_rate_pct,
    
    case 
        when count(distinct conversions.conversion_id) > 0 then sum(campaign_ads.ad_spend) / count(distinct conversions.conversion_id)
        else null 
    end as actual_cpa,
    
    case 
        when count(distinct visitor_sessions.visitor_id) > 0 then sum(conversions.revenue) / count(distinct visitor_sessions.visitor_id)
        else 0 
    end as revenue_per_visitor,
    
    current_timestamp as date_transformed
    
from {{ ref('int_campaign_ads') }} as campaign_ads
left join {{ ref('int_visitor_sessions') }} as visitor_sessions 
    on campaign_ads.campaign_id = visitor_sessions.campaign_id
left join {{ ref('int_conversions') }} as conversions 
    on campaign_ads.campaign_id = conversions.campaign_id
group by 
    campaign_ads.campaign_id,
    campaign_ads.campaign_name,
    campaign_ads.campaign_channel,
    campaign_ads.campaign_objective,
    campaign_ads.campaign_manager,
    campaign_ads.campaign_status,
    campaign_ads.campaign_start_date,
    campaign_ads.campaign_end_date,
    campaign_ads.campaign_budget,
    campaign_ads.campaign_target_cpa