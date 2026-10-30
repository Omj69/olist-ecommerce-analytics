select
    p.product_id,
    coalesce(t.category_name_en, p.category_name_pt, 'unknown') as category,
    p.category_name_pt,
    p.photos_qty,
    p.weight_g,
    p.length_cm * p.height_cm * p.width_cm                      as volume_cm3
from {{ ref('stg_products') }} p
left join {{ ref('stg_category_translation') }} t using (category_name_pt)