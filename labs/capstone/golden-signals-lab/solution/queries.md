# Golden Signals Lab - Solution

## Query 1: P95 Latency

**PromQL:**

```promql
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{endpoint="/api/checkout"}[5m])) by (le))
```

**Expected result:** ~1500ms (1.5 seconds) during the incident window

**Interpretation:** Latency is definitely up. The p95 has risen 15x above the 100ms baseline and is 7.5x above the 200ms SLO. This confirms the user-reported slowness and tells us the problem is real and severe. Continue investigating the other signals to find the cause.

---

## Query 2: Traffic

**PromQL:**

```promql
rate(http_requests_total{endpoint="/api/checkout"}[5m])
```

**Expected result:** ~10 req/s (unchanged from baseline)

**Interpretation:** Traffic is normal, not the cause. Request volume has not increased, so we cannot attribute the latency spike to a sudden surge in load. This rules out a traffic-related cause and narrows the investigation to something wrong inside the service or its dependencies.

---

## Query 3: Error Rate

**PromQL:**

```promql
(
  sum(rate(http_requests_total{endpoint="/api/checkout", status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total{endpoint="/api/checkout"}[5m]))
) * 100
```

**Expected result:** ~1% (unchanged from baseline)

**Interpretation:** Error rate is normal. Requests are completing and returning successful responses — they are just taking much longer than expected. A normal error rate combined with high latency is a strong indicator of a saturation or resource bottleneck downstream, not an application-level failure.

---

## Query 4: Resource Saturation

**PromQL:**

```promql
rate(node_disk_read_bytes_total[5m])
```

**Expected result:** ~524,288,000 bytes/s (~500 MB/s), spiked from a baseline of ~104,857,600 bytes/s (~100 MB/s)

**Interpretation:** Disk read throughput on the database host has spiked 5x above baseline. CPU is only at 30% and memory is healthy, so the bottleneck is not compute. The database is performing excessive disk reads, consistent with slow queries doing full table scans. Every checkout request that hits the database must wait for disk I/O to complete, which is why latency is high for all requests while the error rate stays low.

---

## Root Cause

The root cause is **database slow queries causing high disk I/O**.

### What happened

An unoptimized query in the checkout service performs a full table scan against the `orders` table. As the table grew over time, this query crossed a threshold where it could no longer be served from the database buffer cache and began reading large amounts of data from disk on every request.

### Likely causes

- A missing or unused index on a frequently queried column (e.g., `user_id` or `created_at`)
- A query that recently changed to bypass an index (e.g., due to a type mismatch or implicit cast)
- Database statistics that have not been updated, causing the query planner to choose a bad execution plan
- A table that grew large enough to make a previously-acceptable sequential scan untenable

### Fix suggestion

1. Run `EXPLAIN ANALYZE` on the slow checkout query to identify the full table scan
2. Add an appropriate index on the column used in the `WHERE` clause
3. Update table statistics with `ANALYZE orders`
4. Monitor `rate(node_disk_read_bytes_total[5m])` to confirm disk I/O returns to baseline after the fix
5. Set up a Prometheus alert on `histogram_quantile(0.95, ...)` so future regressions page on-call before users notice
