with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('fct_order_details') }}
),

customer_orders as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        sum(total_amount) as total_spent
    from orders
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.email,
        c.signup_date,

        coalesce(co.total_orders, 0) as total_orders,
        coalesce(co.total_spent, 0) as total_spent

    from customers c
    left join customer_orders co
        on c.customer_id = co.customer_id
)

select * from final