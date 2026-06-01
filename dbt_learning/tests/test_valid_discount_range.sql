-- tests/test_valid_discount_range.sql
-- Fails if discount is outside the valid 0–100% range

select *
from {{ ref('stg_order_items') }}
where discount_pct < 0 or discount_pct > 100