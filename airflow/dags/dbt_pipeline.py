"""
dbt_pipeline — Week 6 reference DAG
===================================
Orchestrates the full dbt pipeline once per day:

    dbt_seed
      -> dbt_test_sources
      -> dbt_run_stage
      -> dbt_test_stage
      -> dbt_run_dev
      -> dbt_test_dev

Each task is a BashOperator that runs `dbt` directly. dbt is installed in
the Airflow image (see Dockerfile.airflow) and the dbt project is mounted at
/opt/airflow/dbt (see docker-compose.yml), so no Docker-in-Docker is needed.
dbt connects to the `postgres` service using the POSTGRES_* env vars that
docker-compose injects from .env into profiles.yml.
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

# Path where docker-compose mounts ./dbt_learning inside the Airflow containers.
DBT_DIR = "/opt/airflow/dbt"

# Where the on_failure_callback records failures (the ./airflow/logs volume).
FAILURE_LOG = "/opt/airflow/logs/dbt_pipeline_failures.log"


def notify_failure(context):
    """on_failure_callback — append failure details to a log file.

    Demonstrates reading the Airflow task context. In production you would
    swap the file write for a Slack webhook, PagerDuty event, or email.
    """
    ti = context["task_instance"]
    lines = [
        "──────────────────────────────────────────────",
        f"DAG       : {ti.dag_id}",
        f"Task      : {ti.task_id}",
        f"Try       : {ti.try_number}",
        f"When      : {context.get('logical_date') or context.get('execution_date')}",
        f"Exception : {context.get('exception')}",
        f"Log URL   : {ti.log_url}",
        "",
    ]
    # Best-effort write — never let the callback itself raise.
    try:
        with open(FAILURE_LOG, "a", encoding="utf-8") as fh:
            fh.write("\n".join(lines))
    except OSError:
        pass


default_args = {
    "owner": "student_name",          # ← replace with your name
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "on_failure_callback": notify_failure,
}


def dbt_task(dag, task_id, dbt_command):
    """Build a BashOperator that cd's into the project and runs a dbt command."""
    return BashOperator(
        task_id=task_id,
        bash_command=f"cd {DBT_DIR} && dbt {dbt_command} --profiles-dir . --target dev",
        dag=dag,
    )


with DAG(
    dag_id="dbt_pipeline",
    description="Daily dbt pipeline: seed -> test sources -> stage -> dev",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule="0 6 * * *",             # daily at 06:00 UTC (Airflow cron is UTC)
    catchup=False,
    tags=["dbt", "dataops"],
) as dag:

    dbt_seed = dbt_task(dag, "dbt_seed", "seed")
    dbt_test_sources = dbt_task(dag, "dbt_test_sources", 'test --select "source:*"')
    dbt_run_stage = dbt_task(dag, "dbt_run_stage", "run --select stage")
    dbt_test_stage = dbt_task(dag, "dbt_test_stage", "test --select stage")
    dbt_run_dev = dbt_task(dag, "dbt_run_dev", "run --select dev")
    dbt_test_dev = dbt_task(dag, "dbt_test_dev", "test --select dev")

    # Linear dependency chain.
    (
        dbt_seed
        >> dbt_test_sources
        >> dbt_run_stage
        >> dbt_test_stage
        >> dbt_run_dev
        >> dbt_test_dev
    )
