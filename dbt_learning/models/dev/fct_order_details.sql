{{
    config(
        materialized='incremental',
        unique_key='order_item_id',
        post_hook=[
            "CREATE INDEX IF NOT EXISTS idx_fct_order_details_order_date   ON {{ this }} (order_date)",
            "CREATE INDEX IF NOT EXISTS idx_fct_order_details_customer_id  ON {{ this }} (customer_id)"
        ]
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

        -- surrogate key 
        {{ dbt_utils.generate_surrogate_key(['oi.order_id', 'oi.order_item_id']) }} as order_detail_sk,

        -- keys
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        o.customer_id,

        -- customer info
        c.first_name,
        c.last_name,
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

        -- gross
        (oi.quantity * oi.unit_price) as gross_amount,

        -- net (USING MACRO - TASK 4.3)
        {{ calculate_revenue(
            'oi.quantity',
            'oi.unit_price',
            'oi.discount_pct'
        ) }} as net_amount,

        -- total (net + shipping)
        (
            {{ calculate_revenue(
                'oi.quantity',
                'oi.unit_price',
                'oi.discount_pct'
            ) }}
            + coalesce(o.shipping_fee, 0)
        ) as total_amount,

        -- TASK 4.2: currency conversion 
        {{ convert_currency(
            '(
                oi.quantity * oi.unit_price *
                (1 - oi.discount_pct / 100.0)
            )',
            'o.currency',
            'USD'
        ) }} as total_amount_usd

    from order_items oi

    left join orders o
        on oi.order_id = o.order_id

    left join products p
        on oi.product_id = p.product_id

    left join customers c
        on o.customer_id = c.customer_id
)

select * from final