select *
from {{ ref('stg_products') }}
where cost_price < 0