# Pipeline Retrospective

Reflections after building the dbt + Airflow pipeline in Week 6.

## 1. What would you change about the pipeline if this were production?

- **Don't run `dbt seed` every day.** Seeds are static reference CSVs; reloading
  them on every run is wasteful and, in real life, raw data would arrive via an
  ingestion/EL tool (Fivetran, Airbyte, a custom extract) rather than committed
  CSVs. In production the first task would *land new raw data*, not re-seed.
- **Use `dbt build` or finer selection instead of separate run/test tasks.**
  `dbt build` runs and tests each model in dependency order and stops at the first
  failure, giving tighter feedback than the coarse "run all stage, then test all
  stage" split we use for teaching clarity.
- **Externalize secrets.** The database password lives in `.env` with a default
  baked into compose. Production would use an Airflow Connection / secrets backend
  (Vault, AWS Secrets Manager) and the Fernet key would be generated per
  environment, never committed.
- **Pin and isolate environments.** Build the dbt project against pinned package
  versions (`packages.yml` + a lockfile) and promote through dev → staging → prod
  targets rather than always running `--target dev`.
- **Make failures block, not warn.** `dbt test --select "source:*"` is a no-op
  today; in production sources would have real freshness and quality tests, and a
  failing source test should halt the run before bad data propagates downstream.

## 2. What additional monitoring would you add?

- **Real alerting**, not just a log file. Wire `on_failure_callback` (and an
  `sla_miss_callback`) to Slack/PagerDuty/email so a human is paged on failure.
- **SLAs** on each task so a run that's merely *slow* (not failed) also alerts.
- **dbt artifacts → observability.** Ship `run_results.json` and `manifest.json`
  to a warehouse table or a tool like Elementary / Monte Carlo to track test pass
  rates, model run times, and freshness trends over time.
- **Data-volume checks.** Row-count anomaly detection (e.g., today's orders are
  10× yesterday's, or zero rows loaded) catches silent upstream breakages that
  schema tests miss.
- **Dashboards on the Airflow metadata DB** (task duration, retry counts, success
  rate) to spot flaky or degrading tasks before they page anyone.

## 3. What was the hardest part of the entire 6-week program?

*(Replace this with your own honest reflection.)* A strong answer names a specific
concept and what finally made it click — for example: getting the **incremental
model** (Week 2) right, because reasoning about what `is_incremental()` does on the
first run vs. subsequent runs, and why the look-back window matters, was less
intuitive than the straightforward `view`/`table` materializations. Wiring dbt into
**Airflow** (Week 6) was also non-obvious: realizing the Airflow worker needs dbt
*installed where the task executes* (not just running in a separate container) was
the key insight that made the `BashOperator` approach work.
