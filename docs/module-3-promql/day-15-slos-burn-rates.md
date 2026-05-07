# Day 15: SLOs and Burn Rates

**Time:** 90 minutes | **Prerequisites:** Days 9-14 completed

## Learning Outcomes

- [ ] Define SLI, SLO, and error budget
- [ ] Write an availability SLI query
- [ ] Calculate burn rate from error ratio
- [ ] Understand why burn rate beats raw error rate for alerting
- [ ] Write a multi-window burn rate alert
- [ ] Build a latency SLO using histogram bucket fractions

## Conceptual Explainer

### The Problem With Raw Error Rate Alerts

Most teams start with an alert like this:

```promql
rate(http_requests_total{status=~"5.."}[5m]) > 0.01
```

This alert fires when your error rate is above 1%. But "1% error rate" means very different things depending on traffic:

- At 10 req/s: 0.1 errors/sec — probably fine
- At 10,000 req/s: 100 errors/sec — definitely not fine

SLOs fix this by connecting error rates to user impact. Instead of alerting on raw numbers, you alert on **how fast you're burning through your reliability budget**.

### SLI: The Measurement

A **Service Level Indicator (SLI)** is a ratio measuring service quality from the user's perspective.

**Availability SLI:** good requests / total requests

```promql
sum(rate(http_requests_total{status!~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

Result: 0.0 to 1.0. A healthy service returns ≈ 0.99 or higher.

The complement — error ratio — is:

```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

Result: 0.0 to 1.0. For a healthy service this is ≈ 0.0. These two values always sum to 1.0.

### SLO: The Target

A **Service Level Objective (SLO)** is the target you commit to. Example:

- Availability SLO: **99%** (0.99)
- This means: tolerate at most 1% errors

Your **error budget** is the allowed failure rate: 1% (0.01). You can track remaining budget:

```promql
1 - (
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
)
```

Result near 1.0 = budget mostly intact. Result near 0 = budget nearly exhausted.

### Burn Rate: How Fast Are You Spending It?

**Burn rate** tells you how fast you're consuming your error budget relative to the allowed rate.

For a 99% SLO, the allowed error ratio is 0.01 (1%):

```promql
(
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
)
/
0.01
```

| Burn rate | Meaning |
|-----------|---------|
| 0 | No errors — budget untouched |
| 1 | Consuming budget at exactly the allowed rate |
| 2 | Budget will exhaust in half the expected window |
| 10 | Budget consumed 10× faster than allowed — investigate |
| 14 | Budget exhausted in ~2 days of a 30-day window — page now |
| 100 | Total outage — all requests failing |

**Why burn rate beats raw error rate:** A 5% error rate at burn rate 5 is bad but manageable. A 5% error rate at burn rate 500 (because you normally have 0.01% errors) is a major incident. Burn rate captures that difference.

### Multi-Window Alerting

A single 5m window is noisy — a brief spike fires the alert even if the long-term trend is fine. Multi-window alerting requires both a short window (fast-burn detection) and a long window (confirmation) to be true simultaneously.

**Simple fast-burn alert** (page when burn rate > 10 for 5 consecutive minutes):

```yaml
groups:
  - name: slo-alerts
    rules:
      - alert: HighErrorBudgetBurn
        expr: |
          (
            sum(rate(http_requests_total{status=~"5.."}[5m]))
            /
            sum(rate(http_requests_total[5m]))
          ) / 0.01 > 10
        for: 5m
        labels:
          severity: page
        annotations:
          summary: "Error budget burn is too high"
          description: "Service is burning error budget more than 10x faster than allowed."
```

**Advanced: multi-window** (both 5m and 1h windows must confirm):

```promql
(
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
) / 0.01 > 14
and
(
  sum(rate(http_requests_total{status=~"5.."}[1h]))
  /
  sum(rate(http_requests_total[1h]))
) / 0.01 > 14
```

The 5m window catches fast spikes. The 1h window confirms the problem is sustained, not a blip. Both must be true to fire. Threshold 14 means budget exhausted in ~2 days — urgent enough to page, confirmed enough to trust.

### Latency SLO

You can define SLOs on latency using histogram buckets. This query returns the fraction of requests completing under 500ms:

```promql
sum(rate(http_request_duration_seconds_bucket{le="0.5"}[5m]))
/
sum(rate(http_request_duration_seconds_count[5m]))
```

**Latency SLO:** 95% of requests complete under 500ms. The query result must be ≥ 0.95.

This connects directly to Day 14 histogram knowledge: `le="0.5"` is the bucket boundary, and you're computing the fraction of requests that fell into that bucket or below.

## Hands-On

**Step 1:** Run the availability SLI query in Prometheus UI:

```promql
sum(rate(http_requests_total{status!~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

Result should be close to 1.0 on a healthy stack.

**Step 2:** Run the error ratio (complement):

```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

Confirm: availability SLI + error ratio = 1.0.

**Step 3:** Run the burn rate query:

```promql
(
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
)
/
0.01
```

On a healthy stack with no errors this returns 0. Note the value — you'll interpret it in the lab.

**Step 4:** Run the latency SLI:

```promql
sum(rate(http_request_duration_seconds_bucket{le="0.5"}[5m]))
/
sum(rate(http_request_duration_seconds_count[5m]))
```

A value above 0.95 means the latency SLO is being met.

## Key Concepts

**SLI** — measurement (a ratio, 0.0–1.0)
**SLO** — target (e.g., 99% availability)
**Error budget** — allowed failure rate (1 - SLO target)
**Burn rate** — error_ratio / allowed_error_ratio

**Burn rate rules of thumb:**
- < 1: budget spending slower than expected, no concern
- 1–5: normal range, monitor
- 5–14: elevated, investigate
- > 14: page immediately

**Multi-window pattern:** Always confirm fast-burn alerts with a slower window. 5m detects, 1h confirms.

## Lab

See [lab-15-slos-burn-rates.md](../../labs/module-3-promql/lab-15-slos-burn-rates.md)

## Exit Criteria

- [ ] Can write an availability SLI query
- [ ] Can write a burn rate query for any SLO target
- [ ] Understand what burn rate 1, 10, 14 mean in practice
- [ ] Know why multi-window alerting reduces false positives
- [ ] Can write a latency SLO using histogram bucket fraction
- [ ] Have added `HighErrorBudgetBurn` alert to the running stack
