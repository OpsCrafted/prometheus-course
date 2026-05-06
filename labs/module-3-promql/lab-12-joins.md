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
sum(rate(http_requests_total{status="200"}[5m]))
/
sum(rate(http_requests_total[5m]))
```
Result: Fraction (0.95 = 95%) — sum() ensures label sets match before dividing

**Query 3:** Error rate
```
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```
Result: Fraction of 5XX errors — sum() collapses labels before dividing

**Query 4:** Comparison (active endpoints)
```
http_request_duration_seconds_count > 10
```
Result: Endpoints that have served more than 10 requests

**Query 5:** Request throughput
```
rate(http_requests_total[5m]) * 60
```
Result: Requests per minute

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
