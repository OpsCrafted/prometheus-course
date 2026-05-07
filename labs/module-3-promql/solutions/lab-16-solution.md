# Lab 16 Solution: PromQL Capstone

## Challenge 1: Health Check

**Targets DOWN:**
```
up == 0
```
Returns: Series with up=0

**Count UP targets:**
```
count(up == 1)
```
Returns: 6 (one per scrape job)

**DOWN targets:**
```
count(up) - count(up == 1)
```
Returns: 0 (ideally)

## Challenge 2: Request Rate Analysis

**Total req/sec:**
```
sum(rate(http_requests_total[5m]))
Result: 0.02 req/sec
```

**By path:**
```
sum(rate(http_requests_total[5m])) by (endpoint)
Result: {endpoint="/"} 0.02
```

**Success rate:**
```
rate(http_requests_total{status="200"}[5m]) /
rate(http_requests_total[5m])
Result: 1.0 (100% successful)
```

**Error rate:**
```
rate(http_requests_total{status=~"5.."}[5m]) /
rate(http_requests_total[5m])
Result: 0 (no errors)
```

## Challenge 3: SLA Monitoring

**p99 latency:**
```
histogram_quantile(0.99, http_request_duration_seconds_bucket)
Result: 0.095 (95ms)
```

**SLO met (p99 ≤ 100ms):**
```
histogram_quantile(0.99, http_request_duration_seconds_bucket) <= 0.1
Result: 1 (true, SLO met)
```

## Challenge 4: Capacity Planning

**Current rate:**
```
rate(http_requests_total[5m])
Result: 0.02 req/sec
```

**1 week ago:**
```
rate(http_requests_total[5m] offset 7d)
Result: (varies, no data if app new)
```

**Growth rate:**
```
(rate(http_requests_total[5m]) /
 (rate(http_requests_total[5m] offset 7d) + 0.001)) - 1
Result: 1000+ (if no history)
```

## Challenge 5: Multi-metric

**Avg latency:**
```
http_request_duration_seconds_sum /
http_request_duration_seconds_count
Result: 0.05 (50ms)
```

**Req/sec:**
```
rate(http_requests_total[5m])
Result: 0.02
```

**Req/sec per latency unit:**
```
rate(http_requests_total[5m]) /
((http_request_duration_seconds_sum /
  http_request_duration_seconds_count) + 0.001)
Result: 0.4 (0.02 req/sec / 0.05 sec/req)
```

## Key Patterns

- Always use `rate()` for counter analysis
- Divide to create percentages: metric1 / metric2
- Use `offset` for historical comparison
- `histogram_quantile()` for SLA checks
- Combine operators for complex analysis
