select *
from {{ ref('stg_orders') }}
where shipping_fee < 0