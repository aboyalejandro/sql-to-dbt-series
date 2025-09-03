select
    campaign_id,
    name as campaign_name,
    channel,
    start_date,
    end_date,
    budget,
    lifetime_spend,
    total_revenue,
    roi,
    target_cpa,
    status,
    objective,
    campaign_manager,
    created_at,
    notes
from {{ source('synthetic_data', 'campaigns') }}