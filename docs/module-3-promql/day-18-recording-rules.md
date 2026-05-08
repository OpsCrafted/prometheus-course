# Day 18: Recording Rules

**Time:** 45 minutes | **Prerequisites:** Day 17 completed

## Learning Outcomes

- [ ] Understand why recording rules exist
- [ ] Know the naming convention for recorded metrics
- [ ] Write a recording rule that pre-aggregates an expensive query
- [ ] Replace a dashboard panel query with the recorded metric

---

## The Problem

You finish Day 17. Your Golden Signals dashboard has 4 panels. Each panel query looks like this:

```promql
histogram_quantile(0.99,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)
```

Prometheus computes this query every time a panel refreshes. With a 30-second dashboard refresh and 4 panels, that's 8 computations per minute of the same expensive aggregation over raw bucket data.

Now imagine 10 engineers have this dashboard open. 80 computations per minute. As cardinality grows, each computation gets slower. Dashboards start to lag.

**Recording rules** solve this by computing the query once on a schedule and storing the result as a new metric. Dashboard panels read the pre-computed value instead of recomputing it.

---

## The Pattern

```yaml
groups:
  - name: recordings
    interval: 30s
    rules:
      - record: job:http_requests:rate5m
        expr: sum(rate(http_requests_total[5m])) by (job)
```

This creates a new metric `job:http_requests:rate5m` that Prometheus updates every 30 seconds. Any query or dashboard panel referencing `job:http_requests:rate5m` reads the cached value — no recomputation.

**Naming convention:** `{labels}:{metric}:{function_and_window}`

- `job` — the labels being aggregated over (from the `by` clause)
- `http_requests` — the base metric name (shortened)
- `rate5m` — the function and window applied

This convention is from the [Prometheus recording rules best practices](https://prometheus.io/docs/practices/rules/). Follow it so teammates immediately understand what a recorded metric contains.

---

## Before and After

**Before (recomputed on every panel load):**

```promql
histogram_quantile(0.99,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)
```

**After (reads pre-aggregated buckets):**

```promql
histogram_quantile(0.99, job:http_request_duration_seconds_bucket:rate5m)
```

The `histogram_quantile()` step still runs at query time — that is unavoidable because quantile computation requires the full bucket distribution. But `sum(rate(...))` over raw buckets no longer runs on every panel load. You pre-compute it once.

This is the most common recording rule pattern in production Prometheus setups.

---

## What Recording Rules Are Not

Recording rules are not a substitute for fixing bad queries. If a query is expensive because of high cardinality, recording the result hides the problem — it does not fix it. Fix cardinality first (Day 8), then record if queries are legitimately expensive due to data volume.

---

## Hands-On

**Step 1:** Add a recording rules group to `labs/alert_rules.yml`:

```yaml
  - name: recordings
    interval: 30s
    rules:
      - record: job:http_requests:rate5m
        expr: sum(rate(http_requests_total[5m])) by (job)

      - record: job:http_request_duration_seconds_bucket:rate5m
        expr: sum(rate(http_request_duration_seconds_bucket[5m])) by (job, le)

      - record: job:http_error_ratio:rate5m
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) by (job)
          /
          sum(rate(http_requests_total[5m])) by (job)
```

**Step 2:** Reload Prometheus:

```bash
cd labs && docker compose exec prometheus kill -HUP 1
```

**Step 3:** Verify the recorded metric exists:

```bash
curl -s 'http://localhost:9090/api/v1/query?query=job:http_requests:rate5m' \
  | jq '.data.result | length'
```

Expected: `1` or more (one result per `job` label value).

**Step 4:** Open Prometheus UI at http://localhost:9090. Run:

```promql
job:http_requests:rate5m
```

You should see the pre-computed request rate. Compare it to the raw query:

```promql
sum(rate(http_requests_total[5m])) by (job)
```

Results should match. The recording rule is working correctly.

---

## Lab

See [lab-18-recording-rules.md](../../labs/module-3-promql/lab-18-recording-rules.md)

## Exit Criteria

- [ ] `job:http_requests:rate5m` metric appears in Prometheus UI
- [ ] `make verify-day-18` passes
- [ ] Grafana dashboard panel updated to use recorded metric
- [ ] Can explain why you record the bucket rate but not the quantile computation
