# Day 14: Histograms & Quantiles

**Time:** 90 minutes | **Prerequisites:** Days 9-13 completed

## Learning Outcomes

- [ ] Query histogram buckets
- [ ] Calculate percentiles with histogram_quantile()
- [ ] Understand bucket semantics
- [ ] Master the critical sum by(le) aggregation pattern

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

**Important:** The `le` label MUST be present in the aggregation. histogram_quantile() uses bucket boundaries to interpolate percentiles.

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

**Step 5:** p95 over 5 minutes with proper aggregation:

```
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```

Shows p95 for the service (aggregated across all instances/methods).

**Step 6:** p95 by endpoint (keeping endpoint dimension):

```
histogram_quantile(0.95, sum by (le, endpoint) (rate(http_request_duration_seconds_bucket[5m])))
```

Shows p95 per endpoint (le must always be included).

## Critical: The sum by(le) Aggregation Pattern

This is the most important concept in histogram queries.

### Why sum by(le) is Essential

When you use `rate()` on a histogram, Prometheus expands it to include ALL labels:
```
rate(http_request_duration_seconds_bucket[5m])
# Returns: {le="0.005", instance="a", method="GET"}, {le="0.01", instance="a", method="GET"}, ...
```

`histogram_quantile()` needs **only the le label** because it interpolates between bucket boundaries. If you keep other labels, you get one percentile per unique label combination (noisy and wrong).

### The Pattern

**CORRECT:** Always use `sum by (le)` before histogram_quantile:
```
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```

**WRONG:** Missing sum by(le) - will produce incorrect results:
```
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
# INCORRECT - doesn't aggregate buckets properly
```

### Keeping Other Dimensions

If you want p95 **per endpoint**, keep that label in sum:
```
histogram_quantile(0.95, sum by (le, endpoint) (rate(http_request_duration_seconds_bucket[5m])))
```

The rule: **Always include `le` in the sum, optionally add other dimensions you want to preserve.**

## Key Concepts

**Quantile range:** 0.0 to 1.0
- 0.5 = 50th percentile (median)
- 0.95 = 95th percentile
- 0.99 = 99th percentile
- 0.999 = 99.9th percentile

**Must include "le" label:** For `histogram_quantile()` to work, the `le` label must be in the result set after aggregation.

**Rate histogram:** For time ranges, always use rate with sum by(le):
```
histogram_quantile(0.95, sum by (le) (rate(metric_bucket[5m])))
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

## Common Mistakes

### Mistake 1: Forgetting sum by(le)
```
# WRONG
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```
Result: One percentile per label combination (confusing noise)

Fix: Add `sum by (le)`:
```
# CORRECT
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```

### Mistake 2: Using by() instead of sum by()
```
# UNCLEAR (might not work as expected)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]) by (le, instance))
```

Fix: Use `sum by()`:
```
# CORRECT
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```

### Mistake 3: Forgetting rate() entirely
```
# Static snapshot (old data)
histogram_quantile(0.95, sum by (le) (http_request_duration_seconds_bucket))
```

Fix: Add `rate()` for current window:
```
# CORRECT
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```

## Lab

See [lab-14-histograms.md](../../labs/module-3-promql/lab-14-histograms.md)

## Exit Criteria

- [ ] Understand histogram buckets
- [ ] Know how to calculate percentiles
- [ ] Can query p50, p95, p99 with correct sum by(le)
- [ ] Understand why sum by(le) is critical for aggregation
- [ ] Know how to keep additional dimensions (endpoint, method, etc)
