# Lab 12 Solution: Joins & Binary Operators

## Query Results

**Query 1:** Average latency
```
http_request_duration_seconds_sum / http_request_duration_seconds_count
Result: 0.05  (50 milliseconds)
```

**Query 2:** Success percentage
```
sum(rate(http_requests_total{status="200"}[5m]))
/
sum(rate(http_requests_total[5m]))
Result: 0.95  (95% successful)
```

**Query 3:** Error rate (5XX)
```
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
Result: 0.05  (5% error rate)
```

**Query 4:** Slow requests (>100ms)
```
http_request_duration_seconds > 0.1
Result: Series where duration > 0.1s (empty if none)
```

**Query 5:** Request throughput
```
rate(http_requests_total[5m]) * 60
Result: ~1.2  (requests per minute)
```

**Query 6:** Requests per hour
```
(rate(http_requests_total[5m]) * 3600)
Result: 72  (requests per hour)
```

## Key Insights

- Binary operators require matching labels
- Division creates ratios/rates
- Comparison filters to matching series
- Chain operations: metric1 / metric2 * scalar
