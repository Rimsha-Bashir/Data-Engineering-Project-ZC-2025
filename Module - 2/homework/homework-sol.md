1. Within the execution for Yellow Taxi data for the year 2020 and month 12: what is the uncompressed file size (i.e. the output file yellow_tripdata_2020-12.csv of the extract task)?

    - `128.3 MiB`
    - 134.5 MiB
    - 364.7 MiB
    - 692.6 MiB

![Q1-sol](Q1.png)

Set `disable` to `true` in the purge files task inside the Flow `06_gcp_taxi` to retain the output file when execution completes so you can check the size. 

2. What is the rendered value of the variable file when the inputs taxi is set to green, year is set to 2020, and month is set to 04 during execution?

    - {{inputs.taxi}}_tripdata_{{inputs.year}}-{{inputs.month}}.csv
    - `green_tripdata_2020-04.csv`
    - green_tripdata_04_2020.csv
    - green_tripdata_2020.csv

3. How many rows are there for the Yellow Taxi data for all CSV files in the year 2020?

    - 13,537.299
    - `24,648,499`
    - 18,324,219
    - 29,430,127

```sql
SELECT count(*) FROM `coral-velocity-451115-d9.zoomcamp.yellow_tripdata` where filename like "%2020%";
```

```sql 
SELECT count(*) FROM `coral-velocity-451115-d9.zoomcamp.yellow_tripdata` where EXTRACT(YEAR from tpep_pickup_datetime)=2020 and EXTRACT(YEAR from tpep_dropoff_datetime)=2020; 
```

4. How many rows are there for the Green Taxi data for all CSV files in the year 2020?

    - 5,327,301
    - 936,199
    - `1,734,051`
    - 1,342,034

```sql
SELECT count(*) FROM `coral-velocity-451115-d9.zoomcamp.green_tripdata` where filename like "%2020%";
```

5. How many rows are there for the Yellow Taxi data for the March 2021 CSV file?

    - 1,428,092
    - 706,911
    - `1,925,152`
    - 2,561,031

```sql 
SELECT count(*) FROM `coral-velocity-451115-d9.zoomcamp.yellow_tripdata` where filename like "%2021%"
and EXTRACT(MONTH from tpep_pickup_datetime)=3;
```

6. How would you configure the timezone to New York in a Schedule trigger?

    - Add a timezone property set to EST in the Schedule trigger configuration
    - `Add a timezone property set to America/New_York in the Schedule trigger configuration`
    - Add a timezone property set to UTC-5 in the Schedule trigger configuration
    - Add a location property set to New_York in the Schedule trigger configuration