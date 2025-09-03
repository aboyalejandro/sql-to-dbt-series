select 
    -- visitor identifiers
    visitor_sessions.visitor_id,
    
    -- visitor journey overview
    count(distinct visitor_sessions.session_id) as total_sessions,
    count(distinct visitor_sessions.campaign_id) as campaigns_touched,
    count(distinct visitor_sessions.ad_id) as ads_touched,
    count(distinct journey_events.event_id) as total_events,
    
    -- session aggregations
    sum(visitor_sessions.pages_viewed) as total_page_views,
    sum(visitor_sessions.session_events_count) as total_session_events,
    avg(visitor_sessions.time_on_site_seconds) as avg_time_on_site,
    sum(visitor_sessions.time_on_site_seconds) as total_time_on_site,
    
    -- engagement metrics
    sum(case when visitor_sessions.is_engaged_session then 1 else 0 end) as engaged_sessions,
    sum(case when visitor_sessions.is_bounce then 1 else 0 end) as bounced_sessions,
    sum(case when visitor_sessions.is_single_page_session then 1 else 0 end) as single_page_sessions,
    
    -- conversion metrics
    sum(case when visitor_sessions.has_conversion then 1 else 0 end) as converting_sessions,
    count(distinct conversions.conversion_id) as total_conversions,
    sum(conversions.conversion_value) as total_conversion_value,
    sum(conversions.revenue) as total_revenue,
    
    -- journey timing
    min(visitor_sessions.session_start) as first_session_time,
    max(visitor_sessions.session_start) as last_session_time,
    date_diff('day', min(visitor_sessions.session_start), max(visitor_sessions.session_start)) as journey_span_days,
    
    -- traffic sources
    array_agg(distinct visitor_sessions.source_medium order by visitor_sessions.source_medium) as all_source_mediums,
    array_agg(distinct visitor_sessions.traffic_category order by visitor_sessions.traffic_category) as all_traffic_categories,
    
    -- simplified attribution (using min/max instead of window functions)
    min(visitor_sessions.source_medium) as first_source_medium,
    max(visitor_sessions.source_medium) as last_source_medium,
    
    -- device and browser
    array_agg(distinct visitor_sessions.device_type order by visitor_sessions.device_type) as devices_used,
    array_agg(distinct visitor_sessions.browser order by visitor_sessions.browser) as browsers_used,
    
    -- visitor segments
    case 
        when count(distinct visitor_sessions.session_id) = 1 then 'single_session'
        when count(distinct visitor_sessions.session_id) between 2 and 5 then 'low_frequency'
        when count(distinct visitor_sessions.session_id) between 6 and 15 then 'medium_frequency'
        else 'high_frequency'
    end as visitor_frequency_segment,
    
    case 
        when sum(conversions.revenue) = 0 then 'non_converter'
        when sum(conversions.revenue) between 0.01 and 100 then 'low_value'
        when sum(conversions.revenue) between 100.01 and 500 then 'medium_value'
        else 'high_value'
    end as visitor_value_segment,
    
    case 
        when avg(visitor_sessions.time_on_site_seconds) < 30 then 'low_engagement'
        when avg(visitor_sessions.time_on_site_seconds) between 30 and 180 then 'medium_engagement'
        else 'high_engagement'
    end as visitor_engagement_segment,
    
    -- calculated metrics
    case 
        when count(distinct visitor_sessions.session_id) > 0 then 
            (count(distinct conversions.conversion_id) * 100.0) / count(distinct visitor_sessions.session_id)
        else 0 
    end as session_conversion_rate_pct,
    
    case 
        when count(distinct visitor_sessions.session_id) > 0 then sum(conversions.revenue) / count(distinct visitor_sessions.session_id)
        else 0 
    end as revenue_per_session,
    
    case 
        when sum(visitor_sessions.time_on_site_seconds) > 0 then sum(conversions.revenue) / (sum(visitor_sessions.time_on_site_seconds) / 60.0)
        else 0 
    end as revenue_per_minute,
    
    current_timestamp as date_transformed
    
from {{ ref('int_visitor_sessions') }} as visitor_sessions
left join {{ ref('int_journey_events') }} as journey_events 
    on visitor_sessions.visitor_id = journey_events.visitor_id 
    and visitor_sessions.session_id = journey_events.session_id
left join {{ ref('int_conversions') }} as conversions 
    on visitor_sessions.visitor_id = conversions.visitor_id 
    and visitor_sessions.session_id = conversions.session_id
group by visitor_sessions.visitor_id