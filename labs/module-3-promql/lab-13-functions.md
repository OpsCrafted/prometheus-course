# Lab 13: Functions & Transformations

**Time:** 30-35 minutes  
**Goal:** Transform metrics with functions

## Lab: Apply Functions

Perform these queries:

**Query 1:** Round to integer
```
round(node_memory_MemFree_bytes / 1e9)
```
Result: Free memory in GB (rounded)

**Query 2:** Absolute value
```
abs(node_cpu_seconds_total)
```
Result: Absolute CPU seconds

**Query 3:** Logarithm (compress large values)
```
log(http_requests_total + 1)
```
Result: Log scale requests

**Query 4:** Compare to 1 hour ago
```
rate(http_requests_total[5m]) /
(rate(http_requests_total[5m] offset 1h) + 0.001)
```
Result: Ratio of current to 1h ago (avoids division by zero)

**Query 5:** Count changes
```
changes(up[15m])
```
Result: How many times targets changed status

**Query 6:** Floor (round down)
```
floor(node_memory_MemFree_bytes / 1e9)
```
Result: Free memory in GB (rounded down)

## Expected Results

- round/ceil/floor change decimal places
- offset compares to historical time
- changes counts status updates
- Functions compose: round(rate(metric[5m]))

## Solution

See `labs/module-3-promql/solutions/lab-13-solution.md`

## Exit Criteria

- [ ] Know common functions
- [ ] Can use offset for time shifts
- [ ] Can combine multiple functions
- [ ] Understand transformations
