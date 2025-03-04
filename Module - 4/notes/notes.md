## Table of Contents
- [Intro to Analytics Engineering](#analytics-engineering-basics)
- [Data Modeling Concepts](#data-modeling-concepts)
    - [ETL v/s ELT](#etl-vs-elt)
    - [Dimensional Modeling](#kimballs-dimensional-modeling)
- [Intro to DBT](#intro-to-dbt)


### Analytics Engineering Basics

[YT Link - DE Zoomcamp 4.1.2 - Analytics Engineering Basics](https://www.youtube.com/watch?v=uF76d5EmdtU&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=33)

In a traditional data team, we recognize the data engineer, the data analyst, and sometimes the data scientist. The data engineer prepares and maintains the infrastructure the data team needs. The data analyst uses the data hosted in that infrastructure to answer questions and solve problems.

With recent developments, data scientists and analysts are writing more code, but they are not trained as software engineers, and this is not their primary focus. Similarly, data engineers, while excellent software engineers, lack training in how the data is used by business users.

This gap is where the analytics engineer comes in. The role combines elements of the data engineer and the data analyst. It introduces good software engineering practices from the data engineer to the efforts of data analysts and scientists.

`Analytics Engineering` is an *inersection* of Data Analyst and Data Engineer. 

![ae1](../notes/images/ae1.jpg)


`Tools / Tech stack` an AE could be exposed to:

![ae0](../notes/images/ae0.png)

In this Module, we'll be focussing on `Data Modeling` and `Data Presentation`


### Data Modeling Concepts

#### **ETL v/s ELT**

![ae2](../notes/images/ae2.jpg)

In an ELT architecture, the Data Warehouse used for storage is also a `data transformation` tool, like BigQuery for example. This eradicates the need to find a medium to transform data, hence reducing costs and increasing operations and analysis flexibility.

#### Kimball's Dimensional Modeling

To understand Kimball’s approach to data modeling, we should begin by talking about the star schema. The star schema is a particular way of organizing data for analytical purposes. It consists of two types of tables:

A fact table, which acts as the primary table for the schema. A fact table contains the primary measurements, metrics, or ‘facts’ of a business process.
Many dimension tables associated with the fact table. Each dimension table contains `dimensions` — that is, descriptive attributes of the fact table.
These dimensional tables are said to `surround` the fact table, which is where the name `star schema` comes from.

![ae3](../notes/images/ae3.jpg)

The star schema is useful because it gives us a standardized, time-tested way to think about shaping your data for analytical purposes. It is:

- Flexible — it allows your data to be easily sliced and diced any which way your business users want to.
- Extensible — you may evolve your star schema in response to business changes.
- Performant — Kimball’s dimensional modeling approach was developed when the majority of analytical systems were run on relational database management systems (RDBMSes). The star schema is particularly performant on RDBMSes, as most queries end up being executed using the ‘star join’, which is a Cartesian product of all the dimensional tables.

Kimball's Dimensional Modeling is an approach to Data Warehouse design which focuses on 2 main points:

- Deliver data that is understandable to the business
- Deliver fast query performance
- Other goals such as reducing redundant data (prioritized by other approaches) are secondary. We are not going to focus heavily on making sure that data is not redundant; instead, we prioritize user understandability of this data and query performance.

Architecture of Dimensional Modeling

An analogy that is presented in Kimball's dimensional modeling is the kitchen analogy. The book compares how the data warehouse and the ETL process could be compared with a restaurant:

- `Staging Area`: Here, we have the raw data. This is not meant to be exposed to everyone but only to those who know how to use that raw data. In the case of a restaurant, this would be the food in its raw state before being processed.

- `Processing Area`: This is the kitchen in a restaurant. Here, raw data is processed and turned into data models. Again, this is limited to those who know how to do this, such as the cooks. The focus is on efficiency and ensuring standards are followed.

- `Presentation Area`: This is the dining hall and represents the final presentation of the data. Here, the data is exposed to business stakeholders.

### Intro to dbt (data build tool)

[YT Link - DE Zoomcamp 4.1.2 - What is dbt?](https://www.youtube.com/watch?v=gsKuETFJr54&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=34)

#### What is DBT?

dbt or data build tool is a transformation workflow that allows us to use SQL, or Python as well, to deploy analytical code. This code enables us to process all the data loaded from different sources. For example, in our case, we're using taxi data, but in a company setting, as a data engineer, you might work with data from backend systems, apps, frontend systems, or even third-party providers.

With dbt, anyone who knows how to write SQL SELECT statements has the power to build models, write tests, and schedule jobs to produce reliable, actionable datasets for analytics. The tool acts as an orchestration layer on top of your data warehouse and helps transform raw data into something meaningful and useful for the business or stakeholders. This transformed data could be consumed by BI tools or integrated into other workflows, such as machine learning pipelines.

![ae4](../notes/images/ae4.jpg)

#### How does dbt work?

In dbt, a model is essentially a SQL file where you write the logic to transform your data. For instance, if you have raw data in your data warehouse, you can create a model to apply transformations, clean it, and make it more structured and useful for analysis. A dbt model typically contains a SQL statement, such as a SELECT query, that defines how the data should be transformed.

A dbt model looks like this:

```sql
WITH
    orders as (select * from {{ref('orders')}}),
    line_items as (select * from {{ref('line_items')}})

SELECT
    id,
    sum(line_items.purchase_price)    

FROM orders
LEFT JOIN line_items ON orders.id = line_items.order_id

GROUP BY 1;
```

![ae5](../notes/images/ae5.jpg)

Here’s how it works step by step:

Selection of Raw Data: The SQL statement in your model pulls raw data from the source tables or external datasets in the data warehouse.

Transformation: The model applies transformations, such as filtering, aggregations, joins, or calculations, to clean and organize the raw data

Persistence: Once the data is transformed, dbt persists the results back into the data warehouse as a table or a view. A table is a physical dataset stored in the warehouse. A view is a virtual dataset that dynamically runs the transformation logic whenever queried.

#### How to use dbt?

There are two ways to use dbt

1. dbt cloud: SaaS application to develop and manage dbt projects.

    - Web-based IDE to develop, run and test a dbt project.
    - Jobs orchestration.
    - Logging and alerting.
    - Intregrated documentation.
    - Free for individuals (one developer seat).

2. dbt core: Open-source project that allows the data transformation.

    - Builds and runs a dbt project (.sql and .yaml files).
    - Includes SQL compilation logic, macros and database adapters.
    - Includes a CLI interface to run dbt commands locally.
    - Open-source and free to use.

#### How are we going to use dbt?

There are two ways to use dbt, and throughout the project, you'll see videos illustrating these approaches: version A and version B.

- `Version A` primarily uses BigQuery as the data warehouse. This method involves using the dbt Cloud Developer plan, which is free. You can create an account at no cost, and since this is cloud-based, there’s no need to install dbtcore locally.

- `Version B` uses PostgreSQL. In this approach, you'll perform development using your own IDE, such as VS Code, and install dbt Core locally connecting to the postgresql database. You will be running dbt models through the CLI

During the project you might already have data loaded into GCP buckets. This raw data will be loaded into tables in BigQuery. dbt will be used to transform the data, and finally, dashboards will be created to present the results.

![ae6](../notes/images/ae6.jpg)

### Setting up dbt with bigquery

[YT Link- DE Zoomcamp 4.2.1 - Start Your dbt Project BigQuery and dbt Cloud (Alternative A)](https://www.youtube.com/watch?v=J0XCDyKiU64&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=35)

1. Create a BigQuery service account

    In order to connect we need the service account JSON file generated from bigquery. Open the BigQuery credential wizard to create a service account

    Steps: 

    [Setup vid followed](https://www.youtube.com/watch?v=_C_pYeuF6_s)

    1. Create an account in dbt cloud. (free for developers)
    2. Create a service account in your google cloud project. I'm going to use `zoomcamp` (an existig one), with BigQuery Admin rights.
    3. Now, you need to go to `GCP Console > API's and Services > Library`, type `BigQuery API` and enable it. 
        > Note: We need this because we're looking to establish a connection between BQ and an external entity (dbt) here.

        ![ae7](../notes/images/ae7.png)

    4. Create a new project in dbt. Next, click on `Add new Connection` in the connection/advanced settings.

        ![alt text](./images/ae8.png)

        Select `BigQuery` and set up a BQ connection 

        ![alt text](./images/ae9.png)

    5. Name the Connection `zoomcamp_biquery` and upload service account json file from step 2.

    6. Go to `Settings > Projects > Configure Repository`

        ![alt text](./images/ae10.png)

    7. Choose the `Github` option and perform the consequent steps necessary to set dbt up with github. 
        > Note: You can also choose the `git clone` methodology. 

    8. You will be redirected to github. Select the repos you want to connect to dbt (you can select all repos as well).

    9. Under `Settings > Projects` in dbt cloud, click on `Configure Repository` and select the repo added in step 8. 

        ![alt text](./images/ae11.png)

        You should then be able to see the repository.. 

        ![alt text](./images/ae12.png)
    
    10. You can further edit project details to create subdirectory to be used in Github and modify project name as you like. 

        ![alt text](./images/ae13.png)

    11. Then, configure development environment and add the connection `zoomcamp_bigquery` created in step 5. 

    12. You can test the connection in `Profile > Credentials`. 

        ![alt text](./images/ae14.png)


