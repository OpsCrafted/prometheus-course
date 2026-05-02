# Lab 9 Solution: Instant Queries

All queries below return instant vectors (current value).

## Query Results

**Query 1:** `up`
```
up{job="prometheus"}      1
up{job="node-exporter"}   1
```

**Query 2:** `up{job="prometheus"}`
```
up{job="prometheus"}      1
```

**Query 3:** `node_cpu_seconds_total{cpu="0"}`
```
node_cpu_seconds_total{cpu="0",instance="node-exporter:9100",job="node-exporter"}  12345.67
```
(Number varies based on system uptime)

**Query 4:** `node_memory_MemFree_bytes`
```
node_memory_MemFree_bytes{instance="node-exporter:9100",job="node-exporter"}  2147483648
```
(Number varies)

**Query 5:** `http_requests_total`
```
http_requests_total{method="GET",endpoint="/",status="200"}  5
```
(If app running)

**Query 6:** `http_requests_total{endpoint="/"}`
```
http_requests_total{method="GET",endpoint="/",status="200"}  5
```

**Query 7:** `http_requests_total{method=~"G.*"}`
```
http_requests_total{method="GET",endpoint="/",status="200"}  5
```

## Key Points

- All return instant (current) values
- Labels narrow down results
- Empty = metric/labels don't exist
