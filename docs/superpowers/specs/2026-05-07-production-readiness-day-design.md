# Production Readiness Checklist — Day 17 Design

**Date:** 2026-05-07
**Scope:** Add Day 17 (Production Readiness Checklist) after Day 16 (Capstone). Builds entirely on existing stack metrics — no new instrumentation required.

---

## Problem

Students finish the capstone knowing how to write PromQL but without a framework for deciding *what* to monitor and *how* to alert responsibly. They can query `http_requests_total` but cannot answer: "Is my service production-ready?" This gap leaves them technically capable but operationally uncertain.

---

## Solution

One day (Day 17) teaching production readiness as a checklist discipline: metrics hygiene, the 4 Golden Signals, 5 essential alerts, anti-patterns to eliminate. Students wire all 5 alerts into the running stack and fill in a reusable checklist template as the exit artifact.

---

## File Map

| Action | Path |
|--------|------|
| Create | `docs/module-3-promql/day-17-production-readiness.md` |
| Create | `labs/module-3-promql/lab-17-production-readiness.md` |
| Create | `labs/module-3-promql/solutions/lab-17-solution.md` |
| Create | `labs/production_readiness_checklist.md` |
| Update | `Makefile` — add `verify-day-17` target + .PHONY + help line |
| Update | `COURSE_INDEX.md` — insert Day 17, update stats |
| Update | `labs/module-3-promql/README.md` — insert Lab 17 row |
| Update | `README.md` — insert Day 17 row in Module 3 table |

---

## Day Guide: `day-17-production-readiness.md`

**Time:** 90 minutes
**Prerequisites:** Days 9-16 completed

### Section 1: Metrics Hygiene

Every service must expose these 4 metric types before it is production-ready:

| Metric | Type | Example |
|--------|------|---------|
| Request count | Counter | `http_requests_total` |
| Error count | Counter | `http_requests_total{status=~"5.."}` |
| Latency | Histogram | `http_request_duration_seconds_bucket` |
| Saturation | Gauge | `node_memory_MemAvailable_bytes` |

**Safe labels** (low cardinality, stable set):
- `method`, `status`, `endpoint` (small finite set of values)

**Unsafe labels** (high cardinality, unbounded):
- User IDs, request IDs, full URLs with path params, IP addresses
- Rule: if the label value could be unique per request, it's unsafe

Verify your stack exposes all 4 types:

```promql
# Counter
http_requests_total

# Histogram
http_request_duration_seconds_bucket

# Gauge
node_memory_MemAvailable_bytes

# Confirm up (target health)
up
```

### Section 2: The 4 Golden Signals

Google SRE defined 4 signals that cover the health of any service. Every alert you write should map to one of these:

| Signal | What it measures | PromQL shape |
|--------|-----------------|--------------|
| **Latency** | How long requests take | `histogram_quantile(0.99, ...)` |
| **Traffic** | How much demand exists | `rate(http_requests_total[5m])` |
| **Errors** | How often requests fail | `rate(...{status=~"5.."}[5m])` |
| **Saturation** | How full resources are | `1 - node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes` |

If you have alerts covering all 4, you will catch almost every production incident.

### Section 3: The 5 Essential Alerts

One alert per golden signal, plus target health. These belong in every production alert_rules.yml.

**1. InstanceDown (Availability)**

```yaml
- alert: InstanceDown
  expr: up{job="sample-app"} == 0
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Instance {{ $labels.instance }} is down"
    description: "Prometheus cannot scrape {{ $labels.instance }} — service may be crashed or unreachable."
```

*Threshold rationale:* 2m `for:` avoids flapping during restarts. Shorter = too noisy; longer = too slow to page.

**2. HighP99Latency (Latency)**

```yaml
- alert: HighP99Latency
  expr: |
    histogram_quantile(0.99,
      sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
    ) > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "P99 latency above 1 second"
    description: "99th percentile request latency is {{ $value | humanizeDuration }} — users are experiencing slow responses."
```

*Threshold rationale:* 1 second is a reasonable user-facing SLO threshold. Adjust to your SLO target. Use p99, not p50 — outliers matter more.

**3. ErrorBudgetBurning (Errors)**

```yaml
- alert: ErrorBudgetBurning
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
    summary: "Error budget burn rate too high"
    description: "Service is burning error budget {{ $value | humanize }}x faster than allowed."
```

*Threshold rationale:* Burn rate > 10 means budget exhausted in 3 days. Connects to Day 15. This is the correct replacement for raw `HighErrorRate` — it captures traffic volume, not just rate.

**4. TrafficDrop (Traffic)**

```yaml
- alert: TrafficDrop
  expr: sum(rate(http_requests_total[5m])) < 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unexpectedly low traffic"
    description: "Request rate dropped below 1 req/s — possible load balancer issue or traffic routing failure."
```

*Threshold rationale:* Traffic drop often means users can't reach the service even when the service itself appears healthy. Tune threshold to your expected baseline.

**5. HighMemorySaturation (Saturation)**

```yaml
- alert: HighMemorySaturation
  expr: |
    (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) > 0.85
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Memory usage above 85%"
    description: "Host memory is {{ $value | humanizePercentage }} used — approaching OOM risk."
```

*Threshold rationale:* 85% leaves headroom before OOM killer fires. 90%+ is critical; 85% gives time to investigate.

### Section 4: Production Anti-Patterns

These patterns appear in many real alert_rules.yml files and cause alert fatigue or missed incidents:

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| Alerting on raw error rate (`> 0.01`) | Fires on 1 error at low traffic | Use burn rate (Day 15) |
| No `for:` clause | Fires on single-sample spikes | Always set `for: 2m` minimum |
| High-cardinality label in alert expr | Generates thousands of alert instances | Filter to job/service level |
| Alert fires when nobody is awake | No severity routing | Use `severity: page` vs `warning` deliberately |
| No `description` annotation | On-call has no context | Always include what and why |

---

## Lab: `lab-17-production-readiness.md`

**Time:** 40 minutes
**Goal:** Wire up all 5 production alerts, audit the existing alerts for anti-patterns, and complete the production readiness checklist for the sample-app.

### Exercise 1: Metrics Hygiene Audit

Run each query. Confirm result is non-empty.

```promql
http_requests_total
http_request_duration_seconds_bucket
node_memory_MemAvailable_bytes
up
```

**Question:** Do all 4 metric types exist in your stack? Record yes/no for each.

### Exercise 2: Add the 5 Essential Alerts

Add a new group to `labs/alert_rules.yml`:

```yaml
  - name: production-readiness
    rules:
      # [all 5 alerts — exact YAML from day guide]
```

Reload Prometheus:

```bash
cd labs && docker compose exec prometheus kill -HUP 1
```

Verify all 5 alert names appear:

```bash
curl -s http://localhost:9090/api/v1/rules | jq '[.data.groups[].rules[] | select(.name | test("InstanceDown|HighP99Latency|ErrorBudgetBurning|TrafficDrop|HighMemorySaturation"))] | length'
```

Expected: `5`

### Exercise 3: 4-Panel Golden Signals Dashboard

Create a Grafana dashboard with one panel per golden signal:

| Panel | Query |
|-------|-------|
| Latency (p99) | `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))` |
| Traffic | `sum(rate(http_requests_total[5m]))` |
| Error rate | `sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))` |
| Saturation | `1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes` |

### Exercise 4: Anti-Pattern Audit

Open `labs/alert_rules.yml`. Find the existing `app_alerts` group. Identify:
1. Which alert uses raw error rate instead of burn rate?
2. Which alerts are missing a `description` annotation?
3. Do any alerts lack a `for:` clause?

*(Answers in solution.)*

### Exercise 5: Fill In the Production Readiness Checklist

Open `labs/production_readiness_checklist.md`. Fill in each checkbox for the sample-app. This is your exit artifact — a completed checklist you can reuse for any service you instrument.

---

## Solution: `lab-17-solution.md`

Contains:
- Exercise 1: All 4 queries with expected output (non-empty results)
- Exercise 2: Complete YAML for all 5 alerts in `production-readiness` group
- Exercise 3: Grafana step-by-step for 4-panel dashboard
- Exercise 4: Anti-pattern answers (HighErrorRate uses raw rate instead of burn rate; all 4 existing alerts lack `description` annotation — only `summary` present; all have `for:` clauses so none missing)
- Exercise 5: Completed checklist for sample-app

---

## Checklist Artifact: `labs/production_readiness_checklist.md`

```markdown
# Production Readiness Checklist

Service: _______________
Date: _______________

## Metrics Hygiene
- [ ] Request counter exposed (`*_requests_total` or `*_total`)
- [ ] Error counter or error label on request counter
- [ ] Latency histogram exposed (`*_duration_seconds_bucket`)
- [ ] Saturation gauge (memory, CPU, queue depth, or disk)
- [ ] All labels have bounded cardinality (no user IDs, request IDs, raw URLs)

## Alerting
- [ ] InstanceDown alert (target not scraping)
- [ ] Latency alert (p99 threshold)
- [ ] Error alert (burn rate, not raw error rate)
- [ ] Traffic alert (unexpected drop)
- [ ] Saturation alert (memory or CPU)
- [ ] All alerts have `for:` clause (minimum 2m)
- [ ] All alerts have `summary` and `description` annotations
- [ ] `severity` label set on all alerts (page vs warning)

## Dashboards
- [ ] One panel per golden signal (latency, traffic, errors, saturation)
- [ ] SLO panel showing availability % with threshold line

## SLO
- [ ] Availability SLI defined (good requests / total requests)
- [ ] SLO target set (e.g., 99%)
- [ ] Error budget calculated (1 - SLO target)
- [ ] Burn rate alert wired up

## Anti-Patterns Eliminated
- [ ] No raw error rate alerts (replaced with burn rate)
- [ ] No high-cardinality labels in alert expressions
- [ ] No alerts without `for:` clause
- [ ] No alerts without annotations
```

---

## Makefile: `verify-day-17`

```makefile
verify-day-17:
	@echo "Verifying Day 17 (production readiness)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "InstanceDown")] | length > 0' > /dev/null && echo "✓ InstanceDown alert loaded" || (echo "✗ InstanceDown not found — add production-readiness group to alert_rules.yml"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "HighP99Latency")] | length > 0' > /dev/null && echo "✓ HighP99Latency alert loaded" || (echo "✗ HighP99Latency not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "ErrorBudgetBurning")] | length > 0' > /dev/null && echo "✓ ErrorBudgetBurning alert loaded" || (echo "✗ ErrorBudgetBurning not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "TrafficDrop")] | length > 0' > /dev/null && echo "✓ TrafficDrop alert loaded" || (echo "✗ TrafficDrop not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "HighMemorySaturation")] | length > 0' > /dev/null && echo "✓ HighMemorySaturation alert loaded" || (echo "✗ HighMemorySaturation not found"; exit 1)
```

---

## COURSE_INDEX.md Changes

- Insert Day 17 entry after Day 16
- Update stats: Day guides 16→17, Labs 16→17, Solutions 16→17
- Module 3 total: 12h → 13.5h
- Total core path: ~29.5h → ~31h

---

## What Does NOT Change

- Sample-app code (no new instrumentation)
- Docker Compose
- Module 1, 2 content
- Existing alert_rules.yml default groups (students add to it)
- Day 16 capstone content
