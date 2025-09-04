-- Test that campaign start_date is always <= end_date
select 
    campaign_id,
    campaign_name,
    start_date,
    end_date
from {{ ref('stg_campaigns') }}
where start_date > end_date