{{ config(materialized="view") }}

with
    fhv_tripdata as (
        select *
        from {{ source("staging", "external_fhv_tripdata_2019") }}
        where dispatching_base_num is not null
    )

select
    dispatching_base_num,
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    {{ dbt.safe_cast("PUlocationID", api.Column.translate_type("integer")) }}
    as pickup_locationid,
    {{ dbt.safe_cast("DOlocationID", api.Column.translate_type("integer")) }}
    as dropoff_locationid,
    SR_Flag as sr_flag,
    Affiliated_base_number as affiliated_base_number, 
from fhv_tripdata