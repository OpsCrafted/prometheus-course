# Lab 11 Solution: Rate & Increase

## Query Results (example with 5 requests/25 seconds)

**Query 1:** `http_requests_total`
```
{method="GET",path="/hello",status="200"}  5
```

**Query 2:** `rate(http_requests_total[5m])`
```
{method="GET",path="/hello",status="200"}  0.02  (5 requests / 300 seconds)
```

**Query 3:** `increase(http_requests_total[5m])`
```
{method="GET",path="/hello",status="200"}  5  (5 requests in 5 minutes)
```

**Query 4:** `rate(http_requests_total[5m]) by (status)`
```
{status="200"}  0.02
```

**Query 5:** Success rate calculation
```
0.95  (95% success, if 5/5 = 1.0 or 95/100)
```

**Query 6:** `rate(http_requests_total[1h])`
```
{method="GET",path="/hello",status="200"}  0.0013  (5 requests / 3600 seconds)
```

## Key Points

- Shorter windows (5m): More volatile rates
- Longer windows (1h): Smoother rates
- rate() handles counter resets automatically
- Divide rates to get ratios (success rate, error rate, etc.)
