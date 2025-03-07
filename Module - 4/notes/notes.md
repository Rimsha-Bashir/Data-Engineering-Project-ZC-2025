## Table of Contents
- [Intro to Analytics Engineering](#analytics-engineering-basics)
- [Data Modeling Concepts](#data-modeling-concepts)
    - [ETL v/s ELT](#etl-vs-elt)
    - [Dimensional Modeling](#kimballs-dimensional-modeling)
- [Intro to dbt](#intro-to-dbt)
    - [What is dbt?](#what-is-dbt)
    - [How does dbt work?](#how-does-dbt-work)
    - [How to use dbt?](#how-to-use-dbt)
- [Setting up dbt with bigquery](#setting-up-dbt-with-bigquery)
- [Setting up dbt with postgres](#start-your-dbt-with-postgres)
- [Development of dbt models](#development-of-dbt-models)
    - [Modular Data Modeling - Fact & Dimesions](#modular-data-modelling)
    - [Anatomy of a dbt model](#anatomy-of-a-dbt-model)
    - [Key concepts and setup of dbt models](#key-concepts-and-setup-of-dbt-models)
- [Developing staging models - Prelim processing](#developing-staging-models)
    - [Model Config file - schema.yml](#schemayml)
    - [Model 1 - stg_green_tripdata.sql](#model-1-stg_green_tripdatasql)
    - [Model 2 - stg_yellow_tripdata.sql](#model-1-stg_yellow_tripdatasql)
    - [Lineage View of Staging models](#lineage-view)
- [Developing Core Models - Fact & Dimensions](#developing-core-models---fact--dimensions)
    - [Seed: taxi_zone_lookup.csv](#seed-taxi_zone_lookupcsv)
    - [Model 1 - dim_zones.sql](#model-1-dim_zonessql)
    - [Model 2 - fact_trips.sql](#model-2-fact_tripssql)
    - [Model 3 - dm_monthly_zone_revenue.sql]()
    - [Lineage View of Core + Staging models](#lineage-view-1)
    - [Build Results](#build-result)
- [Testing & Documentation](#testing--documentation)
- [Deploying the project (using dbt Cloud)](#deploying-the-project-dbt-cloud)
- [Deploying the project (using dbt Cloud)](#deploying-the-project-locally)
- [Visualizing NYC data using Looker Studio](#visualizing-the-transformed-data-in-looker-studio)
- [Visualizing NYC data using Metabase](#visualising-the-data-with-metabase)
- [Important Notes](#important-notes)
- [Troubleshooting](#troubleshooting-errors)


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


There are two ways to implement the above, and throughout the project, you'll see videos illustrating these approaches: version A and version B.

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
    
    13. Now, you're set to explore the dbt cloud IDE (under `Develop`).


To follow along with the course video, I created a `dbt_test` branch in my git repo and pulled it in dbt cloud as well. 

![alt text](./images/ae15.png)

Click on `Initialize dbt` to create `starter dbt models` and a host of files are created under the subdirectory mentioned in step 10 above. 





### Start Your dbt with Postgres

[YT Link](https://www.youtube.com/watch?v=1HmL63e-vRs&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=36)

Install dbt Core locally and note that in this case, you define the `profiles.yml` file to initialized dbt. In the `profiles.yml` file you'll define the connection to the database you're using, which in this case, will be `Postgres`. The file will look something like this:
![alt text](./images/ae16.png)

*You have to create the schema/dataset in postgres.*

Installing dbt Core locally can be done following the steps in the [official docs](https://docs.getdbt.com/docs/core/installation-overview). For more information, check out the YT link above. 


### Development of dbt models

Let's start now with the development of those DBT models. If we go back to the initial lessons, DBT sits on top of our platform, either BigQuery or Postgres.

![alt text](./images/ae17.png)

We already loaded the raw data as the trips data. Now we're going to work on development, testing, and documentation. We'll start with development and by the end of these lessons, we'll deploy this into production to use those transformations in our BI tools.

#### Modular data modelling

To get started, we're going to use a modular data modeling approach. As we discussed in earlier lessons, we'll create fact tables and dimensional tables. The structure of our DBT project will look something like this:

First, we have the tables we loaded (trips data). These are our sources. (Step 1)

Then, we'll start building SQL scripts called "models" in DBT to perform transformations. (Step 3)

For example, we'll pick up the source data, clean it, deduplicate it, recast and rename columns, and typecast data. Afterward, we'll apply business logic to create fact and dimension tables. Finally, we'll create data marts to aggregate the data for our stakeholders. (Step 2)

We initially have tables that already exist outside our DBT project. These contain the data we will use, and we define them as sources. Additionally, we will use a file (e.g., taxi_zone_lookup) to create a table that will be incorporated into our transformations.

#### Anatomy of a dbt model

DBT models are SQL scripts. We'll always work with files named after the `model`, saved as `.sql`. Inside these files, we write SQL statements, primarily SELECT statements, because DBT handles the DDL (Data Definition Language) and DML (Data Manipulation Language) for us.

![alt text](./images/ae18.jpg)

1. `config(materialized = 'table')` indicates that the output of the model file should be materialized as a `table` in the database. It can be saved in different ways, see `materialization strategies` in the image above. When you run the command `dbt run`, it compiles all the SQL files in your project.

2. After the compilation, i.e ater the modelling script runs, it's going to look like this :

    ![alt text](./images/ae19.jpg)

Materialization Strategies: 

![alt text](./images/ae20.png)

1. Ephermeral: These tables are like CTE's they only exist within other models.
2. View: Every time you run dbt run, it creates or alters the view based on the SELECT statement in your file.
3. Table: This materializes as a table in the physical database. Each time you run the model, DBT drops the existing table and recreates it with the CREATE TABLE AS SELECT statement, as shown earlier.
4. Incremental: This is a more advanced materialization type. It also materializes as a table in the physical database, but instead of recreating the table entirely, it can work in two ways: Drop the table and recreate it with the SELECT statement or Insert only the new data into the table, allowing you to update the table incrementally.

#### Key concepts and setup of dbt models

<details>
  <summary>DBT (Data Build Tool) Explained Simply</summary>

  DBT is a tool used to transform raw data into clean, structured data inside a data warehouse like BigQuery, Snowflake, or Postgres. It lets data engineers and analysts write SQL-based transformations in an easy, scalable way.

  Key Concepts in DBT:

  1. SEEDS
     - Seeds are CSV files that you upload to the DBT project.
     - Useful for reference data like country codes, mappings, or small static datasets.
     - Example:
       - You have a countries.csv file:
         country_code,country_name
         US,United States
         IN,India
         UK,United Kingdom
       - In DBT, you place it in the seeds/ folder and run `dbt seed`.
       - DBT loads this CSV into your database as a table.

  2. MODELS
     - Models are SQL queries that transform data.
     - They help clean, aggregate, and join raw data into meaningful tables.
     - Types of models:
       - Staging models (clean raw data)
       - Intermediate models (joins & calculations)
       - Final models (ready for reporting)
     - Example:
       - File: models/stg_orders.sql
         SELECT order_id, user_id, order_date, total_price FROM raw.orders
       - Run `dbt run`.
       - DBT creates a table/view with cleaned order data.

  3. REFS
     - `ref()` is used to reference other models in DBT.
     - It ensures dependencies are handled automatically.
     - Example:
       - File: models/orders_summary.sql
         SELECT user_id, COUNT(order_id) AS total_orders, SUM(total_price) AS total_spent FROM {{ ref('stg_orders') }} GROUP BY user_id.
       - Instead of raw.orders, it references the cleaned stg_orders model.

  4. SOURCES
     - Sources define raw tables in your database.
     - Helps track where data is coming from.
     - Example:
       - File: models/schema.yml
         sources:
           - name: raw
             description: "Raw data from the production database"
             tables:
               - name: orders
                 description: "Order data before transformation"
       - In a model, reference it like:
         SELECT * FROM {{ source('raw', 'orders') }}.
       - This ensures DBT knows the raw data source.

  5. TESTS
     - DBT allows data quality tests on models and sources.
     - Helps catch issues early.
     - Example:
       - File: models/schema.yml
         models:
           - name: stg_orders
             columns:
               - name: order_id
                 tests:
                   - unique
                   - not_null
       - Run `dbt test`.
       - DBT will check for duplicate or missing order IDs.

  6. MACROS
     - Macros are reusable SQL functions in DBT (like Python functions).
     - Avoids repeating code.
     - Example:
       - File: macros/get_order_status.sql
         {% macro get_order_status(price) %}
         CASE 
           WHEN {{ price }} > 100 THEN 'VIP'
           ELSE 'Regular'
         END
         {% endmacro %}
       - Use it in a model:
         SELECT order_id, total_price, {{ get_order_status('total_price') }} AS order_status FROM stg_orders.


</details>


1. **The `FROM` clause**

    - **Sources**: We'll be taking in data from `sources`, which is the data we've loaded into out DWH. We define these sources in a YAML file and specify where to find the source, allowing us to define the data location only once. After that, we can reference all tables within that location using the definition.

        ![alt text](./images/ae21.jpg)

    This approach abstracts the complexity of where the source is physically stored, as we only define it once. When referencing it in the project, we use the source() function, providing the source name and the table name. DBT then compiles this reference into the appropriate database and schema location defined in the YAML file.

    - **Seeds**: The second source of data we select from is seeds. Seeds are CSV files stored within our repository. When running dbt run on a seed, DBT executes an operation similar to a `COPY INTO` command in SQL.

    The advantage of using seeds in DBT is that they are version-controlled and stored in the same repository as the rest of the DBT project. This ensures:

        - Consistency and centralization of all project files.
        - Integration with version control for better collaboration.
        - Documentation and testing capabilities for the seed data.
        - Seeds are ideal for data that does not change frequently. For example, we can use a seed for a master data table, like   taxi_zone_lookup, which is relatively small and benefits from version control.

    - **Refs**: `ref()` is used to reference other models in DBT.

    This approach allows us to run the same code in any environment. For instance, when working locally, the model may go to a development schema like my_name_schema. In production, the same code will automatically point to a production schema. DBT abstracts the complexity of environment-specific configurations, enabling seamless execution across different environments.

    Another benefit of using ref() is that it automatically builds dependencies between models. For example, if a new DBT model depends on the `stg_green_tripdata` model, DBT recognizes this relationship. This ensures that models are executed in the correct order during development and deployment, simplifying the process significantly.

    ![alt text](./images/ae23.png)

    ![alt text](./images/ae24.jpg)

2. **`Marcos`**

    - Macros are conditional and flow control strcutures in SQL, like `for loops` or `case/if` statements. 
    - Use `env variables` in your project for prod deployments.
    - Written using `jinja`, a templating language with the {{}}. 
    - Operate on the results of one query to generate another query.
    - Abstract snippets of SQL into reusable macros.

    dbt already includes a series of macros like config(), source() and ref(), but custom macros can also be defined.

    Unlike functions in Python, the input and output of a macro result in dynamically generated SQL code. Macros are very useful for simplifying repetitive code, adhering to the DRY (Don't Repeat Yourself) principle, and enabling dynamic code generation. For example, you can use loops within a macro to generate complex SQL constructs like case statements.

    Let’s create a macro called get_payment_type_description. It will take a parameter, such as payment_type, and generate a SQL case statement. The syntax for defining macros is similar to Python functions:

    - Use macro to define the macro.
    - Provide the macro's name.
    - Specify its parameters.
    - Include the SQL code to be dynamically generated
    Macros are defined in separate .sql files which are typically stored in a macros directory.

    <details>
    <summary>Jinja Delims</summary>

    There are 3 kinds of Jinja delimiters:

    1. {% ... %} for statements (control blocks, macro definitions)
    2. {{ ... }} for expressions (literals, math, comparisons, logic, macro calls...)
    3. {# ... #} for comments.

    </details>

    Here’s an example of `get_payment_type_description.sql` macro:

    {#
        This macro returns the description of the payment_type 
    #}

    {% macro get_payment_type_description(payment_type) -%}

        case {{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }}  
            when 1 then 'Credit card'
            when 2 then 'Cash'
            when 3 then 'No charge'
            when 4 then 'Dispute'
            when 5 then 'Unknown'
            when 6 then 'Voided trip'
            else 'EMPTY'
        end

    {%- endmacro %}

    This macro is designed to return the description of a given payment_type in a SQL context. It uses a CASE statement to map integer values of payment_type to their corresponding descriptions.

    The macro uses dbt.safe_cast to ensure payment_type is safely converted to an integer (or a compatible type). This is useful for ensuring type compatibility in SQL.

    api.Column.translate_type("integer") helps translate the type definition for the database being used.

    The macro outputs the resulting SQL CASE statement, which can then be embedded in a query to dynamically resolve the description of the payment type.

    Example Usage:


    ![alt text](./images/ae25.jpg)


    We can observe the macro in the stg_green_tripdata.sql file, line 42:

    {{ get_payment_type_description("payment_type") }} as payment_type_description
    The output of the macro is included in the query as a new column named payment_type_description. For instance:


    ![alt text](./images/ae26.jpg)


    When compiled, DBT will replace the macro call with the actual SQL case statement. This approach saves time and effort when dealing with large-scale projects.

    Macros can also be reused across projects by creating packages. A DBT package is similar to a library in other programming languages. It can contain models, macros, and other reusable components. By adding a package to your project, you can leverage its functionality anywhere in your codebase.

    For example, if you find yourself frequently using a macro like get_payment_type_description across multiple projects, you can bundle it into a package and include it in your DBT projects using the packages.yml file.

3. **`Packages`**

    Macros can be exported to packages, similarly to how classes and functions can be exported to libraries in other languages. Packages contain standalone dbt projects with models and macros that tackle a specific problem area.

    When you add a package to your project, the package's models and macros become part of your own project. A list of useful packages can be found in the [dbt package hub](https://hub.getdbt.com/). Adding and using a package is a two step process: 

    - To use a package, you must first create a `packages.yml` file in the root of your work directory. Here's an example:

        ```yml
        packages:
        - package: dbt-labs/dbt_utils
            version: 0.8.0
        ``` 

        After declaring your packages in the `packages.yml` file, you need to install them by running the `dbt deps` command either locally or on dbt Cloud. This will download and install the packages into your project. You can find the installed packages and their macros under the dbt_packages directory.

        ![alt text](./images/ae27.png)

    - You may access macros inside a package in a similar way to how Python access class methods:

        ```sql
        select
            {{ dbt_utils.surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
            cast(vendorid as integer) as vendorid,
            -- ...
        ```
        The `surrogate_key()` macro generates a hash of the `vendor_id` and `lpep_pickup_datetime` fields to create a unique identifier for each row (as one vendor can only pickup one customer at the pickup time specified). A good practice is to include this surrogate key at the beginning of your table, as it helps define the granularity of the data.

5. **`Variables`**

    The concept of variables in DBT is similar to variables in any programming language. A variable acts like a container where you store a value that you want to use later, and you can access it whenever needed. Variables are typically defined in two different ways: 

    - In DBT, variables can be defined at the project level *within* the dbt_project.yml file, allowing you to use them across various models or macros. For example, you might define a variable payment_type_values as a list of numbers:

    ```yml    
        vars:
        payment_type_values: [1, 2, 3, 4, 5, 6]
    ```

    This list could be used in different scenarios, such as building a CASE statement by looping through the list. Running a test to check if the actual values in the table are part of the list or dynamically setting a variable's value within a macro using the var marker.

    - Additionally, you can pass a value for a variable *during execution*. This allows you to customize behavior dynamically at runtime. To access a variable, use the var() marker.

    Here’s an example in `stg_green_tripdata`:

    ```yml
        {% if var('is_test_run', default=true) %}

        limit 100

        {% endif %}
    ```
    Run the command **dbt build --m <model.sql> --var `is_test_run: False`** and change is_test_run to `True` in order to limit the output of the `stg_green_tripdata.sql` by 100 entries only. If False, the query proceeds without the limit. The code also defines a default value for is_test_run, which is True. This means that unless specified otherwise, LIMIT 100 will always be added by default. This is a useful technique for development, as it allows you to test with smaller datasets (faster and cheaper queries) while ensuring full production data is used during deployment by setting is_test_run to False.

    This method, often referred to as a "dev limit," is highly recommended for optimizing development workflows. By default, you’ll have faster and cheaper queries during development, but the limit can easily be removed when working with the full production data.

6. **`Tests`**

    DBT tests are assumptions we make about our data. They're essentially statements that select data we don’t want to have. If the query produces results, the test fails and stops execution immediately, preventing the building of dependent models. For example, when building a project, if the query returns no results, the test passes, the data is good, and no alerts are triggered.

    These assumptions are primarily defined in YAML files like our schema.yml and are compiled into SQL code. DBT comes with four out-of-the-box tests:

    - `Unique Test` - Ensures the uniqueness of a field in the data model.
    - `Not Null Test` - Verifies that a field does not contain null values.
    - `Accepted Values Test` - Checks if a field contains only predefined valid values.
    - `Foreign Key Test` - Ensures relationships between fields in different tables are valid.

    Let's look into three cases here:

    1. For example, the "Accepted Values" test might ensure that a field like payment_type only contains values 1, 2, 3, 4, or 5. If it’s outside this `range of values`, the test will fail:

        ```yml
        - name: payment_type
            description: A numeric code signifying how the passenger paid for the trip.
            tests:
            - accepted_values:
                values: [1,2,3,4,5]
                severity: warn
        ```

        This can also be written as: 

        ```yml
        - name: Payment_type 
                    description: >
                    A numeric code signifying how the passenger paid for the trip.
                    tests: 
                    - accepted_values:
                        values: "{{ var('payment_type_values') }}"
                        severity: warn
                        quote: false 
        ```
        Where `payment_type_values` is a variable defined in the `dbt_project.yml` file, and `Quote` is a necessary tage to add for BigQuery (not Postgres), otherwise it'll fail.  

    2. Another test ensures that pickup_location has a `valid relationship` to the ref_taxi_lookup table, verifying it corresponds to a valid taxi zone:

        ```yml
        - name: Pickup_locationid
            description: locationid where the meter was engaged.
            tests:
            - relationships:
                to: ref('taxi_zone_lookup')
                field: locationid
                severity: warn
        ```

    3. Here, the trip_id must be `unique` and `not null`, as it’s the primary key:

        ```yml
        - name: tripid
            description: Primary key for this table, generated with a concatenation of vendorid+pickup_datetime
            tests:
                - unique:
                    severity: warn
                - not_null:
                    severity: warn
        ```

7. **`Documentations`**

    dbt also provides a way to generate documentation for your dbt project and render it as a website. The dbt generated docs will include the following:

    Information about the project:

    - Model code (both from the .sql files and compiled code)
    - Model dependencies
    - Sources
    - Auto generated DAGs from the ref() and source() macros
    - Descriptions from the .yml files and tests
    
    Information about the Data Warehouse:

    - Column names and data types
    - Table stats like size and rows

    dbt docs can be generated on the cloud or locally with this command:
    
    ```
        dbt docs generate
    ```
    Example:

    After running `dbt docs generate`, click on the `docs` icon here:

    ![alt text](./images/ae35.png)

    A new page/website with documentation opens up. 

    ![alt text](./images/ae34.png)


### Developing staging models

We will now create our first model.

We will begin by creating 2 new folders under our models folder:

 - `staging` will have the raw models.
 - `core` will have the models that we will expose at the end to the BI tool, stakeholders, etc.

Under the models directory, there is a folder named staging inside dbt_taxi_data which is my dbt project name. This will represent the initial layer of models responsible for cleaning the source data. 
Inside the staging folder, there is a schema.yml file for defining the sources (two tables for green and yellow trip data):

#### **schema.yml**

```yaml
version: 2

sources:
  - name: staging
    database: coral-velocity-451115-d9 
    schema: zoomcamp
  
    tables:
      - name: green_tripdata
      - name: yellow_tripdata

models:
    - name: stg_green_tripdata
    ...  
    - name: stg_yellow_tripdata
    ...
```
where `database` or `dataset` (as it's referred to in BQ), you'll find the yellow and green trip data and the `schema` is the folder under it containing the repective tables.  

In this file, we'll define the sources and we'll define the database and schema where the data resides. Next, we'll define the tables we want to use, such as green_tripdata and yellow_tripdata. Once defined, these sources can be referenced in our models. For example, we'll start by working with the green_tripdata.

One advantage of using DBT's approach is that it adheres to the DRY (Don't Repeat Yourself) principle. If we change the schema or table name in the YAML file, all dependent models will automatically update without requiring code changes in multiple places.


#### **Model 1: stg_green_tripdata.sql**

```sql
{{
    config(
        materialized='view' 
    )
}}
```
You can type __ (underscore twice) to get the jinja braces. 

```sql
with tripdata as 
(
  select *,
    row_number() over(partition by vendorid, lpep_pickup_datetime) as rn 
  from {{ source('staging','green_tripdata') }}
  where vendorid is not null 
)
```
Here, we're trying to find duplicates. We're using the same two fields as primary keys (surrogate key macro).. so if any row number or rn repeats, we're found a redundant entry. Later, in the select statement only rn=1 are selected. 
`where vendorid is not null` this check also makes sure we have only non-null values. This is all a part of data transformation or cleanup.

```sql
select
    -- identifiers
    {{ dbt_utils.generate_surrogate_key(['vendorid', 'lpep_pickup_datetime']) }} as tripid,
    {{ dbt.safe_cast("vendorid", api.Column.translate_type("integer")) }} as vendorid,
    {{ dbt.safe_cast("ratecodeid", api.Column.translate_type("integer")) }} as ratecodeid,
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,
```
Here is the surrogate key we created. If you do `dbt compile`, you'll see the line of code replaced in-line by the macro. 

```sql
    -- timestamps
    cast(lpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    store_and_fwd_flag,
    {{ dbt.safe_cast("passenger_count", api.Column.translate_type("integer")) }} as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    {{ dbt.safe_cast("trip_type", api.Column.translate_type("integer")) }} as trip_type,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(ehail_fee as numeric) as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    coalesce({{ dbt.safe_cast("payment_type", api.Column.translate_type("integer")) }},0) as payment_type,
    {{ get_payment_type_description("payment_type") }} as payment_type_description
from tripdata
where rn = 1
```
In the above block of code, we `cast` the columns into appropriate data types, rename columns to make the field names more meaningful, etc.

```sql
-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
```
These are variables. Check notes for variables [here](#modular-data-modeling). 
It's also a macro, so you can define it under macros seperately and call it here as well. 

#### **Model 2: stg_yellow_tripdata.sql**

Similarly, create another model [stg_yellow_tripdata.sql](../dbt_taxi_data/models/staging/stg_yellow_tripdata.sql) for yellow_tripdata by modifying necessary values and field names. 
 
#### **Lineage View**

![alt text](./images/ae28.png)

### Developing Core Models - Fact & Dimensions

Create a `Core` folder inside `models`. Here, we create fact and dim models, and also, upload/setup `taxi_zone_lookup.csv` in `seeds` as there's no source defined for this. 

#### **Seed: taxi_zone_lookup.csv**

- Copy `taxi_zone_lookup.csv` into the seeds directory.
- Run `dbt build --select taxi_zone_lookup.csv`. 

```
13:17:48 1 of 1 START seed file zoomcamp.taxi_zone_lookup ............................... [RUN]
13:17:54 1 of 1 OK loaded seed file zoomcamp.taxi_zone_lookup ........................... [INSERT 265 in 6.21s]
```

#### **Model 1: dim_zones.sql**

`dim_zones` is a master data table containing all the zone information where the taxis operate. These taxis move within specific zones, and we want to ensure we have accurate information about them.

Since we don’t have source data for this, we’ll use the seeds mentioned earlier. For this, we'll leverage the taxi_zone_lookup file. It’s unlikely that this data will change frequently (hence, the *seed*).

As mentioned above, we'll copy the CSV data in it's raw form (I took it from Module -1), and include it in our project under the seeds folder as `taxi_zone_lookup.csv`, and it can be downloaded directly from GitHub if needed. his master data will allow us to connect the data with the taxi_zone_lookup table for additional context. 

```sql 
{{ config(materialized='table') }}

select 
    locationid, 
    borough, 
    zone, 
    replace(service_zone,'Boro','Green') as service_zone 
from {{ ref('taxi_zone_lookup') }}
```
`Boro` is actually an inconsistency in the source. It's meant for green trips, and that's why we replace the word boro with green in ther service_zone column. 
> Note: Typing `__` auto generates the rest of the command for you, which in this case is {{ ref('') }}.  

#### **Model 2: fact_trips.sql**

This is fact table for trips (fact_trips), where we culminate the data from all sources (green and yellow trip) into a **single fact table**, *join* it with the dimensional data created in `dim_zones.sql`, and materialize it as a table. Materializing it as a table ensures better performance for analytics because we want this data to persist because of it's large size. 

```sql
{{
    config(
        materialized='table'
    )
}}

with green_tripdata as (
    select *, 
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
), 
yellow_tripdata as (
    select *, 
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
), 
trips_unioned as (
    select * from green_tripdata
    union all 
    select * from yellow_tripdata
), 
dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select trips_unioned.tripid, 
    trips_unioned.vendorid, 
    trips_unioned.service_type,
    trips_unioned.ratecodeid, 
    trips_unioned.pickup_locationid, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    trips_unioned.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    trips_unioned.pickup_datetime, 
    trips_unioned.dropoff_datetime, 
    trips_unioned.store_and_fwd_flag, 
    trips_unioned.passenger_count, 
    trips_unioned.trip_distance, 
    trips_unioned.trip_type, 
    trips_unioned.fare_amount, 
    trips_unioned.extra, 
    trips_unioned.mta_tax, 
    trips_unioned.tip_amount, 
    trips_unioned.tolls_amount, 
    trips_unioned.ehail_fee, 
    trips_unioned.improvement_surcharge, 
    trips_unioned.total_amount, 
    trips_unioned.payment_type, 
    trips_unioned.payment_type_description
from trips_unioned
inner join dim_zones as pickup_zone
on trips_unioned.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on trips_unioned.dropoff_locationid = dropoff_zone.locationid
```
We do three things here:

 - Add `service_type` `green` and `yellow` in each table as an identifier for later transformations. 
 - Disregard the data entries where the `Borough` is `Unknown`. 
 - `Inner join` on `dim_zones` twice, once for `pickup_locationid` and one for `dropoff_locationid`.

#### **Model 3: dm_monthly_zones_revenue.sql**

This is a dbt model that creates a table summarizing revenue-related metrics for trips data as a table selecting data from our previous dbt model called fact_trips. It will include monthly revenue metrics per pickup zone and service type, various fare components, trip counts, and averages, allowing us to analyse revenue trends, performance and other trip details. 

```sql 
{{ config(materialized='table') }}

with trips_data as (
    select * from {{ ref('fact_trips') }}
)
    select 
    -- Reveneue grouping 
    pickup_zone as revenue_zone,
    {{ dbt.date_trunc("month", "pickup_datetime") }} as revenue_month, 

    service_type, 

    -- Revenue calculation 
    sum(fare_amount) as revenue_monthly_fare,
    sum(extra) as revenue_monthly_extra,
    sum(mta_tax) as revenue_monthly_mta_tax,
    sum(tip_amount) as revenue_monthly_tip_amount,
    sum(tolls_amount) as revenue_monthly_tolls_amount,
    sum(ehail_fee) as revenue_monthly_ehail_fee,
    sum(improvement_surcharge) as revenue_monthly_improvement_surcharge,
    sum(total_amount) as revenue_monthly_total_amount,

    -- Additional calculations
    count(tripid) as total_monthly_trips,
    avg(passenger_count) as avg_monthly_passenger_count,
    avg(trip_distance) as avg_monthly_trip_distance

    from trips_data
    group by 1,2,3

```

#### **Lineage View** 

![alt text](./images/ae29.png)

Now, we need to specify to dbt, after it's identified the connections between the models, and the sources/seeds, to build the resulting model in a certain order. In order to do that we select, the below:

![alt text](./images/ae30.png)

The flow of execution:
    - Retrieves the source files and ensures that it's `Fresh`, looks out for `tests` (checks for null values, invalid data etc). If there are pre-defined checks/tests, it will be executed. 
    - It would then `build` the staging models for green and yellow trip data. And parallely, the taxi_zone_lookup.csv file will be seeded/built. After each model build, dbt will check if there are any tests defined for that specific model. If so, it will be built as well. 
    - After the run and executions have been correctly, it's going to execute `fact_trips`

#### Build Result

![alt text](./images/ae31.png)

```sql 
-- dbt build --select <model.sql> --vars '{'is_test_run: false}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
```

Note that we want the entirety of data available in our BQ, and not just the first 100. So, we override the macro value with `False` in the dbt run command, so the value `False` is taken into consideration when building both the staging models. 

### Testing & Documentation 

To understand the concept of **tests** and **documentation** and how they're executed, check [this](#key-concepts-and-setup-of-dbt-models).  

`codegen package` aims to make testing and documentation easier for you, one of the many capabilities of the package macros include:

**Macro:**

![alt text](./images/ae32.png)

**Result:**

![alt text](./images/ae33.png)

This gives you the `model` details and you can directly copy+paste it into to your schema to further define contraints and checks on each field of data/column as per the tests. 

### Deploying the project (dbt Cloud)

[YT Link](https://www.youtube.com/watch?v=V2m5C0n8Gro&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=39)

Now that we've deveoped, tested and documented necessary models, schemas and sources. The next step is `Deployment` where we aim to push the project to production (merge the code into the main branch). Later, we'll analyze the data in BigQuery and present the findings in Looker for the stakeholders. 

![alt text](./images/ae36.png)

involves taking all our code, opening a pull request, and merging the code into the main branch, which affects our production environment. In production, we’ll run the models, but there will be some differences. For example, during development, we often limit the data. In production, we need all the data without limits. Additionally, in a real-life production scenario, not everyone will have the same access rights. Not everyone will be able to write or read all the data. This is likely handled in a different database or schema with specific access controls.

The deployment workflow works as follows:

- `Development` is done in custom branches, with different teams or persons working on different aspects of the project in each. 

- Meanwhile, `production` continues using the `main` branch, unaffected by the development branches.

- When a development branch is ready for production, the team will open a push request, which if and when approved, will be merged into the main branch.

- Now, you can run the models in the production environment using the main branch.

- Later, as required you can set a schedule that will update the models on a specified basis. 

#### Running the project in PROD

Running the dbt project in production involves creation of a CI/CD pipeline that will be managed by the dbt `scheduler`. It has jobs running in sequence or parallely, as defined. These single job can run multiple commands, like dbt build, dbt deps etc, and maintain logs for each over time. 

To do this, we first create a `Production` environment in dbt as we've been working on a `Development` one all this while. 

1. In you dbt console, `go to Deploy > Create environment`. 
    - Specify Env name as `Production`
    - Choose `Production` as deployment type. 
    - Set the Warehouse connection to sue for this env, which in my case will be `zoomcamp_bigquery`
    - Set Deployment credentials, dataset name as `prod` (create this dataset manually in BQ - check [troubleshooting errors](#troubleshooting-errors) section.) 
    - `Save`
2. Now you can `Create jobs`. This is the Scheduler. 
    - Select the `Deploy job` from the Create job dropdown. 
    - Set the `Job settings`
    - You can add/remove commands to be executed here under `Execution Settings`. 
    - You can also select the checkbox for `Generate docs on run` and `Run source freshness`. 
    - You can configure the `Schedule` run the pipeline at specified times.  
    - There are some advanced settings as well.
    - `Save`
3. This takes you the next step where you can run the deploy job.  

![alt text](./images/ae37.png)

In BigQuery:

![alt text](./images/ae38.png)

#### What is CI/CD?

Another important feature we can implement is creating a continuous integration (CI) job. When working with pull requests, it's essential to ensure automation and quality through CI/CD practices. It's implemented via `webhooks` in Github or Gitlab

`CI (Continuous Integration)`: Regularly merging code changes into the main branch while automating builds and tests to avoid breaking production.

`CD (Continuous Deployment)`: Automating the deployment process after the changes pass tests.

Setting Up CI in dbt Cloud

Go to `Deploy > Jobs` and from the `Create Job` drop down select `Continuous Integration Job (Run on Pull requests from GIT)`. 

![alt text](./images/ae39.png)

`dbt build --select state:modified+` 

This command will check what's been modified (+) indicates children. You can also add your commands to perform tests, such as a check to ensure your models are documented. This job is triggered by pull requests and helps prevent breaking production.

On executing the job, dbt Cloud creates a schema named `dbt_cloud_PR_<PR_name>` for the pull request. This schema is automatically dropped when the pull request is closed, ensuring that production and development environments remain unaffected. You can set the environment it will compare against, in the job I'm running, it will be production. (It can also be `No deferral`)

So, say you make some changes in your files in dbt. In my case, I've edited the `dbt_project` to add the `seeds` block (later updated the headers in taxi_zone_lookup to lower case). Then, commit and create a pull request. It opens the Github repo as dbt cloud is connected to the repository. Here, you compare and `View Pull Request`. The job compares the changes to the `CI Check` production run, identifies affected models (e.g, taxi_zone_lookup), and executes tasks only for these models and their children. Once CI Check job passes, pull and merge.  

Benefits of CI Jobs in dbt Cloud:

- Automates tests and builds, reducing manual effort and errors.
- Prevents breaking production by isolating changes in a temporary schema.
- Builds confidence in the integration and deployment process.
- Streamlines collaboration within the team by ensuring consistent workflows.
- In this case, the process detected the modified fact_trips model and its children, ran the required tasks, and displayed a successful check. The fix was verified and ready for deployment, illustrating how CI jobs make the workflow efficient and reliable.

### Deploying the project locally 

[YT Link](https://www.youtube.com/watch?v=Cs9Od1pcrzM&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=40)

### Visualizing the transformed data in Looker Studio

[YT Link](https://www.youtube.com/watch?v=39nLTs74A3E&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=41)

First, set the deploy_job_1 to run the command - `dbt build --select +dm_monthly_zone_revenue.sql+ --vars '{is_test_run: false}'`

By doing this, we setup `prod` in BigQuery with the entire dataset (not just a limit of 100). Then, we'll use this prod dataset to visualize the data in looker studio.

First, create a `datasource`, and select `BigQuery`. Then choose your table. Here, we'll select `prod` > `fact_trip` and connect. 

![alt text](./images/ae41.png)

Follow the link attached above to create the report:

![alt text](./images/ae42.png)

### Visualising the data with Metabase

[YT Link](https://www.youtube.com/watch?v=BnLkrA7a6gM&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=42)

Using Open source metabase to create the BI report. Watch the video to understand how to use Metabase. 

### Important notes

1. What is the profiles.yml file in dbt Core?

    The profiles.yml file in dbt Core is a critical configuration file that stores connection details needed for dbt to communicate with a data warehouse. It plays a vital role in the dbt Core setup by providing the credentials and configurations required to execute transformations on your data. When dbt Core is run from the command line, it uses the profile name specified in the dbt_project.yml file to locate the corresponding profile in profiles.yml. Understanding the structure and purpose of connection profiles in dbt is essential for effectively managing database connections.

2. How does dbt Cloud simplify connection management compared to dbt Core?

    Dbt Cloud streamlines connection management by offering a web-based interface, eliminating the need for manually creating and managing a profiles.yml file. This makes dbt Cloud a user-friendly alternative for setting up and managing data warehouse connections. In dbt Cloud, connections are configured directly through the platform, centralizing management and enhancing security by securely storing credentials. This approach significantly reduces complexity, particularly for users unfamiliar with YAML configuration files.

3. Difference between `dbt run` and `dbt build`
    | **Command**   | **What it Does** | **When to Use** |
    |--------------|-----------------|----------------|
    | `dbt run`   | Executes models (i.e., runs `.sql` files in the `models/` directory) | When you only want to run models (without running tests or snapshots) |
    | `dbt build` | Runs models (`dbt run`), tests (`dbt test`), snapshots (`dbt snapshot`), and seeds (`dbt seed`) all together | When you want a full pipeline execution, including data validation and freshness checks |


### Troubleshooting errors

- It's not `generate_surrogate_key`, it's `surrogate_key`
- Changed credential details for the connection. In it, the dataset name was zoomcamp_dbt. Updated it to zoomcamp and restarted the IDE.   

- Get this error block on trying to deploy my dbt project. 
    ```
    12:02:26 1 of 17 ERROR creating sql view model prod.stg_green_tripdata .................. [ERROR in 1.93s]
    12:02:26 4 of 17 SKIP test accepted_values_stg_green_tripdata_Payment_type__False___var_payment_type_values_  [SKIP]
    12:02:26 2 of 17 ERROR creating sql view model prod.stg_yellow_tripdata ................. [ERROR in 2.00s]
    ```
    Solution:
    
    **Manually Create the prod Dataset in BigQuery**

    Since dbt creates datasets in the US by default, you need to manually create the prod dataset in the correct location (europe-west1):

    - Go to Google Cloud Console → BigQuery.
    - In the navigation panel, select your project.
    - Click Create Dataset.
    - Set the Dataset ID to prod.
    - Set the Location to EU or europe-west10 (match the source dataset).
    - Click Create.
    - Now, dbt will use this dataset instead of trying to create one in the wrong location.

- The above error is shown again when running the CI job. 

    Solution:

    When you are creating the pull request and running the CI, dbt is creating a new schema on BigQuery. By default that new schema will be created on ‘US’ location, if you have your dataset, schemas and tables on EU that will generate an error and the pull request will not be accepted. To change that location to EU on the connection to BigQuery from dbt we need to add the location `europe-west1` on the connection optional settings:

    `Dbt -> project -> settings -> connection BigQuery -> Optional Settings -> Location ->` **europe-west1**

- Seeding error : taxi_zone_lookup can not be seeded on trying to run CI job. 

    Solution:
    - Updated the file, copied it directly from raw in datatalks repo. 
    - Added a few more commands to the CI job - `dbt debug` and `dbt --select taxi_zone_lookup` 
    (manually updated the file in `main`, but I think step 2 is what solved the error)

    ![alt text](./images/ae40.png)


