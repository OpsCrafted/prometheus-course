# Day 10: Aggregation Operators

**Time:** 90 minutes | **Prerequisites:** Day 9 completed

## Learning Outcomes

- [ ] Know aggregation operators (sum, avg, max, min, count)
- [ ] Understand "by" and "without" clauses
- [ ] Can aggregate across labels

## Conceptual Explainer

Aggregation combines multiple time-series into one or fewer.

### Sum

Adds values across time-series:

```
sum(http_requests_total)
```

Example:
```
http_requests_total{method="GET", path="/api/users"}     100
http_requests_total{method="GET", path="/api/posts"}     50
http_requests_total{method="POST", path="/api/users"}    30
                                                        -------
sum(http_requests_total)                                 180
```

### Average

Averages values:

```
avg(node_cpu_seconds_total)
```

### Max / Min

```
max(http_request_duration_seconds)
min(node_memory_MemFree_bytes)
```

### Count

Counts number of time-series:

```
count(up)
```

Returns: Number of targets (each is a separate time-series)

### Group By

Keep specific labels, drop others:

```
sum(http_requests_total) by (method)
```

Result:
```
{method="GET"}     150
{method="POST"}    30
```

### Group Without

Keep all labels except specified:

```
sum(http_requests_total) without (path)
```

Result:
```
{method="GET"}     150
{method="POST"}    30
```

## Hands-On: Aggregate Metrics

**Step 1:** Sum all requests:

```
sum(http_requests_total)
```

If app is running, shows total.

**Step 2:** Sum by method:

```
sum(http_requests_total) by (method)
```

Shows GET total, POST total, etc.

**Step 3:** Sum by status:

```
sum(http_requests_total) by (status)
```

Shows 200 total, 500 total, etc.

**Step 4:** Count targets:

```
count(up)
```

Shows number of targets.

**Step 5:** Count by job:

```
count(up) by (job)
```

Shows targets per job.

## Key Concepts

**Aggregation operators:**
- `sum()` — Total
- `avg()` — Average
- `max()` — Maximum
- `min()` — Minimum
- `count()` — Number of series
- `stddev()` — Standard deviation
- `quantile()` — Percentile

**Grouping:**
- `by (label)` — Keep only this label
- `without (label)` — Remove this label

**Be careful with cardinality:** Aggregating high-cardinality metrics can still return many series.

## Reference

**Aggregation Syntax:**

```
operator(metric) [by|without (labels)]
```

**Examples:**
```
sum(metric)
sum(metric) by (job)
sum(metric) without (instance)
avg(metric)
max(metric)
count(metric)
```

## Lab

See [lab-10-aggregation.md](../../labs/module-3-promql/lab-10-aggregation.md)

## Exit Criteria

- [ ] Know all aggregation operators
- [ ] Can use "by" clauses
- [ ] Can use "without" clauses
- [ ] Understand aggregation results
