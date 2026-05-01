# PromQL Cheatsheet

## Instant Vectors (Current Value)

```
metric_name                    # All series
metric_name{label="value"}     # Filter by label
metric_name{label=~"regex"}    # Regex filter
metric_name{label!="value"}    # Not equal
```

## Range Vectors (Time Window)

```
metric_name[5m]                # Last 5 minutes
metric_name[1h]                # Last 1 hour
metric_name[1d]                # Last 1 day
```

## Aggregation Operators

```
sum(metric)                    # Sum all values
avg(metric)                    # Average
max(metric)                    # Maximum
min(metric)                    # Minimum
count(metric)                  # Count of series
stddev(metric)                 # Standard deviation
```

### Grouping

```
sum(metric) by (label)         # Group by label
sum(metric) without (label)    # Group excluding label
sum(metric) by (l1, l2)        # Multiple labels
```

## Rate & Increase (For Counters)

```
rate(counter[5m])              # Per-second rate
increase(counter[5m])          # Total increase
```

Use `rate()` for monitoring, `increase()` for totals.

## Binary Operators

```
metric1 + metric2              # Addition
metric1 - metric2              # Subtraction
metric1 * metric2              # Multiplication
metric1 / metric2              # Division
```

## Comparison Operators

```
metric > 100                   # Greater than
metric < 50                    # Less than
metric == 1                    # Equal
metric != 0                    # Not equal
```

Returns: Series matching condition (empty if none match)

## Functions

```
round(metric)                  # Round to integer
ceil(metric)                   # Round up
floor(metric)                  # Round down
abs(metric)                    # Absolute value
log(metric)                    # Natural log
log2(metric)                   # Base-2 log
log10(metric)                  # Base-10 log
```

### Time Shifts

```
metric offset 1h               # Value from 1 hour ago
metric offset 5m               # Value from 5 minutes ago
rate(metric[5m]) offset 1d     # Rate from 1 day ago
```

## Histogram Quantiles

```
histogram_quantile(0.5, metric_bucket)   # p50 (median)
histogram_quantile(0.95, metric_bucket)  # p95
histogram_quantile(0.99, metric_bucket)  # p99
```

Quantile range: 0.0 to 1.0

## Complex Queries

Success rate:
```
rate(requests_total{status="200"}[5m]) /
rate(requests_total[5m])
```

Error rate:
```
rate(requests_total{status=~"5.."}[5m]) /
rate(requests_total[5m])
```

Growth rate (% change):
```
(rate(metric[5m]) / (rate(metric[5m] offset 1h) + 0.001)) - 1
```

Average latency:
```
http_request_duration_seconds_sum /
http_request_duration_seconds_count
```

p95 latency by method:
```
histogram_quantile(0.95,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le, method))
```

## Label Matchers

```
=     Exact match
!=    Not equal
=~    Regex match
!~    Regex not match
```

Regex examples:
```
method=~"GET|POST"            # GET or POST
status=~"2.."                 # 2XX (200-299)
job=~"app-.+"                 # app-* (app-1, app-2, ...)
```

## Empty Results Debugging

If query returns empty:
- Metric doesn't exist (check Targets tab)
- Label filter is too strict
- Time range has no data
- Check metric name spelling

## Time Units

```
s     seconds
m     minutes
h     hours
d     days
w     weeks
y     years
```

Examples: `5m`, `1h`, `7d`, `30m`

## PromQL Best Practices

1. Always use `rate()` for counters in time-series
2. Filter early: `metric{job="app"}` not `metric` then filter
3. Use specific labels to reduce cardinality
4. Longer time windows for smoother rates
5. Test queries incrementally
6. Document complex queries
