-- Test that session_start is always <= session_end
select 
    session_id,
    visitor_id,
    session_start,
    session_end
from {{ ref('stg_sessions') }}
where session_start > session_end