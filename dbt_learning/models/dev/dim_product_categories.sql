{{
    config(
        materialized='table'
    )
}}

{% set categories = dbt_utils.get_column_values(
    table=ref('stg_products'),
    column='category'
) %}

select
    category
from {{ ref('stg_products') }}
where category is not null
group by category
order by category