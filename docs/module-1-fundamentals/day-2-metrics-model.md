# Day 2: Metrics Model

**Time:** 90 minutes | **Prerequisites:** Day 1 completed

## Learning Outcomes

- [ ] Know the 4 metric types (gauge, counter, histogram, summary)
- [ ] Understand when to use each metric type
- [ ] Know label naming conventions

## Conceptual Explainer

Prometheus defines 4 metric types, each serving a specific purpose:

### 1. Gauge — Value that can go up or down

A gauge represents a measurement that can increase or decrease over time.

**Example:** `node_memory_MemFree_bytes` (memory free on a system)

**Use when:** Temperature, memory, disk space, connections, CPU load, queue length

**Key trait:** The value at any moment matters. "What is the current value?"

### 2. Counter — Value that only increases (or resets on restart)

A counter measures a cumulative quantity that only ever increases. It can reset when the application restarts.

**Example:** `http_requests_total` (total requests since startup)

**Use when:** Tracking totals (requests, errors, bytes sent, disk writes completed)

**Key trait:** Only increases monotonically. "How much total since boot?"

### 3. Histogram — Bucket distribution of observations

A histogram tracks the distribution of observations by putting them into buckets. Useful for latency and response size analysis.

**Example:** `http_request_duration_seconds`

**What it creates:**
- `_bucket{le="0.005"}`, `_bucket{le="0.01"}`, ... (buckets)
- `_sum` (total sum of observations)
- `_count` (total count of observations)

**Use when:** Measuring request latency, response sizes, percentiles (p50, p95, p99)

**Key trait:** Prometheus can calculate percentiles from buckets.

### 4. Summary — Pre-computed quantiles (rarely used)

A summary is like a histogram but with quantiles pre-calculated by the client library.

**Use when:** Client-side quantile calculation is preferred (rare)

**Note:** Histogram is usually better.

## Decision Tree

```
Does the value go down?
├─ YES → GAUGE
└─ NO → Only increases?
   └─ YES → COUNTER
   └─ NO → Distribution needed?
      ├─ YES → HISTOGRAM or SUMMARY
      └─ NO → Check requirements again
```

## Hands-On: Identify Metrics in Prometheus

**Step 1:** Verify Prometheus is running

```bash
curl http://localhost:9090/-/healthy
```

**Step 2:** Open http://localhost:9090, click **Graph** tab

**Step 3:** Query `up`:
- Shows 1 (up) or 0 (down)
- **This is a GAUGE** — value changes between 0 and 1

**Step 4:** Query `node_cpu_seconds_total`:
- Large numbers, increasing over time
- **This is a COUNTER** — increases with each CPU second
- `_total` suffix is a hint

**Step 5:** Query `node_filesystem_size_bytes`:
- File system sizes (stable unless filesystems change)
- **This is a GAUGE** — can change but doesn't always increase

## Label Naming Conventions

Good label names:
- Are lowercase
- Use underscores (not dashes)
- Are descriptive but short
- Follow a consistent naming scheme

**Examples:**
- `http_requests_total{method="GET", status="200"}`
- `database_query_duration_seconds{query_type="SELECT", table="users"}`

**Auto-added labels from scrape config:**
- `job` — the job name from prometheus.yml
- `instance` — the target address (host:port)

## Reference

**Metric Type Quick Reference:**

| Type | Can decrease? | Use case | Example |
|------|---------------|----------|---------|
| Gauge | Yes | Current state | memory_bytes, temp |
| Counter | No | Cumulative total | requests_total |
| Histogram | N/A | Distribution | request_duration_seconds |
| Summary | N/A | Quantiles | request_duration_seconds |

**Naming best practices:**
- Use `_total` suffix for counters
- Use `_seconds`, `_bytes`, `_percent` for units
- Prefix with subsystem: `http_`, `database_`

## Lab

See [lab-2-metric-types.md](../../labs/module-1-fundamentals/lab-2-metric-types.md)

## Exit Criteria

- [ ] Know 4 metric types and their purpose
- [ ] Can identify metric type from name and behavior
- [ ] Understand label naming conventions
