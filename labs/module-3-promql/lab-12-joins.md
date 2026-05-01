# Lab 12: Joins & Binary Operators

**Time:** 30-35 minutes  
**Goal:** Combine metrics with operators

## Lab: Calculate Ratios

Perform these queries:

**Query 1:** Division (average latency)
```
http_request_duration_seconds_sum /
http_request_duration_seconds_count
```
Result: Average latency in seconds (0.05 = 50ms)

**Query 2:** Success percentage
```
rate(http_requests_total{status="200"}[5m]) /
rate(http_requests_total[5m])
```
Result: Fraction (0.95 = 95%)

**Query 3:** Error rate
```
rate(http_requests_total{status=~"5.."}[5m]) /
rate(http_requests_total[5m])
```
Result: Fraction of 5XX errors

**Query 4:** Comparison (slow requests)
```
http_request_duration_seconds > 0.1
```
Result: Requests slower than 100ms

**Query 5:** Math (KB/s)
```
rate(http_response_size_bytes[5m]) / 1024
```
Result: Throughput in KB/s

**Query 6:** Multiple operations
```
(rate(http_requests_total[5m]) * 3600)
```
Result: Requests per hour

## Expected Results

- Binary operators combine metrics
- Must have matching labels
- Division creates ratios
- Comparison filters series

## Solution

See `labs/module-3-promql/solutions/lab-12-solution.md`

## Exit Criteria

- [ ] Understand joins on labels
- [ ] Can use binary operators
- [ ] Know comparison operators
- [ ] Can calculate percentages and ratios
