with orders as (
    select customer_unique_id,
           date_trunc('month', purchase_date) as order_month
    from {{ ref('fct_orders') }}
    where is_valid_sale
),
cohorts as (
    select customer_unique_id, min(order_month) as cohort_month
    from orders
    group by 1
),
activity as (
    select c.cohort_month,
           date_diff('month', c.cohort_month, o.order_month) as months_since_first,
           count(distinct o.customer_unique_id)              as customers
    from orders o
    join cohorts c using (customer_unique_id)
    group by 1, 2
)
select cohort_month,
       months_since_first,
       customers,
       100.0 * customers / first_value(customers) over (
           partition by cohort_month order by months_since_first) as retention_pct
from activity