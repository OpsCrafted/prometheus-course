# Lab 9: Instant Queries

**Time:** 25-30 minutes  
**Goal:** Practice instant queries with filters

## Lab: Query Available Metrics

Perform these queries in Prometheus Graph tab:

**Query 1:** All up metrics
```
up
```
Result: Shows all targets (up=1 or up=0)

**Query 2:** Only prometheus job up status
```
up{job="prometheus"}
```
Result: Single series for prometheus

**Query 3:** CPU seconds
```
node_cpu_seconds_total{cpu="0"}
```
Result: Total CPU seconds for CPU 0

**Query 4:** Memory free (if available)
```
node_memory_MemFree_bytes
```
Result: Free memory in bytes

**Query 5:** Requests total by method (if app running)
```
http_requests_total
```
Result: All requests

**Query 6:** Specific request endpoint
```
http_requests_total{endpoint="/"}
```
Result: Requests for / endpoint only

**Query 7:** Regex filter (methods starting with G)
```
http_requests_total{method=~"G.*"}
```
Result: GET and similar methods

## Expected Results

Each query should return:
- Instant value (single point in time)
- Label set for each series
- Number in Prometheus blue

If query returns empty, the metric or label doesn't exist.

## Troubleshooting

- No results? Check Targets tab
- Wrong labels? Try without label filter
- Metric name wrong? Check metric list in UI

## Solution

See `labs/module-3-promql/solutions/lab-9-solution.md`

## Exit Criteria

- [ ] Executed all 7 queries
- [ ] Understand instant vs range syntax
- [ ] Know how to filter by labels
