# Airflow Overview

A short primer answering the four core Airflow questions for Week 6.

## 1. What is a DAG?

A **DAG** (Directed Acyclic Graph) is how Airflow represents a workflow. It is a
collection of **tasks** wired together with **dependencies** that flow in one
direction and never loop back on themselves ("acyclic"). The DAG defines *what*
runs, *in what order*, and *on what schedule* — but each individual unit of work
lives in a **task**.

In our project the `dbt_pipeline` DAG chains six tasks:

```
dbt_seed → dbt_test_sources → dbt_run_stage → dbt_test_stage → dbt_run_dev → dbt_test_dev
```

The arrows are the dependencies: `dbt_run_stage` will not start until
`dbt_test_sources` has succeeded, which guarantees the raw data is loaded and
sanity-checked before we build the staging layer.

## 2. BashOperator vs PythonOperator

An **operator** is a template for a single task. The two most common are:

| Operator | Runs | Use it when… |
| --- | --- | --- |
| `BashOperator` | A shell command (a string) | You want to invoke an external CLI — `dbt run`, a shell script, `aws s3 cp`, etc. The task succeeds if the command exits with code `0`. |
| `PythonOperator` | A Python callable you pass in | The logic is Python — calling an API, transforming a dataframe, branching on a condition. You get the full Airflow context as keyword arguments. |

In this pipeline every task is a `BashOperator` because the actual work is done
by the `dbt` command-line tool. If we needed to, say, post a custom Slack message
or compute something in Python, we would reach for a `PythonOperator`.

## 3. What does `schedule_interval` control?

`schedule_interval` (called `schedule` in newer Airflow) controls **how often the
DAG runs automatically**. It accepts a cron expression (`"0 6 * * *"`), a preset
(`"@daily"`, `"@hourly"`), or a `timedelta`.

Our DAG uses `"0 6 * * *"` — **every day at 06:00 UTC**. Airflow evaluates cron
schedules in **UTC** by default, so 06:00 here is 06:00 UTC regardless of the
machine's local time zone.

Two related settings matter:
- **`start_date`** — the date from which scheduling begins.
- **`catchup`** — when `False`, Airflow does **not** retroactively run every
  missed interval between `start_date` and now; it only schedules from the
  present forward. We set `catchup=False` so turning the DAG on doesn't trigger a
  flood of historical runs.

## 4. What is a sensor, and when would you use one?

A **sensor** is a special operator that **waits for a condition to become true**
before allowing downstream tasks to proceed. It polls (or, in "deferrable" mode,
waits asynchronously) until the thing it's watching exists — then it succeeds.

Common examples:
- `FileSensor` — wait until a file lands in a directory.
- `ExternalTaskSensor` — wait until a task in *another* DAG finishes.
- `SqlSensor` — wait until a SQL query returns a row.

You use a sensor when your pipeline **depends on something external that arrives
on its own schedule**. For instance, if an upstream team dropped a daily CSV into
a folder, we'd put a `FileSensor` *before* `dbt_seed` so the pipeline waits for the
file instead of failing when it isn't there yet.
