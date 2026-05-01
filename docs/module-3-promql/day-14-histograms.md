# Day 14: Histograms & Quantiles

**Time:** 90 minutes | **Prerequisites:** Days 9-13 completed

## Learning Outcomes

- [ ] Query histogram buckets
- [ ] Calculate percentiles with histogram_quantile()
- [ ] Understand bucket semantics

## Conceptual Explainer

### Histogram Buckets

Histograms store observations in buckets:

```
http_request_duration_seconds_bucket{le="0.005"}  100
http_request_duration_seconds_bucket{le="0.01"}   250
http_request_duration_seconds_bucket{le="0.025"}  500
http_request_duration_seconds_bucket{le="0.05"}   800
http_request_duration_seconds_bucket{le="0.1"}    950
http_request_duration_seconds_bucket{le="+Inf"}   1000
```

**Reading:** 100 requests ≤ 5ms, 250 ≤ 10ms, etc.

### Quantiles (Percentiles)

- p50 (median): 50% of values
- p95: 95% of values below
- p99: 99% of values below

### histogram_quantile()

```
histogram_quantile(0.95, http_request_duration_seconds_bucket)
```

Result: 95th percentile (p95)

The 0.95 means "95th percentile" (range: 0.0 to 1.0)

### Computing Percentiles

Example from buckets above:
- p50: ~12ms (50% of 1000 = 500)
- p95: ~45ms (95% of 1000 = 950)
- p99: ~100ms (99% of 1000 = 990)

## Hands-On: Query Histograms

**Step 1:** View raw buckets:

```
http_request_duration_seconds_bucket
```

Shows all buckets.

**Step 2:** Calculate p50 (median):

```
histogram_quantile(0.50, http_request_duration_seconds_bucket)
```

Shows median latency.

**Step 3:** Calculate p95:

```
histogram_quantile(0.95, http_request_duration_seconds_bucket)
```

Shows 95th percentile latency.

**Step 4:** Calculate p99:

```
histogram_quantile(0.99, http_request_duration_seconds_bucket)
```

Shows 99th percentile latency.

**Step 5:** p95 by method:

```
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, method))
```

Shows p95 per HTTP method.

## Key Concepts

**Quantile range:** 0.0 to 1.0
- 0.5 = 50th percentile (median)
- 0.95 = 95th percentile
- 0.99 = 99th percentile
- 0.999 = 99.9th percentile

**Must include "le" label:** For `histogram_quantile()` to work, the `le` label must be in the result.

**Rate histogram:** For time ranges, use rate:
```
histogram_quantile(0.95, rate(metric_bucket[5m]))
```

## Reference

**Histogram Buckets:**
- `_bucket{le="value"}` — Bucket count
- `_sum` — Total sum
- `_count` — Total count

**Common percentiles:**
```
histogram_quantile(0.50, metric)  # p50 (median)
histogram_quantile(0.95, metric)  # p95
histogram_quantile(0.99, metric)  # p99
histogram_quantile(0.999, metric) # p99.9
```

## Lab

See [lab-14-histograms.md](../../labs/module-3-promql/lab-14-histograms.md)

## Exit Criteria

- [ ] Understand histogram buckets
- [ ] Know how to calculate percentiles
- [ ] Can query p50, p95, p99
- [ ] Understand aggregation with histograms
