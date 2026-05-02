# Lesson 3: Recording Rules

**Time:** 45 minutes

## The Mistake

A dashboard with many panels often ends up running the same expensive query dozens of times. A typical example is a dashboard with 50 panels that each compute a latency percentile using `histogram_quantile`:

```yaml
# Panel 1 — p50 latency, service: api
histogram_quantile(0.50,
  sum by (le, service) (
    rate(http_request_duration_seconds_bucket{service="api"}[5m])
  )
)

# Panel 2 — p95 latency, service: api
histogram_quantile(0.95,
  sum by (le, service) (
    rate(http_request_duration_seconds_bucket{service="api"}[5m])
  )
)

# Panel 3 — p99 latency, service: api
histogram_quantile(0.99,
  sum by (le, service) (
    rate(http_request_duration_seconds_bucket{service="api"}[5m])
  )
)

# ... repeated for every service and every panel
```

Each panel runs its own independent query. When the dashboard refreshes every 15 seconds, all 50 queries execute simultaneously.

## Why It's Bad

The math is straightforward:

- **50 panels** each running a `histogram_quantile` query
- **15-second refresh interval** means 4 refreshes per minute
- **50 queries × 4 refreshes = 200 queries per minute**

`histogram_quantile` is one of the most CPU-intensive PromQL functions. It must iterate over all histogram buckets for every evaluation. At 200 queries per minute across a large dataset:

- Prometheus CPU climbs to 80% or higher.
- Query evaluation takes 3–5 seconds, so the dashboard feels sluggish.
- Other systems (alerting, recording) share the same CPU budget and slow down too.
- Adding one more dashboard panel makes everything worse.

## The Fix

Use recording rules to pre-calculate expensive queries once per interval. Dashboards then query the resulting metric — a simple label lookup — instead of recomputing from raw data.

### Step 1: Define recording rules

```yaml
groups:
  - name: latency_percentiles
    interval: 30s   # pre-calculate every 30 seconds
    rules:

      - record: job:http_request_duration_seconds:p50
        expr: |
          histogram_quantile(0.50,
            sum by (le, service) (
              rate(http_request_duration_seconds_bucket[5m])
            )
          )

      - record: job:http_request_duration_seconds:p95
        expr: |
          histogram_quantile(0.95,
            sum by (le, service) (
              rate(http_request_duration_seconds_bucket[5m])
            )
          )

      - record: job:http_request_duration_seconds:p99
        expr: |
          histogram_quantile(0.99,
            sum by (le, service) (
              rate(http_request_duration_seconds_bucket[5m])
            )
          )
```

### Step 2: Update dashboards to query the pre-calculated metric

```yaml
# Before: expensive histogram_quantile recomputed on every refresh
histogram_quantile(0.95,
  sum by (le, service) (rate(http_request_duration_seconds_bucket{service="api"}[5m]))
)

# After: instant lookup of the pre-calculated metric
job:http_request_duration_seconds:p95{service="api"}
```

The dashboard now gets an instant response because the metric already exists — Prometheus just looks up the stored value.

### Trade-off: 30-second staleness

Recording rules run on a fixed interval (30s in the example above). This means dashboard data can be up to 30 seconds old.

| | Complex query on every refresh | Recording rule |
|---|---|---|
| CPU cost | High (runs 50 × 4/min) | Low (runs 3 × 2/min) |
| Dashboard latency | 3–5 seconds | ~100 ms |
| Data freshness | Real-time | Up to 30s stale |
| Acceptable for dashboards? | Yes | Yes — 30s lag is invisible to humans |

For dashboards, 30 seconds of staleness is completely acceptable. Humans cannot perceive the difference between data that is 0 seconds old and data that is 30 seconds old on a trend chart.

Recording rules are **not** a substitute for alerting rules. Alerts should always query live data.

### Naming convention

The Prometheus community uses the pattern `level:metric:operations` for recorded metric names:

- `job:http_request_duration_seconds:p95` — aggregated at the job level, source metric, operation performed
- `instance:node_cpu_usage:rate5m` — per-instance CPU rate over 5 minutes

Consistent naming makes it easy to identify pre-calculated metrics at a glance.

## Lab: Recording Rules Lab

Hands-on practice for this lesson is in the companion lab:

```
labs/capstone/scenarios/recording-rules-lab/
```

In the lab you will:

1. Start with a slow dashboard where each panel runs a raw `histogram_quantile` query.
2. Observe Prometheus CPU usage at ~80% and dashboard load times of ~5 seconds.
3. Write recording rules to pre-calculate each query.
4. Update the dashboard to use the pre-calculated metrics.
5. Verify that Prometheus CPU drops to ~20% and dashboard load time drops to ~100ms.
