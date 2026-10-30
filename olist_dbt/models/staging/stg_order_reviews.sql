-- Gotcha 2: keep only the latest review per order
select
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    cast(review_creation_date as timestamp)    as review_created_at,
    cast(review_answer_timestamp as timestamp) as review_answered_at
from {{ source('raw', 'order_reviews') }}
qualify row_number() over (
    partition by order_id
    order by review_answer_timestamp desc, review_id
) = 1