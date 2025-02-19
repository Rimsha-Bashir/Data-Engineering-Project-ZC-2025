Q2. 
Steps to execute:
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

I had to change the network to `docker_sql_pg-network` which is where the containers postgres and pgadmin were running too. 
I have tried to add `network: pg-network` in the docker-compose file, but for some reason the containers still run in the default container created by docker-compose, i.e `docker_sql_pg-network` which is <folder_name>_<network_name>
You can always troubleshoot using `docker network inspect pg-network` to check if the containers are running on it or not. 