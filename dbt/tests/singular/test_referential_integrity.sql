-- Test referential integrity across all staging tables
-- This test checks that all foreign key relationships are valid

with integrity_checks as (
    -- Sessions should reference valid campaigns
    select 'sessions_to_campaigns' as check_type, count(*) as violations
    from {{ ref('stg_sessions') }} s
    left join {{ ref('stg_campaigns') }} c on s.campaign_id = c.campaign_id
    where s.campaign_id is not null and c.campaign_id is null
    
    union all
    
    -- Sessions should reference valid ads  
    select 'sessions_to_ads' as check_type, count(*) as violations
    from {{ ref('stg_sessions') }} s
    left join {{ ref('stg_ads') }} a on s.ad_id = a.ad_id
    where s.ad_id is not null and a.ad_id is null
    
    union all
    
    -- Conversions should reference valid sessions
    select 'conversions_to_sessions' as check_type, count(*) as violations
    from {{ ref('stg_conversions') }} c
    left join {{ ref('stg_sessions') }} s on c.session_id = s.session_id
    where c.session_id is not null and s.session_id is null
    
    union all
    
    -- Ads should reference valid campaigns
    select 'ads_to_campaigns' as check_type, count(*) as violations
    from {{ ref('stg_ads') }} a
    left join {{ ref('stg_campaigns') }} c on a.campaign_id = c.campaign_id
    where a.campaign_id is not null and c.campaign_id is null
)

select *
from integrity_checks
where violations > 0