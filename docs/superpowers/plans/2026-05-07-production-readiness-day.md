# Production Readiness Checklist — Day 17 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Day 17 (Production Readiness Checklist) as the final day of the Prometheus course, covering metrics hygiene, the 4 Golden Signals, 5 essential production alerts, and anti-patterns, with a reusable checklist artifact.

**Architecture:** Five sequential tasks — checklist artifact first (standalone), then day guide, lab, solution, then wire up verification and navigation. No code changes; all work is markdown, YAML, and Makefile.

**Tech Stack:** Markdown, YAML (alert rules), GNU Make, Prometheus HTTP API, jq, wget.

---

## File Map

| Action | Path |
|--------|------|
| Create | `labs/production_readiness_checklist.md` |
| Create | `docs/module-3-promql/day-17-production-readiness.md` |
| Create | `labs/module-3-promql/lab-17-production-readiness.md` |
| Create | `labs/module-3-promql/solutions/lab-17-solution.md` |
| Modify | `Makefile` — add `verify-day-17` target, .PHONY, help line |
| Modify | `COURSE_INDEX.md` — insert Day 17, update stats |
| Modify | `labs/module-3-promql/README.md` — insert Lab 17 row, update scope line |
| Modify | `README.md` — insert Day 17 row in Module 3 table |

---

### Task 1: Create the production readiness checklist artifact

**Files:**
- Create: `labs/production_readiness_checklist.md`

- [ ] **Step 1: Create the checklist file**

Create `labs/production_readiness_checklist.md` with this exact content:

```markdown
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
```

- [ ] **Step 2: Verify**

```bash
grep "## Alerting\|## SLO\|## Metrics Hygiene\|## Anti-Patterns" labs/production_readiness_checklist.md | wc -l
```

Expected: `4`

- [ ] **Step 3: Commit**

```bash
git add labs/production_readiness_checklist.md
git commit -m "feat: add production readiness checklist template"
```

---

### Task 2: Create Day 17 guide

**Files:**
- Create: `docs/module-3-promql/day-17-production-readiness.md`

- [ ] **Step 1: Create the guide**

Create `docs/module-3-promql/day-17-production-readiness.md` with this exact content:

```markdown
# Day 17: Production Readiness Checklist

**Time:** 90 minutes | **Prerequisites:** Days 9-16 completed

## Learning Outcomes

- [ ] Know which 4 metric types every service must expose
- [ ] Distinguish safe labels from unsafe labels
- [ ] Map the 4 Golden Signals to PromQL queries
- [ ] Write all 5 essential production alerts with correct YAML
- [ ] Identify common alerting anti-patterns
- [ ] Complete a production readiness checklist for a live service

## Section 1: Metrics Hygiene

Before a service is production-ready it must expose four metric types. These cover all dimensions needed to answer "is this service healthy?":

| Metric type | What it measures | Example |
|-------------|-----------------|---------|
| **Counter** (requests) | Total demand received | `http_requests_total` |
| **Counter** (errors) | Total failures | `http_requests_total{status=~"5.."}` |
| **Histogram** (latency) | Distribution of request duration | `http_request_duration_seconds_bucket` |
| **Gauge** (saturation) | Resource utilization | `node_memory_MemAvailable_bytes` |

If any of these is missing, you have a blind spot.

### Safe vs Unsafe Labels

Labels are powerful but dangerous. The rule: **label values must come from a small, bounded set**.

**Safe labels** (finite, predictable values):
- `method` — GET, POST, PUT, DELETE
- `status` — 200, 404, 500
- `endpoint` — /api/users, /health, /metrics
- `job`, `instance` — set by Prometheus at scrape time

**Unsafe labels** (unbounded, unique per request):
- User IDs — `user_id="8f3a2b1c"`
- Request IDs — `request_id="abc-def-123"`
- Full URLs — `path="/api/users/8f3a2b1c/orders/99"`
- IP addresses — `client_ip="192.168.1.42"`

Unsafe labels cause **cardinality explosion**: one unique value per request means millions of time series. Prometheus will run out of memory.

**Rule of thumb:** if the label value could be unique per request, it is unsafe. Use it in logs, not metrics.

Verify your stack exposes all 4 metric types:

```promql
# 1. Request counter
http_requests_total

# 2. Latency histogram
http_request_duration_seconds_bucket

# 3. Memory saturation gauge
node_memory_MemAvailable_bytes

# 4. Target health
up
```

Each should return at least one result.

## Section 2: The 4 Golden Signals

Google's SRE book defines 4 signals that together describe the health of any service. Every production alert maps to one of these:

| Signal | What it measures | Query shape |
|--------|-----------------|-------------|
| **Latency** | How long requests take | `histogram_quantile(0.99, ...)` |
| **Traffic** | How much demand the service receives | `rate(http_requests_total[5m])` |
| **Errors** | How often requests fail | `rate(...{status=~"5.."}[5m])` |
| **Saturation** | How close resources are to their limit | `1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes` |

If you have alerts covering all 4 signals, you will catch the overwhelming majority of production incidents.

## Section 3: The 5 Essential Alerts

One alert per golden signal plus target health. These belong in every production `alert_rules.yml`.

### 1. InstanceDown (Availability)

```yaml
- alert: InstanceDown
  expr: up{job="sample-app"} == 0
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Instance {{ $labels.instance }} is down"
    description: "Prometheus cannot scrape {{ $labels.instance }}. Service may be crashed or unreachable."
```

**Why `for: 2m`:** A brief restart clears in under 2 minutes. Without `for:`, every deployment pages on-call.

### 2. HighP99Latency (Latency)

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
    description: "99th percentile request latency is {{ $value | humanizeDuration }}. Users are experiencing slow responses."
```

**Why p99 not p50:** The median hides outliers. 1% of requests at p99 often represents your worst-affected users.

### 3. ErrorBudgetBurning (Errors)

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

**Why burn rate not raw error rate:** A 2% error rate at 10 req/s is fine. A 2% error rate at 10,000 req/s is a major incident. Burn rate captures that difference. (See Day 15 for full explanation.)

### 4. TrafficDrop (Traffic)

```yaml
- alert: TrafficDrop
  expr: sum(rate(http_requests_total[5m])) < 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Unexpectedly low traffic"
    description: "Request rate dropped below 1 req/s. Possible load balancer issue or upstream traffic routing failure."
```

**Why traffic matters:** A service can appear healthy (no errors, low latency) while receiving zero traffic because something upstream is broken. Traffic drop is an independent signal.

### 5. HighMemorySaturation (Saturation)

```yaml
- alert: HighMemorySaturation
  expr: |
    (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) > 0.85
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Memory usage above 85%"
    description: "Host memory is {{ $value | humanizePercentage }} used. Approaching OOM risk."
```

**Why 85%:** Linux may start evicting pages around 90%. Alerting at 85% gives time to investigate before the OOM killer fires.

## Section 4: Production Anti-Patterns

These patterns appear frequently in real alert_rules.yml files and cause alert fatigue or missed incidents:

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| Alerting on raw error rate (`> 0.05`) | Fires at low traffic on 1–2 errors | Use burn rate (Day 15) |
| No `for:` clause | Fires on single-scrape spikes | Always set `for: 2m` minimum |
| High-cardinality label in expr | One alert instance per unique label value | Filter to job or service level |
| No `description` annotation | On-call has no context when paged | Include what happened and why it matters |
| Using p50 for latency alerts | Median hides tail-latency problems | Use p95 or p99 |
| Alerting on everything | Noise desensitizes on-call | Alert only on user-impacting symptoms |

The existing `app_alerts` group in this course has some of these. You will identify them in the lab.

## Hands-On

**Step 1:** Run all 4 metric hygiene queries in Prometheus UI at http://localhost:9090. Confirm each returns at least one result.

**Step 2:** Add all 5 essential alerts to `labs/alert_rules.yml` under a new `production-readiness` group (full YAML in lab Exercise 2).

**Step 3:** Reload Prometheus:

```bash
cd labs && docker compose exec prometheus kill -HUP 1
```

**Step 4:** Verify all 5 alerts loaded:

```bash
curl -s http://localhost:9090/api/v1/rules | jq '[.data.groups[].rules[] | select(.name | test("InstanceDown|HighP99Latency|ErrorBudgetBurning|TrafficDrop|HighMemorySaturation"))] | length'
```

Expected: `5`

## Key Concepts

**Cardinality** — number of unique time series. High cardinality = memory pressure.
**Golden Signals** — Latency, Traffic, Errors, Saturation. Alerts covering all 4 catch most incidents.
**`for:` clause** — alert must be true for this duration before firing. Prevents alert flapping on transient spikes.
**Burn rate** — correct unit for error alerting. Captures impact at any traffic volume.

## Lab

See [lab-17-production-readiness.md](../../labs/module-3-promql/lab-17-production-readiness.md)

## Exit Criteria

- [ ] All 4 metric types confirmed present in the running stack
- [ ] All 5 production-readiness alerts appear in Prometheus Status → Rules
- [ ] 4-panel Golden Signals dashboard built in Grafana
- [ ] Anti-patterns in existing `app_alerts` identified
- [ ] Production readiness checklist filled in for sample-app
```

- [ ] **Step 2: Verify**

```bash
grep "InstanceDown\|HighP99Latency\|ErrorBudgetBurning\|TrafficDrop\|HighMemorySaturation" docs/module-3-promql/day-17-production-readiness.md | wc -l
```

Expected: at least 10 matches (each alert name appears multiple times across YAML and text)

```bash
grep "## Exit Criteria" docs/module-3-promql/day-17-production-readiness.md
```

Expected: one match

- [ ] **Step 3: Commit**

```bash
git add docs/module-3-promql/day-17-production-readiness.md
git commit -m "feat: add Day 17 guide — production readiness checklist"
```

---

### Task 3: Create Lab 17

**Files:**
- Create: `labs/module-3-promql/lab-17-production-readiness.md`

- [ ] **Step 1: Create the lab**

Create `labs/module-3-promql/lab-17-production-readiness.md` with this exact content:

```markdown
# Lab 17: Production Readiness Checklist

**Time:** 40 minutes
**Goal:** Wire up all 5 production alerts, audit existing alerts for anti-patterns, build the Golden Signals dashboard, and complete the production readiness checklist for the sample-app.

## Background

You have a running stack with `http_requests_total`, `http_request_duration_seconds_bucket`, `node_memory_MemAvailable_bytes`, and `up`. The existing `labs/alert_rules.yml` has an `app_alerts` group — you will audit it for anti-patterns and add a new `production-readiness` group with the 5 essential alerts.

## Exercise 1: Metrics Hygiene Audit

Run each query in the Prometheus UI at http://localhost:9090. Confirm each returns at least one result.

```promql
http_requests_total
```

Result non-empty? ___

```promql
http_request_duration_seconds_bucket
```

Result non-empty? ___

```promql
node_memory_MemAvailable_bytes
```

Result non-empty? ___

```promql
up
```

Result non-empty? ___

All 4 must be present before a service is considered metrics-complete.

## Exercise 2: Add the 5 Essential Alerts

Open `labs/alert_rules.yml`. Add a new group **after** the existing `app_alerts` group (and after any `slo-alerts` group if present from Day 15):

```yaml
  - name: production-readiness
    rules:
      - alert: InstanceDown
        expr: up{job="sample-app"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} is down"
          description: "Prometheus cannot scrape {{ $labels.instance }}. Service may be crashed or unreachable."

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
          description: "99th percentile request latency is {{ $value | humanizeDuration }}. Users are experiencing slow responses."

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

      - alert: TrafficDrop
        expr: sum(rate(http_requests_total[5m])) < 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Unexpectedly low traffic"
          description: "Request rate dropped below 1 req/s. Possible load balancer issue or upstream traffic routing failure."

      - alert: HighMemorySaturation
        expr: |
          (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Memory usage above 85%"
          description: "Host memory is {{ $value | humanizePercentage }} used. Approaching OOM risk."
```

Reload Prometheus:

```bash
cd labs && docker compose exec prometheus kill -HUP 1
```

Wait 5 seconds, then verify all 5 loaded:

```bash
curl -s http://localhost:9090/api/v1/rules | jq '[.data.groups[].rules[] | select(.name | test("InstanceDown|HighP99Latency|ErrorBudgetBurning|TrafficDrop|HighMemorySaturation"))] | length'
```

Expected: `5`

Open Prometheus UI → Status → Rules. Confirm `production-readiness` group appears with 5 rules.

## Exercise 3: 4-Panel Golden Signals Dashboard

Build a Grafana dashboard at http://localhost:3000 (admin/admin) with one panel per golden signal.

1. **Dashboards → New → New Dashboard → Add visualization**
2. Data source: **Prometheus**

**Panel 1 — Latency (p99)**
- Query: `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))`
- Title: `P99 Latency`
- Unit (Standard options): `seconds (s)`

**Panel 2 — Traffic**
- Query: `sum(rate(http_requests_total[5m]))`
- Title: `Request Rate`
- Unit: `requests/sec (reqps)`

**Panel 3 — Errors**
- Query: `sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))`
- Title: `Error Ratio`
- Unit: `Percent (0.0-1.0)`

**Panel 4 — Saturation**
- Query: `1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes`
- Title: `Memory Saturation`
- Unit: `Percent (0.0-1.0)`

Save the dashboard as **Golden Signals**.

## Exercise 4: Anti-Pattern Audit

Open `labs/alert_rules.yml` and inspect the existing `app_alerts` group. Answer:

1. Which alert uses raw error rate instead of burn rate?
2. Which alerts are missing a `description` annotation?
3. Do any alerts lack a `for:` clause?

*(Check your answers in the solution.)*

## Exercise 5: Fill In the Checklist

Open `labs/production_readiness_checklist.md`. Work through each checkbox for the sample-app based on what you have wired up in this lab. Check off items that are done. Leave unchecked items that remain gaps.

This is your exit artifact — a completed checklist you can reuse for any service you instrument.

## Solution

See `labs/module-3-promql/solutions/lab-17-solution.md`

## Exit Criteria

- [ ] All 4 metric types return results in Prometheus UI
- [ ] `production-readiness` group appears in Status → Rules with 5 alerts
- [ ] 4-panel Golden Signals dashboard saved in Grafana
- [ ] Anti-pattern questions answered
- [ ] Production readiness checklist filled in
```

- [ ] **Step 2: Verify**

```bash
grep "Exercise\|Exit Criteria\|production-readiness" labs/module-3-promql/lab-17-production-readiness.md | wc -l
```

Expected: at least 10 matches

- [ ] **Step 3: Commit**

```bash
git add labs/module-3-promql/lab-17-production-readiness.md
git commit -m "feat: add Lab 17 — production readiness exercises"
```

---

### Task 4: Create Lab 17 Solution

**Files:**
- Create: `labs/module-3-promql/solutions/lab-17-solution.md`

- [ ] **Step 1: Create the solution**

Create `labs/module-3-promql/solutions/lab-17-solution.md` with this exact content:

```markdown
# Lab 17 Solution: Production Readiness Checklist

## Exercise 1: Metrics Hygiene Audit

All 4 queries should return non-empty results on the running stack:

- `http_requests_total` — sample-app exposes this counter ✓
- `http_request_duration_seconds_bucket` — sample-app histogram ✓
- `node_memory_MemAvailable_bytes` — node-exporter gauge ✓
- `up` — Prometheus scrape health, one series per target ✓

If any query returns empty, the corresponding service may not be running. Check with:

```bash
cd labs && docker compose ps
```

## Exercise 2: The 5 Essential Alerts

After adding the `production-readiness` group and reloading:

```bash
curl -s http://localhost:9090/api/v1/rules | jq '[.data.groups[].rules[] | select(.name | test("InstanceDown|HighP99Latency|ErrorBudgetBurning|TrafficDrop|HighMemorySaturation"))] | length'
```

Expected output: `5`

If you see fewer than 5, check YAML indentation in `alert_rules.yml`. The `production-readiness` group must be at the same level as `app_alerts` — a child of `groups:`, not nested inside another group.

**Correct structure:**

```yaml
groups:
  - name: app_alerts        # existing group
    rules:
      # ...

  - name: production-readiness   # new group — same indent level as app_alerts
    rules:
      # ...
```

## Exercise 3: 4-Panel Dashboard

| Panel | Query | Expected range (healthy stack) |
|-------|-------|-------------------------------|
| P99 Latency | `histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))` | 0.01–0.5s |
| Request Rate | `sum(rate(http_requests_total[5m]))` | 1–50 req/s |
| Error Ratio | `sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))` | 0.0–0.05 |
| Memory Saturation | `1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes` | 0.3–0.8 |

## Exercise 4: Anti-Pattern Audit

**1. Which alert uses raw error rate?**

`HighErrorRate` — `expr: ... > 0.05` is a raw threshold, not burn rate. At low traffic (e.g., 2 req/s) a single 500 response crosses this threshold. The correct version uses `/ 0.01 > 10` (burn rate) as shown in the Day 15 and Day 17 guides.

**2. Which alerts are missing `description`?**

All 4 existing alerts — `TargetDown`, `HighErrorRate`, `HighP95Latency`, `LowTraffic`. Each has only `summary`. On-call engineers need `description` to understand impact without reading source code.

**3. Any alerts missing `for:` clause?**

No — all existing alerts have `for:` set. This part of the existing config is correct.

## Exercise 5: Checklist — Sample-App

```markdown
# Production Readiness Checklist

Service: sample-app
Date: [today]

## Metrics Hygiene
- [x] Request counter exposed (http_requests_total)
- [x] Error counter or error label on request counter (status label with 5xx values)
- [x] Latency histogram exposed (http_request_duration_seconds_bucket)
- [x] Saturation gauge (node_memory_MemAvailable_bytes via node-exporter)
- [x] All labels have bounded cardinality (method, status, endpoint — all finite)

## Alerting
- [x] InstanceDown alert (target not scraping — production-readiness group)
- [x] HighLatency alert (HighP99Latency — p99 > 1s)
- [x] Error alert (ErrorBudgetBurning — burn rate, not raw rate)
- [x] Traffic alert (TrafficDrop — < 1 req/s)
- [x] Saturation alert (HighMemorySaturation — > 85%)
- [x] All production-readiness alerts have for: clause (2m or 5m)
- [x] All production-readiness alerts have summary and description annotations
- [x] severity label set (critical / warning / page)

## Dashboards
- [x] One panel per golden signal (latency, traffic, errors, saturation)
- [x] SLO panel showing availability % with threshold line (from Day 15 lab)

## SLO
- [x] Availability SLI defined (good requests / total requests — Day 15)
- [x] SLO target set (99%)
- [x] Error budget calculated (0.01)
- [x] Burn rate alert wired up (ErrorBudgetBurning)

## Anti-Patterns Eliminated
- [ ] No raw error rate alerts — HighErrorRate in app_alerts still uses raw rate (identified but not fixed in this lab)
- [x] No high-cardinality labels in alert expressions
- [x] No alerts without for: clause
- [ ] No alerts without annotations — app_alerts group still missing description fields
```

Note: The `app_alerts` gaps are intentional. The lab asks you to identify them, not fix them. In a real production setup you would update or replace those alerts.

## Key Patterns

- 4 metric types = complete observability surface: counter (requests), counter (errors), histogram (latency), gauge (saturation)
- 4 Golden Signals = Latency + Traffic + Errors + Saturation — every production alert maps to one of these
- `for: 2m` minimum prevents flapping during restarts and brief spikes
- Burn rate > raw error rate: captures traffic volume, not just ratio
- `description` annotation = on-call context without reading source code
- The checklist is a tool, not a checkbox exercise — gaps are expected on first pass; the goal is visibility
```

- [ ] **Step 2: Verify**

```bash
grep "Exercise\|Anti-Pattern\|Golden Signal\|burn rate" labs/module-3-promql/solutions/lab-17-solution.md | wc -l
```

Expected: at least 10 matches

- [ ] **Step 3: Commit**

```bash
git add labs/module-3-promql/solutions/lab-17-solution.md
git commit -m "feat: add Lab 17 solution — production readiness answers"
```

---

### Task 5: Wire up verify-day-17 and update navigation

**Files:**
- Modify: `Makefile` — add `verify-day-17` target, .PHONY entry, help line
- Modify: `COURSE_INDEX.md` — insert Day 17 entry, update stats
- Modify: `labs/module-3-promql/README.md` — insert Lab 17 row, update scope line
- Modify: `README.md` — insert Day 17 row in Module 3 table

- [ ] **Step 1: Add verify-day-17 to Makefile .PHONY**

In `Makefile` line 1, find:

```
.PHONY: setup verify down clean reset logs-prometheus logs-grafana logs-app verify-rules verify-day-5 verify-day-9 verify-day-10 verify-day-12 verify-day-13 verify-day-15 verify-day-16 verify-day-11 verify-day-14 help
```

Replace with:

```
.PHONY: setup verify down clean reset logs-prometheus logs-grafana logs-app verify-rules verify-day-5 verify-day-9 verify-day-10 verify-day-12 verify-day-13 verify-day-15 verify-day-16 verify-day-17 verify-day-11 verify-day-14 help
```

- [ ] **Step 2: Add verify-day-17 help line**

In the `help` target, find:

```
	@echo "  make verify-day-16      — Verify Day 16 (PromQL capstone)"
```

Replace with:

```
	@echo "  make verify-day-16      — Verify Day 16 (PromQL capstone)"
	@echo "  make verify-day-17      — Verify Day 17 (production readiness)"
```

- [ ] **Step 3: Add verify-day-17 target block**

Add the following block immediately after the `verify-day-16` target block (which ends after its last `cd labs && docker compose exec prometheus ...` line):

```makefile
verify-day-17:
	@echo "Verifying Day 17 (production readiness)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "InstanceDown")] | length > 0' > /dev/null && echo "✓ InstanceDown alert loaded" || (echo "✗ InstanceDown not found — add production-readiness group to labs/alert_rules.yml"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "HighP99Latency")] | length > 0' > /dev/null && echo "✓ HighP99Latency alert loaded" || (echo "✗ HighP99Latency not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "ErrorBudgetBurning")] | length > 0' > /dev/null && echo "✓ ErrorBudgetBurning alert loaded" || (echo "✗ ErrorBudgetBurning not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "TrafficDrop")] | length > 0' > /dev/null && echo "✓ TrafficDrop alert loaded" || (echo "✗ TrafficDrop not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "HighMemorySaturation")] | length > 0' > /dev/null && echo "✓ HighMemorySaturation alert loaded" || (echo "✗ HighMemorySaturation not found"; exit 1)
```

- [ ] **Step 4: Insert Day 17 entry in COURSE_INDEX.md**

In `COURSE_INDEX.md`, find:

```
**Total Module 3:** 12 hours
```

Insert the following block immediately before it (after the Day 16 block):

```markdown
### Day 17: Production Readiness Checklist
- **Guide:** `docs/module-3-promql/day-17-production-readiness.md`
- **Lab:** `labs/module-3-promql/lab-17-production-readiness.md`
- **Solution:** `labs/module-3-promql/solutions/lab-17-solution.md`
- **Artifact:** `labs/production_readiness_checklist.md`
- **Topics:** Metrics hygiene, safe labels, 4 Golden Signals, 5 essential alerts, anti-patterns
- **Time:** 90 minutes

```

- [ ] **Step 5: Update COURSE_INDEX.md stats**

Find:
```
**Total Module 3:** 12 hours
```
Replace with:
```
**Total Module 3:** 13.5 hours
```

Find:
```
| Day guides | 16 |
| Labs | 16 |
| Solutions | 16 |
```
Replace with:
```
| Day guides | 17 |
| Labs | 17 |
| Solutions | 17 |
```

Find:
```
| Module 3: PromQL | 12 hours |
```
Replace with:
```
| Module 3: PromQL | 13.5 hours |
```

Find:
```
| **Total (core path)** | **~29.5 hours** |
```
Replace with:
```
| **Total (core path)** | **~31 hours** |
```

- [ ] **Step 6: Insert Lab 17 row in labs/module-3-promql/README.md**

Find:
```
Labs for Days 9–16. Run queries at http://localhost:9090.
```
Replace with:
```
Labs for Days 9–17. Run queries at http://localhost:9090.
```

Find:
```
| Lab 16 | [lab-16-capstone.md](lab-16-capstone.md) | Multi-step real-world queries: SLA monitoring, capacity planning |
```
Replace with:
```
| Lab 16 | [lab-16-capstone.md](lab-16-capstone.md) | Multi-step real-world queries: SLA monitoring, capacity planning |
| Lab 17 | [lab-17-production-readiness.md](lab-17-production-readiness.md) | 5 essential alerts, Golden Signals dashboard, production readiness checklist |
```

- [ ] **Step 7: Insert Day 17 row in root README.md**

In `README.md`, find:

```
| 1️⃣6️⃣ | [Capstone](docs/module-3-promql/day-16-capstone.md) | 4-6h | 3 real-world challenges |
```

Replace with:

```
| 1️⃣6️⃣ | [Capstone](docs/module-3-promql/day-16-capstone.md) | 4-6h | 3 real-world challenges |
| 1️⃣7️⃣ | [Production Readiness](docs/module-3-promql/day-17-production-readiness.md) | 90m | 5 essential alerts, Golden Signals, checklist |
```

- [ ] **Step 8: Verify**

```bash
grep -r "day-17\|lab-17\|verify-day-17\|Day 17" --include="*.md" --include="Makefile" . | grep -v "superpowers" | grep -v "Binary"
```

Expected: matches in Makefile, COURSE_INDEX.md, labs/module-3-promql/README.md, README.md, plus the new files themselves.

- [ ] **Step 9: Commit**

```bash
git add Makefile COURSE_INDEX.md labs/module-3-promql/README.md README.md
git commit -m "feat: add verify-day-17 target and update course navigation for Day 17"
```

---

## Self-Review

**Spec coverage:**
- ✓ `labs/production_readiness_checklist.md` — Task 1
- ✓ `docs/module-3-promql/day-17-production-readiness.md` — Task 2
- ✓ `labs/module-3-promql/lab-17-production-readiness.md` — Task 3
- ✓ `labs/module-3-promql/solutions/lab-17-solution.md` — Task 4
- ✓ Makefile verify-day-17 (5 checks, one per alert) — Task 5
- ✓ COURSE_INDEX.md Day 17 entry + stats — Task 5
- ✓ labs/module-3-promql/README.md Lab 17 row — Task 5
- ✓ README.md Day 17 row — Task 5

**Placeholder scan:** No TBD, TODO, or incomplete sections. All YAML is complete. All queries present.

**Type consistency:** Alert names consistent across day guide, lab, solution, and verify-day-17 checks: `InstanceDown`, `HighP99Latency`, `ErrorBudgetBurning`, `TrafficDrop`, `HighMemorySaturation`.
