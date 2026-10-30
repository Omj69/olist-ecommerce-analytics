-- Gotcha 5: one row per zip prefix, points outside Brazil removed
select
    lpad(cast(geolocation_zip_code_prefix as varchar), 5, '0') as zip_code_prefix,
    avg(geolocation_lat) as lat,
    avg(geolocation_lng) as lng
from {{ source('raw', 'geolocation') }}
where geolocation_lat between -34 and 6
  and geolocation_lng between -74 and -34
group by 1