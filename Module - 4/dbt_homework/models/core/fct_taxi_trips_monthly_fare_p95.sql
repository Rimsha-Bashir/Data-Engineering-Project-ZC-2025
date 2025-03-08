{{ config(materialized="table") }}

with
    filtered_entries as (
        select service_type, pickup_year, pickup_month, fare_amount
        from {{ ref("fact_trips") }}
        where
            fare_amount > 0
            and trip_distance > 0
            and payment_type_description in ('Cash', 'Credit card')
    )

select
    service_type,
    pickup_year,
    pickup_month,
    approx_quantiles(fare_amount, 100)[offset(97)] as p97,
    approx_quantiles(fare_amount, 100)[offset(95)] as p95,
    approx_quantiles(fare_amount, 100)[offset(90)] as p90
from filtered_entries
group by service_type, pickup_year, pickup_month
