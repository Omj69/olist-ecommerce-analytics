-- Total order value in the fact table must equal the item-level total.
-- If a join ever fans out, this fails.
with fact  as (select sum(order_value) as v from {{ ref('fct_orders') }}),
     items as (select sum(price + freight_value) as v from {{ ref('stg_order_items') }})
select fact.v as fact_total, items.v as items_total
from fact, items
where abs(fact.v - items.v) > 0.01