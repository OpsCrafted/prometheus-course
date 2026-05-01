# Lab 13 Solution: Functions & Transformations

## Query Results

**Query 1:** Memory in GB (rounded)
```
round(node_memory_MemFree_bytes / 1e9)
Result: 2  (2 GB free)
```

**Query 2:** Absolute CPU seconds
```
abs(node_cpu_seconds_total)
Result: 12345.67  (same, already positive)
```

**Query 3:** Log scale
```
log(http_requests_total + 1)
Result: 1.79  (log of 5+1 = log(6))
```

**Query 4:** Growth ratio
```
rate(http_requests_total[5m]) / (rate(http_requests_total[5m] offset 1h) + 0.001)
Result: 1.5  (50% more traffic now than 1h ago)
```

**Query 5:** Status changes
```
changes(up[15m])
Result: 0  (no targets went up/down)
```

**Query 6:** Memory GB (floor)
```
floor(node_memory_MemFree_bytes / 1e9)
Result: 1  (1 GB, rounded down from 1.8)
```

## Function Patterns

- `round(value)` for clean numbers
- `metric offset 1h` for historical comparison
- `log(metric)` for compression
- `changes(metric)` for volatility
- `ceil/floor` for rounding direction control
