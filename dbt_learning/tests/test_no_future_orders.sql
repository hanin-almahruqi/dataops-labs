-- tests/test_no_future_orders.sql
-- Fails if any order has a date in the future

select *
from {{ ref('stg_orders') }}
where order_date > current_date