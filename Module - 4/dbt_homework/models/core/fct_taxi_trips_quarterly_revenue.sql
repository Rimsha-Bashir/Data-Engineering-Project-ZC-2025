{{ config(materialized="table") }}

with
    cte as (
        select service_type, pickup_year, pickup_qtr, pickup_year_qtr, sum(total_amount) as total_revenue
        from {{ ref("fact_trips") }}
        where pickup_year in (2019, 2020)
        group by 1, 2, 3, 4
        order by 1, 2, 3
    )
select
    curr.service_type,
    curr.pickup_year_qtr as cur_year_qtr,
    prev.pickup_year_qtr as prev_year_qtr,
    round(((curr.total_revenue - prev.total_revenue) / prev.total_revenue)*100,2) as YoY_Growth
from cte as curr
join
    cte as prev
    on curr.service_type = prev.service_type
    and curr.pickup_year = prev.pickup_year + 1
    and curr.pickup_qtr = prev.pickup_qtr
order by curr.service_type, curr.pickup_year, curr.pickup_qtr

