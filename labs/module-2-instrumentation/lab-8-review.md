# Lab 8: Instrumentation Review

**Time:** 35-40 minutes  
**Goal:** Apply best practices to app.go

## Lab: Refactor for Best Practices

Review your app.go and refactor to follow best practices.

**Task 1:** Verify Metric Names

Check all metrics follow `{subsystem}_{feature}_{unit}`:
- ✓ `http_requests_total` — good
- ✓ `http_request_duration_seconds` — good
- ✓ `app_active_connections` — good

**Task 2:** Check Label Cardinality

For each metric, count potential unique values per label:

```go
requestsTotal.WithLabelValues(r.Method, r.URL.Path, status)
// method: ~4 (GET, POST, PUT, DELETE) ✓
// path: ~2 (/hello, /metrics) ✓  
// status: ~3 (200, 404, 500) ✓
// Total: 4 * 2 * 3 = 24 series (fine)
```

**Task 3:** Check for High Cardinality

If you had user IDs in labels:
```go
// ❌ BAD
requestsTotal.WithLabelValues(r.Method, userID).Inc()
// Could be millions of userIDs!

// ✓ GOOD
requestsTotal.WithLabelValues(r.Method, "user").Inc()
```

**Task 4:** Verify Help Texts

All metrics should have clear help text:
```go
prometheus.GaugeOpts{
    Name: "app_active_connections",
    Help: "Number of active HTTP connections",  // Clear!
}
```

**Task 5:** Performance Check

Make sure metrics don't cause performance issues:
- [ ] Metrics recorded only per-request (not per-operation)
- [ ] Gauges updated on timer (not on every event)
- [ ] No dynamic metric registration

## Checklist

- [ ] All metric names follow convention
- [ ] Label cardinality is reasonable (< 100 per label)
- [ ] No user IDs, IPs, or other high-variance data in labels
- [ ] Help text is clear and accurate
- [ ] Metrics don't impact performance
- [ ] Code is production-ready

## Solution

See `labs/module-2-instrumentation/solutions/app-best-practices-solution.go`

## Exit Criteria

- [ ] Verified metric names
- [ ] Analyzed label cardinality
- [ ] No high-cardinality labels
- [ ] Help texts clear
- [ ] Performance acceptable
