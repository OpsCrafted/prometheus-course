# Lesson 1: Cardinality Explosion

**Time:** 30 minutes

---

## The Mistake

Consider an HTTP request counter instrumented like this:

```python
requests_total = Counter(
    "requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status", "user_id"]   # <-- user_id is the problem
)

requests_total.labels(
    method="GET",
    endpoint="/api/orders",
    status="200",
    user_id=current_user.id          # unique per user
).inc()
```

This looks harmless. But consider what happens at scale:

| Label | Unique values |
|-------|--------------|
| `user_id` | 1,000,000 (one per registered user) |
| `endpoint` | 100 |
| `method` | 5 |
| `status` | 5 |

**Total time series: 1,000,000 × 100 × 5 × 5 = 500,000,000**

Prometheus stores each active time series in memory. At roughly 100 bytes per series, 500 million
series consumes ~50 GB of RAM — on a single metric. Add a few more metrics with the same pattern
and your Prometheus node runs out of memory, crashes, and takes your alerting down with it.

---

## Why It's Bad

**Cardinality** is the number of unique time series a metric produces. It is the product of the
number of unique values across all label dimensions.

Prometheus is designed around **bounded cardinality**: label values come from a small, finite set
known at deploy time (HTTP methods, status codes, service names). The TSDB (time-series database)
is optimised for thousands to low millions of series — not hundreds of millions.

**Bounded labels** (safe):

```
method:   GET, POST, PUT, DELETE, PATCH         → 5 values
status:   200, 400, 404, 429, 500               → 5 values
endpoint: /api/orders, /api/users, /health ...  → ~100 values
```

**Unbounded labels** (dangerous):

```
user_id:    1, 2, 3, ... 1000000+   → grows forever
request_id: uuid per request        → billions of values
ip_address: every client IP         → millions of values
```

Every new value for an unbounded label creates a new time series. Because users register, request
IDs are generated per-call, and IP addresses span the internet, these label sets grow without
bound. Prometheus cannot compact or evict active series during a scrape cycle, so memory grows
until the process is killed.

---

## The Fix

Remove unbounded label dimensions from metric definitions. Aggregate the data you actually need
to alert on into bounded labels.

**Before (dangerous):**

```python
requests_total = Counter(
    "requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status", "user_id"]
)
```

**After (safe):**

```python
requests_total = Counter(
    "requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"]     # user_id removed
)
```

If you need per-user analytics, use a purpose-built system (application database, data warehouse,
or a tracing backend). Prometheus is not the right tool for per-entity cardinality — it is a
system for aggregate operational metrics.

**Quick cardinality check** — run this PromQL query against your Prometheus instance:

```promql
topk(10, count by (__name__)({__name__=~".+"}))
```

This shows the 10 metrics with the most active time series. Any metric above ~100,000 series
warrants investigation.

---

## Lab: Cardinality Incident

In this lab you will diagnose a simulated Prometheus instance that is consuming 50 GB of memory
and crashing every few hours due to a cardinality explosion on a single metric.

Lab files: [`labs/capstone/scenarios/cardinality-incident/`](../../labs/capstone/scenarios/cardinality-incident/)

Start with the lab README for the full scenario, investigation steps, and the fix to apply.
