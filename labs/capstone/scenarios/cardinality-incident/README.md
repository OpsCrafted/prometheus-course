# Cardinality Incident Lab

**Scenario:** Your production Prometheus instance is using 50 GB of memory, the data disk is
full, and the process has been crashing every few hours. On-call woke you up at 3 AM. The
application itself is healthy — only monitoring is down.

**Task:** Diagnose which metric is causing high cardinality, understand why, and apply the fix.

---

## Background

The incident data for this scenario is in [`incident-data.json`](incident-data.json). It
describes the TSDB state at the time of the crash: which metric is responsible, how many
series it produced, and the label breakdown that caused the explosion.

---

## Investigation Steps

1. **Inspect the incident data to understand the scale of the problem:**

   ```bash
   cat labs/capstone/scenarios/cardinality-incident/incident-data.json
   ```

2. **Identify the highest-cardinality metric using PromQL** (run against a live Prometheus):

   ```bash
   curl -sG http://localhost:9090/api/v1/query \
     --data-urlencode 'query=topk(10, count by (__name__)({__name__=~".+"}))' \
     | jq '.data.result[] | {metric: .metric.__name__, series: .value[1]}'
   ```

3. **Drill into the problematic metric to confirm which label is unbounded:**

   ```bash
   curl -sG http://localhost:9090/api/v1/query \
     --data-urlencode 'query=count by (user_id)(requests_total)' \
     | jq '.data.result | length'
   ```

4. **Check current TSDB memory and series count via the Prometheus API:**

   ```bash
   curl -s http://localhost:9090/api/v1/status/tsdb \
     | jq '{headStats: .data.headStats, seriesCountByMetricName: .data.seriesCountByMetricName[:5]}'
   ```

5. **Locate the instrumentation code that adds the `user_id` label and remove it:**

   ```bash
   grep -r "user_id" labs/capstone/scenarios/cardinality-incident/
   ```

   Remove `user_id` from the label list in the counter definition, redeploy, and restart
   Prometheus so it begins a fresh TSDB block without the old high-cardinality series.

6. **Verify cardinality drops after the fix** by re-running the query from step 2 and
   confirming `requests_total` no longer dominates the top-10 list.

---

## What You Learn

- High memory usage in Prometheus is almost always caused by cardinality, not data volume —
  knowing to check series count before disk usage saves hours of debugging
- A single metric with one unbounded label can produce more series than all other metrics
  combined, making the `topk` cardinality query the first tool to reach for in any OOM incident
- The fix is always at the instrumentation layer: removing or bounding the offending label,
  not tuning Prometheus storage parameters
