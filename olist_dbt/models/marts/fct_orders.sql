with orders    as (select * from {{ ref('stg_orders') }}),
     customers as (select customer_id, customer_unique_id from {{ ref('stg_customers') }}),
     items     as (select * from {{ ref('int_order_items_agg') }}),
     payments  as (select * from {{ ref('int_order_payments_agg') }}),
     reviews   as (select order_id, review_score from {{ ref('stg_order_reviews') }})

select
    o.order_id,
    c.customer_unique_id,
    o.order_status,
    o.order_status not in ('canceled', 'unavailable')  as is_valid_sale,
    o.purchased_at,
    cast(o.purchased_at as date)                       as purchase_date,
    o.approved_at,
    o.shipped_at,
    o.delivered_at,
    o.estimated_delivery_at,

    coalesce(i.n_items, 0)                             as n_items,
    i.n_sellers,
    coalesce(i.items_value, 0)                         as items_value,
    coalesce(i.freight_value, 0)                       as freight_value,
    coalesce(i.items_value, 0) + coalesce(i.freight_value, 0) as order_value,
    p.payment_value,
    p.main_payment_type,
    p.max_installments,

    date_diff('day', cast(o.purchased_at as date), cast(o.delivered_at as date))          as delivery_days,
    date_diff('day', cast(o.purchased_at as date), cast(o.estimated_delivery_at as date)) as promised_days,
    date_diff('day', cast(o.estimated_delivery_at as date), cast(o.delivered_at as date)) as delay_days,
    cast(o.delivered_at as date) > cast(o.estimated_delivery_at as date)                  as is_late,

    r.review_score,
    r.review_score <= 2                                as is_negative_review
from orders o
left join customers c using (customer_id)
left join items     i using (order_id)
left join payments  p using (order_id)
left join reviews   r using (order_id)