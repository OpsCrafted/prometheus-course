# Metric Types Reference Guide

## Gauge

Measures a current value that can go up or down.

Use case: temperature, memory, disk space, connections, queue length

Example: `node_memory_MemFree_bytes`

Characteristics:
- Can increase or decrease
- Represents a snapshot in time
- No `_total` suffix

Operations:
- Set: `gauge.Set(value)`
- Increment/Decrement: `gauge.Inc()`, `gauge.Dec()`

Queries:
- Direct: `memory_bytes`
- Aggregation: `sum(memory_bytes)`, `avg(memory_bytes)`

## Counter

Cumulative total that only increases (or resets on restart).

Use case: total requests, total errors, bytes sent/received

Example: `http_requests_total`

Characteristics:
- Always increases (monotonic)
- Resets on application restart
- Always has `_total` suffix

Operations:
- Increment: `counter.Inc()`
- Add: `counter.Add(value)`

Queries:
- Rate: `rate(requests_total[5m])` (req/sec)
- Increase: `increase(requests_total[5m])` (total in window)
- Never query directly (always use rate/increase)

## Histogram

Distribution of observations in buckets.

Use case: request latency, response size, percentiles

Example: `http_request_duration_seconds`

Characteristics:
- Creates multiple time-series (_bucket, _sum, _count)
- Allows percentile calculation
- Bucket boundaries defined at creation

Operations:
- Observe: `histogram.Observe(value)`

Time-series created:
- `{metric}_bucket{le="value"}` — Count in bucket
- `{metric}_sum` — Sum of all observations
- `{metric}_count` — Count of observations

Queries:
- Quantile: `histogram_quantile(0.95, metric_bucket)`
- Average: `metric_sum / metric_count`
- Rate: `rate(metric_bucket[5m])`

Buckets:
- Standard: 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10 (seconds)
- Custom: Define when creating metric

## Summary

Pre-computed quantiles (rarely used).

Use case: Client-side quantile calculation (rare)

Characteristics:
- Similar to histogram but pre-computed
- Less useful than histogram
- Don't use unless specific reason

Queries:
- Quantiles available directly from `_quantile` label

## Decision Tree

```
Does value go up and down? → GAUGE
Does value only increase? → COUNTER
Need distribution/percentiles? → HISTOGRAM
```

## Naming Conventions

Pattern: `{subsystem}_{feature}_{unit}`

Examples:
- `http_requests_total` (subsystem: http, feature: requests, unit: total/count)
- `database_query_duration_milliseconds`
- `cache_hit_ratio`
- `memory_usage_bytes`

Unit suffixes:
- `_total` for counters
- `_seconds` for time
- `_bytes` for size
- `_percent` for percentages
- `_ratio` for ratios

## Label Cardinality

Keep label values low-cardinality:
- `method` (GET, POST, PUT, DELETE) = 4 values ✓
- `status` (200, 400, 500, etc.) = ~10 values ✓
- `user_id` (any integer) = millions ✗
- `request_id` (unique per request) = unbounded ✗

Rule: Each label should have < 100 unique values typically.

Total series = label1_values × label2_values × label3_values

Example with low cardinality (good):
- method (4) × status (10) × path (5) = 200 series ✓

Example with high cardinality (bad):
- method (4) × status (10) × user_id (1M) = 40M series ✗
