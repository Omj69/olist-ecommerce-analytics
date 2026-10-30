select
    order_id,
    sum(payment_value)                   as payment_value,
    count(*)                             as n_payments,
    max(payment_installments)            as max_installments,
    arg_max(payment_type, payment_value) as main_payment_type
from {{ ref('stg_order_payments') }}
group by 1