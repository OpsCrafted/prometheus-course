# Day 13: Functions & Transformations

**Time:** 90 minutes | **Prerequisites:** Days 9-12 completed

## Learning Outcomes

- [ ] Know common PromQL functions
- [ ] Understand offset for time shifts
- [ ] Can transform metrics with functions

## Conceptual Explainer

### Common Functions

**Rounding:**
```
round(metric)           # Round to nearest integer
ceil(metric)            # Round up
floor(metric)           # Round down
```

**Logarithm:**
```
log(metric)             # Natural logarithm
log2(metric)            # Base-2 logarithm
log10(metric)           # Base-10 logarithm
```

**Absolute Value:**
```
abs(metric)             # Absolute value
```

**History:**
```
shift(metric, 1h)       # Shift back 1 hour in time
deriv(metric)           # Derivative (rate of change)
```

### Offset (Time Shift)

Compare current vs past:

```
http_requests_total - http_requests_total offset 1h
```

Result: How many requests in the last hour compared to 1 hour ago

### Changes

Track when values change:

```
changes(metric[5m])     # Number of times metric changed
```

## Hands-On: Transform Metrics

**Step 1:** Round values:

```
round(node_memory_MemFree_bytes / 1e9)
```

Result: Free memory in gigabytes (rounded)

**Step 2:** Compare to 1 hour ago:

```
rate(requests_total[5m]) / (rate(requests_total[5m] offset 1h))
```

Result: Ratio of current rate to 1 hour ago

**Step 3:** Count changes:

```
changes(up[15m])
```

Result: How many times a target status changed

**Step 4:** Absolute value:

```
abs(node_pressure_io_waiting_seconds)
```

## Key Concepts

**offset:** Compare to historical data
```
metric offset 1h        # Value from 1 hour ago
metric offset 5m        # Value from 5 minutes ago
```

**Combining functions:**
```
round(rate(metric[5m]) / 1000)
```

Reads inside-out: metric → rate → divide → round

## Reference

**Functions:**

| Function | Purpose |
|----------|---------|
| round() | Round to nearest |
| ceil() | Round up |
| floor() | Round down |
| abs() | Absolute value |
| log() | Natural log |
| deriv() | Derivative |
| changes() | Count changes |

**Time shifts:**
```
metric offset 1h        — 1 hour ago
metric offset 5m        — 5 minutes ago
```

## Lab

See [lab-13-functions.md](../../labs/module-3-promql/lab-13-functions.md)

## Exit Criteria

- [ ] Know common functions
- [ ] Can use offset for time shifts
- [ ] Can combine multiple functions
- [ ] Understand transformations
