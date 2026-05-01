# Lab 14 Solution: Histograms & Quantiles

## Query Results (example app)

**Query 1:** View buckets
```
http_request_duration_seconds_bucket{le="0.005"}  10
http_request_duration_seconds_bucket{le="0.01"}   25
http_request_duration_seconds_bucket{le="0.025"}  50
http_request_duration_seconds_bucket{le="0.05"}   80
http_request_duration_seconds_bucket{le="0.1"}    95
http_request_duration_seconds_bucket{le="+Inf"}   100
```

**Query 2:** p50 (median)
```
histogram_quantile(0.50, http_request_duration_seconds_bucket)
Result: 0.020  (20ms)
```

**Query 3:** p95
```
histogram_quantile(0.95, http_request_duration_seconds_bucket)
Result: 0.060  (60ms)
```

**Query 4:** p99
```
histogram_quantile(0.99, http_request_duration_seconds_bucket)
Result: 0.095  (95ms)
```

**Query 5:** p95 by method (example)
```
{method="GET"}   0.060
{method="POST"}  0.080
```

**Query 6:** p99 over 5 minutes
```
Result: 0.085  (more stable than raw query)
```

## Understanding Quantiles

- p50 = 50% of requests faster than this
- p95 = 95% of requests faster than this
- p99 = 99% of requests faster than this

Example: If p95=60ms, then 95% of requests completed in 60ms or less.
