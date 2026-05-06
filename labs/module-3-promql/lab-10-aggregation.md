# Lab 10: Aggregation

**Time:** 30-35 minutes  
**Goal:** Practice aggregation operators

## Lab: Aggregate Metrics

Perform these queries:

**Query 1:** Count all targets
```
count(up)
```
Should return: 6 (one per scraped job: prometheus, node-exporter, sample-app, postgres-exporter, redis-exporter, blackbox)

**Query 2:** Sum all requests (if app running)
```
sum(http_requests_total)
```
Should return: Total of all requests

**Query 3:** Sum requests by method
```
sum(http_requests_total) by (method)
```
Should return: GET=X, POST=Y

**Query 4:** Sum requests by status
```
sum(http_requests_total) by (status)
```
Should return: 200=X, 500=Y

**Query 5:** Average value
```
avg(node_cpu_seconds_total)
```
Should return: Average CPU seconds

**Query 6:** Count by job
```
count(up) by (job)
```
Should return: one series per scraped job (prometheus, node-exporter, sample-app, postgres-exporter, redis-exporter, blackbox)

**Query 7:** Max memory
```
max(node_memory_MemFree_bytes)
```
Should return: Maximum free memory

## Expected Results

Each aggregation returns fewer series (grouped by label).

## Solution

See `labs/module-3-promql/solutions/lab-10-solution.md`

## Exit Criteria

- [ ] Understand aggregation operators
- [ ] Can use "by" clauses
- [ ] Results make sense (fewer series)
