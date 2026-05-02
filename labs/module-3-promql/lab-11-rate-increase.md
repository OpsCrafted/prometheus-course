# Lab 11: Rate & Increase

**Time:** 30-35 minutes  
**Goal:** Calculate rates from counters

## Lab: Calculate Rates

Perform these queries (need app running):

**Query 1:** Raw counter
```
http_requests_total
```
Result: Cumulative total (e.g., 5, 10, 15, ...)

**Query 2:** Per-second rate (5 min window)
```
rate(http_requests_total[5m])
```
Result: Requests per second (e.g., 0.05 req/s)

**Query 3:** Total increase (5 min window)
```
increase(http_requests_total[5m])
```
Result: Total increase in last 5 min (e.g., 15 requests)

**Query 4:** Rate by status
```
sum(rate(http_requests_total[5m])) by (status)
```
Result: Per-second rate grouped by status

**Query 5:** Success rate (% of 200s)
```
rate(http_requests_total{status="200"}[5m]) /
rate(http_requests_total[5m])
```
Result: Fraction (0.95 = 95% success)

**Query 6:** Rate with 1 hour window
```
rate(http_requests_total[1h])
```
Result: Smoother rate (less volatile)

## Expected Results

- rate() returns per-second values (small decimals)
- increase() returns absolute totals
- Rates smooth over time window
- Longer windows = smoother rates

## Solution

See `labs/module-3-promql/solutions/lab-11-solution.md`

## Exit Criteria

- [ ] Understand rate() calculation
- [ ] Can apply rate to different time windows
- [ ] Know difference between rate and increase
- [ ] Can calculate ratios from rates
