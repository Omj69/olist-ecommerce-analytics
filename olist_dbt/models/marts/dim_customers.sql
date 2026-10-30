with orders as (
    select * from {{ ref('fct_orders') }}
),

customer_orders as (
    select
        customer_unique_id,
        min(purchased_at)                                          as first_order_at,
        max(purchased_at)                                          as last_order_at,
        count(*) filter (where is_valid_sale)                      as n_orders,
        coalesce(sum(order_value) filter (where is_valid_sale), 0) as lifetime_value,
        avg(review_score)                                          as avg_review_score
    from orders
    group by 1
),

latest_location as (
    select c.customer_unique_id, c.zip_code_prefix, c.city, c.state
    from {{ ref('stg_customers') }} c
    join {{ ref('stg_orders') }} o using (customer_id)
    qualify row_number() over (
        partition by c.customer_unique_id
        order by o.purchased_at desc
    ) = 1
)

select
    co.*,
    l.zip_code_prefix,
    l.city,
    l.state,
    g.lat,
    g.lng
from customer_orders co
left join latest_location l using (customer_unique_id)
left join {{ ref('stg_geolocation') }} g using (zip_code_prefix)