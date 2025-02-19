## Module 1 Homework: Docker & SQL

1. Understanding docker first run. 
Run docker with the python:3.12.8 image in an interactive mode, use the entrypoint bash.
What's the version of pip in the image?


    SOLUTION:

    __Command - `docker run -it --entrypoint=bash python:3.12.8` in GitBash after cd to folder dir.__

    __Pip version - `24.3.1`__




2. Understanding Docker networking and docker-compose.
Given the following docker-compose.yaml, what is the hostname and port that pgadmin should use to connect to the postgres database?

    SOLUTION: 
    Both the service name `db` and the container name `postgres` can be used. 

    PortNumber - 5432 (inside the netw, this port connects to the postgres container, so pgadmin must use this)

    Hostname - db/postgres 

    So, **`db:5432` or `postgres:5432`**




3. Trip Segmentation Count
During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, respectively, happened:

    SOLUTION:

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

    Output:
    **`104,802; 198,924; 109,603; 27,678; 35,189`**



4. Longest trip for each day
    Which was the pick up day with the longest trip distance? Use the pick up time for your calculations.

    Tip: For every day, we only care about one single trip with the longest distance.

    SOLUTION:
    ```
    select lpep_pickup_datetime, max(trip_distance) as max_trip
    from green_taxi_data 
    group by lpep_pickup_datetime order by 2 desc
    limit 1;
    ```

    Output:

    **`"2019-10-31 23:23:41","515.89"`**


5. Three biggest pickup zones
    Which were the top pickup locations with over 13,000 in total_amount (across all trips) for 2019-10-18?

    Consider only lpep_pickup_datetime when filtering by date.

    SOLUTION:
    ```
    select z."Zone", round(CAST(sum(g."total_amount") AS numeric),2) as "total_cost"
        from green_taxi_data as g 
        inner join zones as z
        on z."LocationID" = g."PULocationID"
        where g."lpep_pickup_datetime"::date='2019-10-18'
        group by 1
        order by 2 desc 
        limit 3;
    ```
    *Remember to cast total_amount to numeric, as round() exects a numeric value, not double precision*

    Output:
    **"Zone"	              "total_cost"**
    **"East Harlem North"	    18686.68**
    **"East Harlem South"	    16797.26**
    **"Morningside Heights"	    13029.79**


6. Question 6. Largest tip
    For the passengers picked up in October 2019 in the zone named "East Harlem North" which was the drop off zone that had the largest tip?

    Note: it's tip , not trip

    We need the name of the zone, not the ID.

    SOLTUION:
    ```
    select z1."Zone", max(g."tip_amount")
        from green_taxi_data as g 
        join zones as z
        on z."LocationID" = g."PULocationID"
        join zones as z1
        on z1."LocationID" = g."DOLocationID"
        where g."lpep_pickup_datetime"::date between'2019-10-01' and '2019-10-31'
            and z."Zone"='East Harlem North'
        group by 1
        order by 2 desc
        limit 1;  
    ```
    Output:
    **`"Zone"	        "max"`**
    **`"JFK Airport"	87.3`**


7. Which of the following sequences, respectively, describes the workflow for:

    Downloading the provider plugins and setting up backend,
    Generating proposed changes and auto-executing the plan
    Remove all resources managed by terraform

    <details>
        <summary>Executed steps</summary>

        - Recreate the VM with the setting specified. 
        - Change external ip in config file 
        - run ssh de-zoomcamp > you're inside the GCP VM shell. 
        - download terraform check notes. 
        - copy gcp-terraform/keys/sa-creds into vm using
            - cd to your local Module - 1/terraform dir
            - sftp de-zoomcamp 
            - mkdir .gc 
            - cd .gc (or you can skip this and the above step)
            - put gcp-terraform/keys/sa-creds.json
        - run > export GOOGLE_APPLICATION_CREDENTIALS=my-creds.json
        - run > gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
        `Activated service account credentials for: [terraform-runner@coral-velocity-451115-d9.iam.gserviceaccount.com] rimsha@de-zoomcamp:~$`
        (how terraform-runner? - it's the name of the service account. created in gcp)
        - now git clone your repo 
        - download terraform (follow all steps.. check notes)
        - move it to bin 
        - add path to .bashrc
        - do source ~/.bashrc
        - run terraform -v 
        - works, good 
        - now run your terraform commands (after cd-ing to the terraform folder)
        - now before destroying, you gotta import these objects -- bq dataset + storage bucket for example.. they've   been created manually in gcp but are not connected to terraform.../ are not in terraform state.  
        - terraform import google_storage_bucket.demo-bucket coral-velocity-451115-d9-terra-bucket
        - terraform import google_bigquery_dataset.demo-dataset demo_database
        - terraform state list 
        - you can now see it there. 
        - Now, you can terraform destroy and the objects will be destroyed. 
    </details>

    Output:
    **`terraform init, terraform apply -auto-approve, terraform destroy`**