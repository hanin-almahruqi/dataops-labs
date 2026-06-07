{{
    config(
        materialized='table'
    )
}}

{% set target_year = 2024 %}

{% set months = [
    ('01', 'jan'), ('02', 'feb'), ('03', 'mar'),
    ('04', 'apr'), ('05', 'may'), ('06', 'jun'),
    ('07', 'jul'), ('08', 'aug'), ('09', 'sep'),
    ('10', 'oct'), ('11', 'nov'), ('12', 'dec')
] %}

with order_data as (

    select
        o.store_id,
        o.order_date,
        oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0) as net_amount
    from {{ ref('stg_orders') }} o
    inner join {{ ref('stg_order_items') }} oi
        on o.order_id = oi.order_id

)

select
    store_id,

    {% for month_num, month_name in months %}
    sum(
        case
            when extract(year from order_date) = {{ target_year }}
             and extract(month from order_date) = {{ month_num }}
            then net_amount
            else 0
        end
    ) as {{ month_name }}_revenue{{ "," if not loop.last }}
    {% endfor %}

from order_data
group by store_id
order by store_id