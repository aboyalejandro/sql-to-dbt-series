-- Test that CTR calculation is accurate (clicks/impressions) with tolerance for floating point precision
select 
    ad_id,
    impressions,
    clicks,
    ctr,
    case 
        when impressions > 0 then clicks / impressions 
        else 0 
    end as calculated_ctr
from {{ ref('stg_ads') }}
where impressions > 0 
  and abs(ctr - (clicks / impressions)) > 0.001