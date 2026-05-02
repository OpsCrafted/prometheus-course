# Recording Rules Lab

**Scenario:** A Grafana dashboard with 20 panels is slow to load. Every panel runs a `histogram_quantile` query directly against Prometheus. The dashboard refresh interval is 15 seconds. Prometheus CPU is sitting at 80%, and each dashboard load takes 5 seconds. Engineers have stopped opening the dashboard because it is too slow to be useful.

**Task:** Convert the slow dashboard queries to recording rules so the pre-calculated metrics are available for instant lookup.

---

## Current Slow Queries

Each panel in the dashboard runs one of these queries independently. Notice that the inner `rate(...)` expression is identical across all three — Prometheus recomputes it from scratch for every panel on every refresh.

```promql
# Panel: p50 request latency by service
histogram_quantile(0.50,
  sum by (le, service) (
    rate(http_request_duration_seconds_bucket[5m])
  )
)
```

```promql
# Panel: p95 request latency by service
histogram_quantile(0.95,
  sum by (le, service) (
    rate(http_request_duration_seconds_bucket[5m])
  )
)
```

```promql
# Panel: p99 request latency by service
histogram_quantile(0.99,
  sum by (le, service) (
    rate(http_request_duration_seconds_bucket[5m])
  )
)
```

With 20 panels and a 15-second refresh, Prometheus evaluates ~80 queries per minute. Each `histogram_quantile` call iterates over every histogram bucket for every service. At this scale, query evaluation alone consumes 80% of Prometheus CPU.

---

## Solution

Define recording rules that pre-calculate each percentile once every 30 seconds. Dashboards then replace each expensive query with a simple metric lookup.

### Recording rules configuration

```yaml
groups:
  - name: latency_percentiles
    interval: 30s
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

Save this file as `rules/latency-percentiles.yml` and add it to `prometheus.yml`:

```yaml
rule_files:
  - "rules/latency-percentiles.yml"
```

### Updated dashboard queries

Replace each panel's query with a lookup of the pre-calculated metric:

```promql
# Panel: p50 request latency by service (was: full histogram_quantile expression)
job:http_request_duration_seconds:p50{service="api"}
```

```promql
# Panel: p95 request latency by service
job:http_request_duration_seconds:p95{service="api"}
```

```promql
# Panel: p99 request latency by service
job:http_request_duration_seconds:p99{service="api"}
```

Prometheus evaluates the recording rules 2 times per minute (every 30 seconds) regardless of how many dashboards or panels query the result. The dashboards now read a stored time series — no computation required at query time.

---

## Verification

After applying the recording rules and updating the dashboard:

| Metric | Before | After |
|---|---|---|
| Prometheus CPU | ~80% | ~20% |
| Dashboard load time | ~5 seconds | ~100 ms |
| Queries per minute | ~80 | ~6 (3 rules × 2/min) |
| Data freshness | Real-time | Up to 30s stale |

Reload Prometheus to pick up the new rules:

```bash
curl -X POST http://localhost:9090/-/reload
```

Confirm the recorded metrics are being written:

```bash
curl -s 'http://localhost:9090/api/v1/query?query=job:http_request_duration_seconds:p95' \
  | jq '.data.result[0].value'
```

You should see a numeric latency value returned immediately with no computation delay.

### Is 30-second staleness acceptable?

Yes. Dashboard trend charts display minutes or hours of history. A 30-second lag is invisible on any chart with a time range longer than a few minutes. Recording rules are not appropriate for alert rules — alerts must always evaluate live data — but for dashboards the trade-off is unambiguously correct.
