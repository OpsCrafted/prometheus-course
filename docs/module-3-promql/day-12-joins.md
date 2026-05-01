# Day 12: Joins & Binary Operators

**Time:** 90 minutes | **Prerequisites:** Days 9-11 completed

## Learning Outcomes

- [ ] Know binary operators (+, -, *, /)
- [ ] Understand metric joins
- [ ] Can divide metrics to calculate ratios

## Conceptual Explainer

### Binary Operators

Combine two metrics:

```
metric1 + metric2       # Addition
metric1 - metric2       # Subtraction
metric1 * metric2       # Multiplication
metric1 / metric2       # Division
```

### Joins (Label Matching)

When combining two metrics, Prometheus matches on labels:

```
http_requests_total{method="GET", path="/api/users"}     100
http_request_duration_seconds{method="GET", path="/api/users"}  0.125

# Result (automatic join on method, path)
http_requests_total / http_request_duration_seconds
= 100 / 0.125 = 800
```

**Matching rules:**
- Labels must have same values
- Non-matching series are dropped

### Ratio Calculation

Calculate error percentage:

```
rate(errors_total[5m]) / rate(requests_total[5m])
```

Result: Fraction (0.05 = 5% errors)

### Comparison Operators

```
metric > 100        # Greater than
metric < 50         # Less than
metric == 1         # Equal
metric != 0         # Not equal
```

## Hands-On: Calculate Ratios

**Step 1:** View two metrics:

```
http_requests_total
http_request_duration_seconds_sum
```

**Step 2:** Calculate average latency:

```
http_request_duration_seconds_sum / http_request_duration_seconds_count
```

Result: Seconds per request

**Step 3:** Filter by status:

```
rate(http_requests_total{status="200"}[5m]) /
rate(http_requests_total[5m])
```

Result: Fraction of successful requests (0.95 = 95%)

**Step 4:** Find slow requests:

```
http_request_duration_seconds > 0.5
```

Returns requests slower than 0.5 seconds.

## Key Concepts

**Label matching:**
- Only series with matching labels are combined
- Extra labels don't prevent joins (ignored)
- Different label values prevent joins (series dropped)

**Use group_left/group_right for cardinality mismatch:**

```
# If counts don't match, use:
rate(requests[5m]) / group_left() rate(total[5m])
```

## Reference

**Binary Operators:**

```
metric1 + metric2   — Add
metric1 - metric2   — Subtract  
metric1 * metric2   — Multiply
metric1 / metric2   — Divide
metric1 % metric2   — Modulo
```

**Comparison:**
```
metric > value
metric < value
metric == value
metric != value
metric >= value
metric <= value
```

## Lab

See [lab-12-joins.md](../../labs/module-3-promql/lab-12-joins.md)

## Exit Criteria

- [ ] Know binary operators
- [ ] Understand metric joins
- [ ] Can calculate ratios and percentages
- [ ] Understand comparison operators
