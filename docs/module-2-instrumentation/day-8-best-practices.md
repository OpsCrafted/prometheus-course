# Day 8: Instrumentation Best Practices

**Time:** 90 minutes | **Prerequisites:** Days 5-7 completed

## Learning Outcomes

- [ ] Know metric naming conventions
- [ ] Understand cardinality limits
- [ ] Follow Prometheus instrumentation guidelines

## Conceptual Explainer

### Metric Naming

Follow Prometheus conventions:

```
{subsystem}_{feature}_{unit}
```

Examples:
- `http_request_duration_seconds` (subsystem: http, feature: request_duration, unit: seconds)
- `database_query_duration_milliseconds` (subsystem: database, feature: query_duration, unit: ms)
- `cache_hits_total` (subsystem: cache, feature: hits, unit: count)

**Rules:**
- Use lowercase
- Use underscores (not dashes or dots)
- Include units: `_seconds`, `_bytes`, `_total`
- Avoid redundancy

### Label Guidelines

**Good labels:**
```go
http_requests_total{method="GET", status="200", handler="/api/users"}
```
- method: HIGH value (GET, POST, PUT, DELETE — ~10 unique)
- status: HIGH value (200, 400, 500 — ~10 unique)
- handler: NORMALIZED (avoid /api/users/123 — use /api/users/{id})

**Bad labels:**
```go
http_requests_total{path="/api/users/123"}  // HIGH CARDINALITY!
http_requests_total{user_id="42"}            // HIGH CARDINALITY!
http_requests_total{ip_address="192.168.1.1"}  // HIGH CARDINALITY!
```

### Cardinality Limits

High cardinality can cause:
- Prometheus memory bloat
- Slow queries
- Database performance issues

**Rule:** Each label combination = 1 time-series

```
http_requests_total{method="GET", status="200"}  = 1 series
http_requests_total{method="POST", status="200"} = 1 series
http_requests_total{method="GET", status="500"}  = 1 series
```

With 4 methods × 10 statuses × 1000 paths = 40,000 series. AVOID!

With 4 methods × 10 statuses × 5 normalized paths = 200 series. GOOD.

## Best Practices Checklist

- [ ] Metric name follows convention
- [ ] Labels are low-cardinality (< 100 unique per label)
- [ ] No user IDs, request IDs, IPs in labels
- [ ] Unit is clear (seconds, bytes, total)
- [ ] Help text is accurate and concise
- [ ] Metrics are tested (increment counter, check output)
- [ ] Metrics don't spam performance (avoid high-frequency updates)

## Anti-Patterns

**❌ DON'T:**
```go
// HIGH CARDINALITY: each request ID is unique
errors.WithLabelValues(errorID).Inc()

// UNBOUNDED MEMORY: creating metrics dynamically
m := prometheus.NewCounter(...)
prometheus.Register(m)  // No unregister!

// TOO FREQUENT: updating every operation
requestCount.Inc()  // 1000s per second
```

**✓ DO:**
```go
// NORMALIZED CARDINALITY
errors.WithLabelValues(normalizeError(err)).Inc()

// PRE-REGISTER all metrics
prometheus.MustRegister(errors)

// BATCH UPDATES
go func() {
    ticker := time.NewTicker(5 * time.Second)
    for range ticker.C {
        updateMetrics()
    }
}()
```

## Reference

**Metric Naming Pattern:**
```
{subsystem}_{feature}_{unit}
```

**Unit Suffixes:**
- `_total` — counters
- `_seconds` — duration
- `_bytes` — size
- `_percent` — percentage
- `_ratio` — ratios

**Label Best Practices:**
- Low cardinality (< 100 unique per label)
- Consistent naming (lowercase, underscores)
- No IDs or high-variance data
- Always include method/status for HTTP

## Lab

See [lab-8-review.md](../../labs/module-2-instrumentation/lab-8-review.md)

## Exit Criteria

- [ ] Know metric naming conventions
- [ ] Understand cardinality and limits
- [ ] Can design metrics for production apps
- [ ] Know anti-patterns to avoid
