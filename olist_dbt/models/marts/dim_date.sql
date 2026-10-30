select
    cast(d as date)        as date_day,
    year(d)                as year,
    quarter(d)             as quarter,
    month(d)               as month,
    strftime(d, '%Y-%m')   as year_month,
    strftime(d, '%b')      as month_name,
    dayofweek(d)           as day_of_week,   -- 0 = Sunday
    strftime(d, '%a')      as day_name,
    dayofweek(d) in (0, 6) as is_weekend
from range(date '2016-01-01', date '2019-01-01', interval 1 day) as t(d)