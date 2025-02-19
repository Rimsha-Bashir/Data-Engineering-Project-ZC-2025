## Module 1 Homework: Docker & SQL

1. Understanding docker first run. 
Run docker with the python:3.12.8 image in an interactive mode, use the entrypoint bash.
What's the version of pip in the image?


Solution:
<span style="background-color: #FFFF00; color: black;">
Command - `docker run -it --entrypoint=bash python:3.12.8` in GitBash after cd to folder dir. 
Pip version - `24.3.1`
</span>

2. Understanding Docker networking and docker-compose.
Given the following docker-compose.yaml, what is the hostname and port that pgadmin should use to connect to the postgres database?

Solution: 
Both the service name `db` and the container name `postgres` can be used. 
PortNumber - 5432 (inside the netw, this port connects to the postgres container, so pgadmin must use this)
Hostname - db/postgres 
SO, <span style="background-color: #FFFF00; color: black;"> `db:5432` or `postgres:5432` </span>

3. Trip Segmentation Count
During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, respectively, happened:

Up to 1 mile
In between 1 (exclusive) and 3 miles (inclusive),
In between 3 (exclusive) and 7 miles (inclusive),
In between 7 (exclusive) and 10 miles (inclusive),
Over 10 miles


Solution:

Steps to execute for the setup:
- Run `docker-compose up -d` (creates pgadmin and postgres containers in the specified netw)
- Run `docker build -t ny_data_ingest:v0 .` to build the img defined in the `Dockerfile`. 
- Specify `URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz"` to download the data before running the `ny_data_ingest:v0` container to ingest data into postgres.
- Run the `ny_data_ingest:v0` container
```
docker run -it \
    --network=docker_sql_pg-network \
        ny_data_ingest:v0 \
        --user=root \
        --password=root \
        --host=pgdatabase \
        --port=5432 \
        --db=ny_taxi \
        --table_name=yellow_taxi_data \
        --url=${URL}
```

- Run `local_green_ny_ingest.ipynb` to download the green_taxi_data file. 

And run the queries in localhost:8080

SQL Query:
```
select 
	count(case when trip_distance<=1 then 1 end) as "upto 1 mile", 
	count(case when trip_distance>1 and trip_distance<=3 then 1 end) as "1-3 miles", 
	count(case when trip_distance>3 and trip_distance<=7 then 1 end) as "3-7 miles", 
	count(case when trip_distance>7 and trip_distance<=10 then 1 end) as "7-10 miles" , 
	count(case when trip_distance>10 then 1 end) as "Over 10 miles" 
from green_taxi_data
where lpep_pickup_datetime>='2019-10-01' and lpep_pickup_datetime<'2019-11-01'
and lpep_dropoff_datetime>='2019-10-01' and lpep_dropoff_datetime<'2019-11-01'; 

```
<span style="background-color: #FFFF00; color: black;">
Output:
`104,802; 198,924; 109,603; 27,678; 35,189`
</span>

