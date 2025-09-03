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
    
    case 
        when ads.ctr > 0.02 then 'high'
        when ads.ctr > 0.01 then 'medium'
        else 'low'
    end as ctr_performance,
    
    case 
        when ads.cpa < campaigns.target_cpa then 'under_target'
        when ads.cpa = campaigns.target_cpa then 'on_target'  
        else 'over_target'
    end as cpa_vs_target,
    
    -- calculated metrics
    case 
        when ads.spend > 0 then ads.conversions / ads.spend 
        else null 
    end as conversion_per_dollar,
    
    case 
        when campaign_budget > 0 then (ads.spend / campaign_budget) * 100 
        else null 
    end as ad_budget_share_pct,
    
    current_timestamp as date_transformed
    
from {{ ref('stg_campaigns') }} as campaigns
left join {{ ref('stg_ads') }} as ads 
    on campaigns.campaign_id = ads.campaign_id