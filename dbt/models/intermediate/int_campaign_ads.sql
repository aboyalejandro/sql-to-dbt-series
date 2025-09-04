select 
    -- campaign identifiers
    campaigns.campaign_id,
    campaigns.campaign_name,
    
    -- campaign details
    campaigns.channel as campaign_channel,
    campaigns.start_date::date as campaign_start_date,
    campaigns.end_date::date as campaign_end_date,
    campaigns.budget as campaign_budget,
    campaigns.lifetime_spend as campaign_lifetime_spend,
    campaigns.total_revenue as campaign_total_revenue,
    campaigns.roi as campaign_roi,
    campaigns.target_cpa as campaign_target_cpa,
    campaigns.status as campaign_status,
    campaigns.objective as campaign_objective,
    campaigns.campaign_manager,
    campaigns.created_at::timestamp as campaign_created_at,
    campaigns.notes as campaign_notes,
    
    -- ad identifiers
    ads.ad_id,
    ads.ad_name,
    
    -- ad details
    ads.creative_type,
    ads.platform as ad_platform,
    ads.placement,
    ads.start_date::date as ad_start_date,
    ads.end_date::date as ad_end_date,
    ads.ad_status,
    ads.targeting,
    ads.last_updated::timestamp as ad_last_updated,
    
    -- ad performance metrics
    ads.impressions,
    ads.clicks,
    ads.ctr,
    ads.spend as ad_spend,
    ads.avg_cpc,
    ads.conversions as ad_conversions,
    ads.cpa as ad_cpa,
    
    -- business logic flags
    case 
        when campaigns.status = 'active' and ads.ad_status = 'active' then true 
        else false 
    end as is_both_active,
    
    case 
        when campaigns.end_date::date >= current_date then true 
        else false 
    end as is_campaign_current,
    
    case 
        when ads.end_date::date >= current_date then true 
        else false 
    end as is_ad_current,
    
    -- performance tiers using macros
    {{ classify_performance_tier(
        column_name='ads.ctr',
        tier_name='ctr_performance',
        high_threshold=0.02,
        medium_threshold=0.01
    ) }},
    
    {{ classify_vs_target(
        actual_column='ads.cpa',
        target_column='campaigns.target_cpa',
        comparison_name='cpa_vs_target'
    ) }},
    
    -- calculated metrics using macros
    {{ safe_divide('ads.conversions', 'ads.spend') }} as conversion_per_dollar,
    
    {{ calculate_percentage_share('ads.spend', 'campaign_budget', 'ad_budget_share_pct') }},
    
    current_timestamp as date_transformed
    
from {{ ref('stg_campaigns') }} as campaigns
left join {{ ref('stg_ads') }} as ads 
    on campaigns.campaign_id = ads.campaign_id