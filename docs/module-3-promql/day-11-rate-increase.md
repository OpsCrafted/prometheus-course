# Day 11: Rate & Increase

**Time:** 90 minutes | **Prerequisites:** Days 9-10 completed

## Learning Outcomes

- [ ] Know rate() for counters
- [ ] Know increase() for counters
- [ ] Calculate per-second rates
- [ ] Understand counter resets

## Conceptual Explainer

### rate() — Per-second rate

Calculates how fast a counter is increasing:

```
rate(http_requests_total[5m])
```

Result: requests per second over last 5 minutes

Example:
```
Time 0:     http_requests_total = 1000
Time 300s:  http_requests_total = 1200
           rate = (1200 - 1000) / 300 = 0.667 req/s
```

### increase() — Total increase

Calculates total increase over time period:

```
increase(http_requests_total[5m])
```

Result: How many requests in the last 5 minutes

Example: `increase(http_requests_total[5m])` = 200 requests

### Key Difference

- `rate()` — Returns per-second rate (0.667 req/s)
- `increase()` — Returns absolute increase (200 requests)

### Counter Resets

Both handle counter resets automatically:

```
Counter: 100 → 50 → 100
          ↓ reset ↓ continues
```

`rate()` and `increase()` calculate correctly even with resets.

## Hands-On: Calculate Rates

**Step 1:** View counter (raw):

```
http_requests_total
```

Shows cumulative total.

**Step 2:** Calculate rate (per-second):

```
rate(http_requests_total[5m])
```

Shows requests/second over last 5 minutes.

**Step 3:** Calculate increase (total):

```
increase(http_requests_total[5m])
```

Shows total requests in last 5 minutes.

**Step 4:** Rate by status:

```
rate(http_requests_total[5m]) by (status)
```

Shows 200/sec, 500/sec, etc.

**Step 5:** Percentage of errors:

```
rate(http_requests_total{status=~"5.."}[5m]) /
rate(http_requests_total[5m])
```

Shows error rate as fraction (0.05 = 5%).

## Key Concepts

**Always use rate() for counters:**
- `rate()` for dashboards, alerts
- `increase()` for total counts

**Time window must have data:**
```
rate(metric[5m])  # Last 5 minutes
rate(metric[1h])  # Last 1 hour
```

Larger windows = smoother rates.

## Reference

**Counter Functions:**

```
rate(counter[5m])     — Requests per second
increase(counter[5m]) — Total increase
```

**Common rates:**
- `rate(requests_total[5m])` — Requests/second
- `rate(errors_total[5m])` — Errors/second
- `rate(bytes_total[5m])` — Bytes/second

## Lab

See [lab-11-rate-increase.md](../../labs/module-3-promql/lab-11-rate-increase.md)

## Exit Criteria

- [ ] Understand rate() calculation
- [ ] Know difference between rate() and increase()
- [ ] Can calculate per-second rates
- [ ] Can filter rates by label
