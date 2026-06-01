select *
from "ecommerce"."STAGE"."stg_orders"
where order_date > current_date

1201	C-205	2099-12-31	completed	S-01	0.00	OMR
---------------------------------------------
select *
from "ecommerce"."STAGE"."stg_products"
where cost_price < 0

P-035	Old Keyboard Model	Peripherals	Input Devices	-5.00	29.99	USD	2019-01-01	false
---------------------------------------------

select *
from "ecommerce"."STAGE"."stg_order_items"
where quantity <= 0

309	1010	P-005	-2	59.99	0.00
---------------------------------------------

select *
from "ecommerce"."STAGE"."stg_orders"
where shipping_fee < 0

1204	C-215	2024-03-22	completed	S-04	-10.00	USD
---------------------------------------------

select *
from "ecommerce"."STAGE"."stg_order_items"
where discount_pct < 0 or discount_pct > 100

311	1020	P-009	3	14.99	150.00