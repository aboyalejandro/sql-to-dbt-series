{% snapshot snap_visitor_segments %}
{{
  config(
    target_schema='snapshots',
    strategy='check',
    unique_key='visitor_id',
    check_cols=[
        'visitor_frequency_segment',
        'visitor_value_segment', 
        'visitor_engagement_segment',
        'total_sessions',
        'total_conversions',
        'total_revenue'
    ],
    invalidate_hard_deletes=true
  )
}}

-- Capture visitor segment evolution as behavior changes over time
select 
    -- Visitor identifier
    visitor_id,
    
    -- Core metrics that drive segment changes
    total_sessions,
    total_conversions,
    total_revenue,
    total_page_views,
    avg_time_on_site,
    
    -- Segmentation columns that we want to track changes for
    visitor_frequency_segment,
    visitor_value_segment,
    visitor_engagement_segment,
    
    -- Journey metrics
    journey_span_days,
    first_session_time,
    last_session_time,
    
    -- Conversion behavior
    converting_sessions,
    session_conversion_rate_pct,
    revenue_per_session,
    
    -- Multi-touch attribution indicators  
    campaigns_touched,
    ads_touched,
    all_traffic_categories,
    first_source_medium,
    last_source_medium,
    
    -- Customer lifecycle stage classification
    case 
        when total_conversions = 0 then 'prospect'
        when total_conversions = 1 and total_revenue < 100 then 'new_customer'
        when total_conversions > 1 and total_revenue < 500 then 'repeat_customer'
        when total_conversions > 1 and total_revenue >= 500 then 'vip_customer'
        else 'unknown'
    end as lifecycle_stage,
    
    -- Engagement evolution indicators
    case 
        when total_sessions = 1 then 'first_visit'
        when total_sessions <= 5 then 'exploring'
        when total_sessions <= 15 then 'engaged'
        else 'loyal'
    end as journey_stage,
    
    -- Risk indicators
    case 
        when date_diff('day', last_session_time, current_timestamp) > 30 then 'at_risk'
        when date_diff('day', last_session_time, current_timestamp) > 7 then 'inactive'
        else 'active'
    end as activity_status,
    
    -- Snapshot metadata
    date_transformed,
    current_date as snapshot_date

from {{ ref('visitor_journey') }}

{% endsnapshot %}