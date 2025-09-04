{% snapshot snap_campaign_performance %}
{{
  config(
    target_schema='snapshots',
    strategy='timestamp',
    unique_key='campaign_id',
    updated_at='date_transformed',
    invalidate_hard_deletes=true
  )
}}

-- Capture daily campaign performance metrics for historical trend analysis
select 
    -- Campaign identifiers
    campaign_id,
    campaign_name,
    campaign_channel,
    campaign_status,
    
    -- Core performance metrics that change daily
    total_ads,
    total_impressions,
    total_clicks,
    total_ad_spend,
    total_conversions,
    total_conversion_value,
    total_revenue,
    
    -- Key calculated metrics for trend analysis
    roas,
    conversion_rate_pct,
    actual_cpa,
    revenue_per_visitor,
    
    -- Performance vs targets
    campaign_target_cpa,
    case 
        when actual_cpa < campaign_target_cpa then 'under_target'
        when actual_cpa = campaign_target_cpa then 'on_target'
        else 'over_target'
    end as cpa_performance,
    
    -- Budget utilization
    campaign_budget,
    case 
        when campaign_budget > 0 then (total_ad_spend / campaign_budget) * 100 
        else 0 
    end as budget_utilization_pct,
    
    -- Performance tier classification
    case 
        when roas >= 4.0 then 'excellent'
        when roas >= 2.0 then 'good'
        when roas >= 1.0 then 'break_even'
        else 'poor'
    end as roas_tier,
    
    case 
        when conversion_rate_pct >= 5.0 then 'high_converting'
        when conversion_rate_pct >= 2.0 then 'medium_converting'
        else 'low_converting'
    end as conversion_tier,
    
    -- Snapshot metadata
    date_transformed,
    current_date as snapshot_date

from {{ ref('campaign_performance') }}

{% endsnapshot %}