{{
    config(
        materialized='incremental',
        unique_key='order_item_id'
    )
}}

with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('stg_orders') }}

    {% if is_incremental() %}
        where order_date >
            (select max(order_date) from {{ this }}) - interval '3 days'
    {% endif %}
),

products as (
    select * from {{ ref('stg_products') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        -- grain
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        o.customer_id,

        -- customer info
        c.customer_name,
        c.email,
        c.country as customer_country,

        -- product info
        p.product_name,
        p.category,
        p.subcategory,

        -- order info
        o.order_date,
        o.order_status,
        o.shipping_fee,
        o.currency,
        o.store_id,

        -- item metrics
        oi.quantity,
        oi.unit_price,
        oi.discount_pct,

        -- calculations
        (oi.quantity * oi.unit_price) as gross_amount,

        (oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
            as net_amount,

        (
            (oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0))
            + coalesce(o.shipping_fee, 0)
        ) as total_amount

    from order_items oi
    left join orders o
        on oi.order_id = o.order_id

    left join products p
        on oi.product_id = p.product_id

    left join customers c
        on o.customer_id = c.customer_id
)

select * from final