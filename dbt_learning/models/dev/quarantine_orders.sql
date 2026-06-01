{{
    config(
        materialized='table'
    )
}}

with future_dates as (
    -- Orders with dates in the future
    select *, 'future_order_date' as failure_reason
    from {{ ref('stg_orders') }}
    where order_date > current_date
),

missing_customer as (
    -- Orders with no customer assigned
    select *, 'missing_customer_id' as failure_reason
    from {{ ref('stg_orders') }}
    where customer_id is null or trim(customer_id) = ''
),

negative_shipping as (
    -- Orders with negative shipping fees
    select *, 'negative_shipping_fee' as failure_reason
    from {{ ref('stg_orders') }}
    where shipping_fee < 0
),

bad_status as (
    -- Orders with unrecognized statuses
    select *, 'invalid_order_status' as failure_reason
    from {{ ref('stg_orders') }}
    where order_status not in ('completed', 'pending', 'shipped', 'returned', 'cancelled')
)

select * from future_dates
union all
select * from missing_customer
union all
select * from negative_shipping
union all
select * from bad_status