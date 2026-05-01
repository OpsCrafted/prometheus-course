# Capstone Challenge Solutions

## Challenge Set 1: Complete System Setup

### Sample Queries

Query 1: Total req/sec
```
sum(rate(api_http_requests_total[5m])) +
sum(rate(database_http_requests_total[5m])) +
sum(rate(cache_http_requests_total[5m]))
```

Query 2: p95 latency per service
```
histogram_quantile(0.95, rate(api_http_request_duration_seconds_bucket[5m]))
```

Query 3: Service health
```
up
```

Query 4: Error rate
```
sum(rate(api_http_requests_total{status=~"5.."}[5m])) /
sum(rate(api_http_requests_total[5m]))
```

Query 5: Client connections
```
api_connected_clients +
database_connected_clients +
cache_connected_clients
```

## Challenge Set 2: Alerts & Dashboard

Key alert queries:
- TargetDown: up == 0
- HighErrorRate: error_rate > 0.05
- HighLatency: p95 > 0.1 seconds
- TrafficDropped: rate_ratio < 0.5

## Challenge Set 3: Troubleshooting

Root cause determination process:

1. Check health: up metric
2. Check traffic: rate(requests[5m])
3. Check latency: histogram_quantile(0.95, ...)
4. Check errors: rate(errors[5m]) / rate(requests[5m])
5. Correlate findings

Common scenarios:
- High latency + high errors = Database issue
- High latency + low errors = Resource contention
- Traffic down = Upstream problem
- Errors high + latency normal = Application bug
