## Table of Contents


### DE Zoomcamp 2.2.1 - Workflow Orchestration Introduction

Workflow *orchestration* is similar to an orchestra will several different instruments playing. And the orchestraion is done by a *conductor* who oversees and assigns tasks. 

What is Kestra?
All in one automation and orchestration platform to perform ETL, schedule workflows, run batch pipelines or event driven pipelines.. has seamless API integration capabilities. You can also monitor your pipelines effectively. 
You can control your workflow in:
- No code 
- Low code
- Full code

What we will cover in the nest few lectures?
- Intro to Kestra 
- ETL - with postgres 
- ELT - with google cloud 
- Parameterizing exec 
- Scheduling workflows + backfills 
- Install kestra on cloud and sync workflows with git

### DE Zoomcamp 2.2.2 - Learn Kestra

1. [Getting Started with Kestra in 15 minutes](https://www.youtube.com/watch?v=a2BZ7vOihjg) 
2. [Kestra Beginner Tutorial (2024)](https://www.youtube.com/playlist?list=PLEK3H8YwZn1oaSNybGnIfO03KC_jQVChL)
    <details>
    <summary> Notes! </summary>
    

    **Docker Command to download kestra** 
    
    ```
    docker run --pull=always --rm -it -p 8080:8080 --user=root \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /tmp:/tmp kestra/kestra:latest server local
    ```

    This will start kestra on localhost:8080

    - Kestra workflows are called `Flows`
    - They're defined in yaml.
    - Works with any languages. 
    - Each flow has three key properties:
        - id - unique identifier for each 'flow'.
        - namespace - env you're task is running in
        - tasks - have serperate properties, must have id and type. 

    **How to use inputs?**
    Constant values. Set before task definition. Has id, type and default (default value).
    Types - string, integer, and boolean (typically)
    An example for a workflow:
        ```
        id: flow_id
        namespace: dev 

        inputs:
            - id: api_url 
            - type: STRING 
            - defaults: https://dummyjson.com/products

        tasks:
            - id: api 
              type: io.kestra.plugin.fs.http.Request
              url: "{{ input.api_url }}"
        
        ```
    You'll see the `api` task in the right pane - `Topology` section.
    The o/p will be request `response code 200`

    **How to pass o/p's between tasks?**
    
    (continuation to above code)

            - id: log_response
              type: io.kestra.core.tasks.log.log
              message: "{{ outputs.api.body }}"

    Here, we're aiming to get the `body` from the http response. You can check the log by going to Executions.. and you'll see the body of the dummyjson. 
    Go to `Executions -> Outputs` and select `api` (task-1) and click on render expression, 
    then type {{outputs.api.body}}, you'll get the same `body`, but in a better, more clear format. 

    Now, say you replace `log_response` with below:. 

            - id: python
              type: io.kestra.plugin.scripts.python.scripts
              docker:
                  image: python:slim 
              beforeCommands:
                  - pip install polaris
              warningOnStdErr: false 
              script: |
                import polaris as pl 
                data = {{outputs.api.body | jq('.products') | first}}
                df = pl.from.dicts(data)
                df.glimpse()
                df.select(["brand", "price"]). write_csv("{{outputDir}}/products.csv")
    
    Similar to before, go to `Executions -> Outputs`, select python, and access the o/p file directly in Kestra. (In the video, he passes the data further to another SQL task)

    **How to schedule workflows with triggers?**

        id: using_triggers
        namespace: dev 

        tasks:
            - id: hello_world
              type: io.kestr.core.tasks.log.log
              message: Hello World!

        triggers:
            - id: schedule_trigger
              type: io.kestra.core.models.triggers.types.Schedule
              cron: 0 0 1 * * 
              
              
    `0 0 1 * *` - will trigger the flow at 12am every 1st day of the month. 

    You can see the triggers under `Flows>Triggers`
    
    For cron expressions visit - [crontab.cronhub.io](https://crontab.cronhub.io/)

    **How to control orchestration logic with Flowable tasks?**

        - Parallel 
        - Subflows
        - Conditional branching

    **How to handles errors and failures?**
    
    Add an `errors` block after your task block and specify the error `command` property in the task. You can add a `retry` property block in your task. 

    **How docker is used inside Kestra?**

    Tasks run in different docker containers to avoid dependency clashes?
    
    </details>


### DE Zoomcamp 2.2.3 - ETL Pipelines with Postgres in Kestra

[NYC tlc data](https://github.com/DataTalksClub/nyc-tlc-data/releases)

#### **ETL Pipelines in Kestra** 

    Workflow Structure:

    - Download NYC tlc data selectively based on the inputs provided, which, in our case will be `green` or `yellow` taxi data, along with `year` and `month`.

    - Create seperate tasks for both^ and add them to staging tables which will include data for that month. 

    - Merge data from staging into another table that will store data from all months and year combined.   
    
    - Ingest the staging and data table into postgres database with pgadmin (both containers run using docker compose, including kestra)


    For `Database setup - Postgres + PgAdmin`, check [this](https://www.youtube.com/watch?v=ywAPYNYFaB4&t=150s). 

    Here, we run a separate postgres container, because note that, kestra has one as well. The `postgres` in kestra is dedicated to the Kestra application. It stores Kestra's operational data, configurations, workflows, and metadata and ensures that Kestra's data is managed and maintained separately from other databases. 
    
    That's why it's better to run a separate postgres container for our exercise data using docker compose [here](../Module%20-%202/postgres/docker-compose.yml). 

    You can either run pgAdmin locally on your machine with the right setup/config or run a container for it. 
    For this session, I ran pgAdmin in my local computer, with the below details:

    ``` - name: Postgres DB
        - connection: localhost             
        - port: 5433 
        - maintenance db: postgres-zoomcamp
        - username: kestra
    ```
    *`connection` can't be localhost if pgAdmin is run on a container. When running PG Admin from a container, you can't reference `localhost` as the host, as this will be referring to the localhost of the container, not the host machine.*


### Troubleshoot:

1. Faced an error on running [02_postgres_taxi.yaml]((../Module%20-%202/flows/02_postgres_taxi.yaml)). 
    ```
        green_create_table
        Cannot invoke "java.sql.Connection.rollback()" because "connection" is null
    ```
    Changed port below to `5433`, and it worked. Probably not why though. Gotta check. 
    ```
        pluginDefaults:
        - type: io.kestra.plugin.jdbc.postgresql
            values:
            url: jdbc:postgresql://host.docker.internal:5433/postgres-zoomcamp
            username: kestra
            password: k3str4
    ```

### Things to keep in mind:

1. When you have a dynamic value you want to assign use in another expression, you have to use render() because only then supplied the input can be read by the outer query in the correct format.