# Production Readiness Checklist

**Service:** _______________
**Date:** _______________
**Filled in by:** _______________

Use this checklist before promoting any service to production monitoring. Each unchecked item is a monitoring gap.

---

## Metrics Hygiene

- [ ] Request counter exposed (`*_requests_total` or similar counter)
- [ ] Error counter or error label on request counter (e.g., `status` label with 5xx values)
- [ ] Latency histogram exposed (`*_duration_seconds_bucket`)
- [ ] Saturation gauge (memory, CPU, queue depth, or disk)
- [ ] All label values have bounded cardinality (no user IDs, request IDs, raw URLs, IP addresses)

---

## Alerting

- [ ] **InstanceDown** — alert fires when Prometheus cannot scrape the service (`up == 0`)
- [ ] **HighLatency** — p99 latency alert (use histogram_quantile, not average)
- [ ] **ErrorBudgetBurning** — error alert using burn rate, not raw error rate
- [ ] **TrafficDrop** — alert for unexpected traffic decline
- [ ] **HighSaturation** — memory or CPU saturation alert
- [ ] All alerts have `for:` clause (minimum 2m to prevent flapping)
- [ ] All alerts have `summary` annotation (one-line description of what fired)
- [ ] All alerts have `description` annotation (what it means, what to check first)
- [ ] `severity` label set on all alerts (`critical` / `page` / `warning`)

---

## Dashboards

- [ ] One panel per golden signal: latency (p99), traffic (req/s), error ratio, saturation
- [ ] SLO panel showing availability % with threshold line at SLO target

---

## SLO

- [ ] Availability SLI defined: `sum(rate(good_requests[5m])) / sum(rate(total_requests[5m]))`
- [ ] SLO target set (e.g., 99%, 99.5%, 99.9%)
- [ ] Error budget calculated: `1 - SLO_target` (e.g., 0.01 for 99% SLO)
- [ ] Burn rate alert wired up with correct divisor

---

## Anti-Patterns Eliminated

- [ ] No raw error rate alerts (replaced with burn rate)
- [ ] No high-cardinality labels in metric or alert expressions
- [ ] No alerts without `for:` clause
- [ ] No alerts without `description` annotation
- [ ] Alert severity levels reflect actual on-call impact (not everything is `critical`)

---

## Notes

_Use this section to document any gaps, outstanding decisions, or context for future reviewers._
