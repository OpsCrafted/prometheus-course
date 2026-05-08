# Lab 18 Solution: Recording Rules

## Exercise 1: alert_rules.yml addition

Add to `labs/alert_rules.yml` (complete file should end with this group):

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

## Exercise 2: Verification

```bash
# 3 recording rules loaded
curl -s http://localhost:9090/api/v1/rules \
  | jq '[.data.groups[].rules[] | select(.type == "recording")] | length'
# → 3

# Recorded metric exists
curl -s 'http://localhost:9090/api/v1/query?query=job:http_requests:rate5m' \
  | jq '.data.result | length'
# → 1 (one result for job="sample-app")

make verify-day-18
# → all checks pass
```

## Exercise 3: Traffic panel query

```promql
sum(job:http_requests:rate5m)
```

Graph is identical to the raw query. Values match because the recording rule evaluates the same expression on the same data — just pre-computed on a 30s schedule instead of at query time.

## Exercise 4: P99 Latency panel and the histogram_quantile question

**Answer:** `histogram_quantile()` must run at query time because it needs the full bucket distribution to compute the percentile. You cannot pre-compute the quantile itself — the result depends on how the buckets are distributed across the `le` labels.

What you *can* pre-compute is the expensive inner part: `sum(rate(...bucket[5m])) by (le)`. The recording rule stores this. The panel then applies `histogram_quantile()` to the already-aggregated data, which is fast because the heavy lifting (iterating over raw samples) is already done.

Updated query:

```promql
histogram_quantile(0.99, sum(job:http_request_duration_seconds_bucket:rate5m) by (le))
```

The `sum() by (le)` wrapper is still needed to re-aggregate across jobs if the recording rule includes `job` in its `by` clause.

## Reference

Canonical recording rule templates: [`labs/templates/recording_rules.yml`](../../templates/recording_rules.yml)
