# Day 9: Instant & Range Vectors

**Time:** 90 minutes | **Prerequisites:** Module 1-2 completed

## Learning Outcomes

- [ ] Understand instant vs range vectors
- [ ] Know time range syntax (5m, 1h, etc.)
- [ ] Can query gauge and counter metrics

## Conceptual Explainer

PromQL has two main query types:

### Instant Vector Query

Returns the current value of a metric.

```
up
```

Result: Single value per time-series
```
up{job="prometheus"}        1
up{job="node-exporter"}     1
```

### Range Vector Query

Returns a range of values over time.

```
up[5m]
```

Result: Time-series with samples from last 5 minutes
- Used for aggregation (sum, avg, etc.)
- Not useful by itself (need aggregation)

### Time Ranges

```
1s    — 1 second
5m    — 5 minutes
1h    — 1 hour
1d    — 1 day
1w    — 1 week
1y    — 1 year
```

### Metric Selectors

Filter by labels:

```
up{job="prometheus"}           # Exact match
up{job=~"prom.*"}              # Regex match
up{job!="node-exporter"}       # Not equal
up{status=~"2.."}              # Regex: 2XX
```

## Hands-On: Query Metrics

**Step 1:** Open http://localhost:9090, Graph tab

**Step 2:** Instant query (gauge):

```
node_memory_MemFree_bytes
```

Shows current free memory.

**Step 3:** Instant query (counter):

```
node_cpu_seconds_total{cpu="0"}
```

Shows total CPU seconds for CPU 0.

**Step 4:** Range query (prepare for aggregation):

```
http_requests_total[5m]
```

Shows requests from last 5 minutes. (If no data, result is empty.)

**Step 5:** Filter by label:

```
up{job="prometheus"}
```

Shows UP status only for prometheus job.

## Key Concepts

**Selector Operators:**
- `=` — exact match
- `!=` — not equal
- `=~` — regex match
- `!~` — regex not match

**Time Syntax:**
- `now()-5m` — 5 minutes ago
- `now()-1h` — 1 hour ago
- Just use the number: `5m`, `1h`, etc.

**Empty results:** If a query returns empty, either:
- The time-series doesn't exist
- The label filter is too strict
- Check Targets tab to see available metrics

## Reference

**Basic PromQL Syntax:**

| Query | Type | Use |
|-------|------|-----|
| `metric_name` | Instant | Current value |
| `metric_name[5m]` | Range | Last 5 minutes |
| `metric{label="value"}` | Instant | Filter by label |
| `metric{label=~"regex"}` | Instant | Regex filter |

**Time Modifiers:**
- `[5m]` — Last 5 minutes
- `[1h]` — Last 1 hour
- `[1d]` — Last 1 day

## Lab

See [lab-9-instant-queries.md](../../labs/module-3-promql/lab-9-instant-queries.md)

## Exit Criteria

- [ ] Understand instant vs range vectors
- [ ] Know time range syntax
- [ ] Can query with label filters
- [ ] Know selector operators
