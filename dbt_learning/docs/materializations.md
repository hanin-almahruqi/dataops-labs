1- What is the difference between a table and a view in PostgreSQL?
    | Feature                     | Table             | View                           |
    | --------------------------- | ----------------- | ------------------------------ |
    | Stores data physically?     | Yes               | No                             |
    | Contains actual rows?       | Yes               | No                             |
    | Query execution             | Reads stored data | Runs underlying SQL every time |
    | Storage usage               | Uses disk space   | Minimal storage                |
    | Performance                 | Usually faster    | Depends on underlying query    |
    | Can insert/update directly? | Yes               | Sometimes                      |

    
    How is data stored differently?
    - a table stores rows of data
    - a view stores the SQL query definition without actual rows of data
    What happens when you query each one?
    - a table: Fast and straightforward
        1- Reads stored rows directly from disk
        2- Returns results
    - a view: 
        1- Expands the view SQL internally
        2- Executes the underlying query
        3- Returns results
        can become slow if:
        - underlying tables are huge
        - joins are complex
        - aggregations are expensive
        Because the query reruns every time.


2- When would you use a view in the STAGE layer vs a table in the DEV layer?
    The STAGE layer is usually for light cleaning, renaming columns, type casting, standardization
    These transformations are simple, fast, close to raw data
    So using a view makes sense.
    STAGE → Views: Raw data changes frequently.
    STAGE queried by data engineers, internal pipelines

    The DEV layer (facts/dimensions) usually contains joins, aggregations, business metrics, calculations
    These queries are heavier because they join multiple tables, calculate revenue metrics, aggregate customer spend
    DEV → Tables: Business metrics don’t need recalculation every query. You refresh them during scheduled dbt runs.
    DEV Queried by analysts, dashboards, BI tools, stakeholders


3- What problem does incremental materialization solve?
    Incremental materialization solves the problem of reprocessing huge amounts of data every time a dbt model runs. Instead of rebuilding an entire table from scratch, dbt only processes new or changed rows.
    Example:
    Day 1 our table contains:
    order_id
    1
    2
    3

    dbt builds: fct_order_details

    Day 2 new orders arrive:
    order_id
    4
    5

    With incremental logic, dbt:
    keeps rows 1–3
    only processes 4–5
    appends them