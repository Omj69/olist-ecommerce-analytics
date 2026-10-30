select
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    f.customer_unique_id,
    f.purchase_date,
    f.order_status,
    f.is_valid_sale,
    i.price,
    i.freight_value
from {{ ref('stg_order_items') }} i
join {{ ref('fct_orders') }} f using (order_id)