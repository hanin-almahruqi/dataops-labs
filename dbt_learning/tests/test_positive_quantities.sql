-- tests/test_positive_quantities.sql
-- Fails if any order item has zero or negative quantity

select *
from {{ ref('stg_order_items') }}
where quantity <= 0