{{ config(materialized="table") }}

with
    fhv_tripdata as (select * from {{ ref("stg_fhv_tripdata") }}),
    dim_zones as (select * from {{ ref("dim_zones") }} where borough != 'Unknown')

select
    fhv.dispatching_base_num as dispatching_base_num,
    fhv.pickup_datetime as pickup_datetime,
    extract(year from fhv.pickup_datetime) as pickup_year,
    extract(month from fhv.pickup_datetime) as pickup_month,
    extract(quarter from fhv.pickup_datetime) as pickup_qtr,
    concat(
        extract(year from fhv.pickup_datetime),
        '/Q',
        extract(quarter from fhv.pickup_datetime)
    ) as pickup_year_qtr,
    fhv.dropoff_datetime as dropoff_datetime,
    fhv.pickup_locationid as pickup_locationid,
    fhv.dropoff_locationid as dropoff_locationid,
    dmz_pu.borough as pickup_borough,
    dmz_do.borough as dropoff_borough,
    dmz_pu.zone as pickup_zone,
    dmz_do.zone as dropoff_zone,
    dmz_pu.service_zone as pickup_service_zone,
    dmz_do.service_zone as dropoff_service_zone
from fhv_tripdata as fhv
inner join dim_zones as dmz_pu on fhv.pickup_locationid = dmz_pu.locationid
inner join dim_zones as dmz_do on fhv.dropoff_locationid = dmz_do.locationid
