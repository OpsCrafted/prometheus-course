# Lab 10 Solution: Aggregation

## Query Results

**Query 1:** `count(up)` = `2`
- Result: 2 targets total

**Query 2:** `sum(http_requests_total)` = `5` (example)
- Result: Total requests across all combinations

**Query 3:** `sum(http_requests_total) by (method)`
```
{method="GET"}  5
```

**Query 4:** `sum(http_requests_total) by (status)`
```
{status="200"}  5
```

**Query 5:** `avg(node_cpu_seconds_total)`
```
12345.67
```
(Average CPU seconds)

**Query 6:** `count(up) by (job)`
```
{job="prometheus"}      1
{job="node-exporter"}   1
```

**Query 7:** `max(node_memory_MemFree_bytes)`
```
2147483648
(varies by system)
```

## Key Insights

- `count()` counts series, not values
- `sum(metric) by (label)` groups by label
- Aggregation returns fewer results (grouped)
- Without "by", returns single aggregated value
