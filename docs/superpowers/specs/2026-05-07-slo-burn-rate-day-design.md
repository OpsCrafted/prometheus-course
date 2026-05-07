# SLO and Burn Rate — Day 15 Design

**Date:** 2026-05-07
**Scope:** Insert new Day 15 (SLOs and Burn Rates) between Day 14 (Histograms) and current Day 15 (Capstone). Capstone renumbers to Day 16.

---

## Problem

Students finish histograms and jump straight into the capstone without understanding how histogram data connects to user-facing reliability targets. They can write `histogram_quantile(0.95, ...)` but cannot answer "is this service meeting its SLO?" or "how fast are we burning error budget?" This gap makes the course feel like tooling education rather than production engineering.

---

## Solution

One day (Day 15) covering SLIs, SLOs, error budget, and burn rate — building entirely on `http_requests_total` and `http_request_duration_seconds_bucket` already present in the sample-app. No new instrumentation required.

---

## File Map

| Action | Path |
|--------|------|
| Create | `docs/module-3-promql/day-15-slos-burn-rates.md` |
| Create | `labs/module-3-promql/lab-15-slos-burn-rates.md` |
| Create | `labs/module-3-promql/solutions/lab-15-solution.md` |
| Rename | `docs/module-3-promql/day-15-capstone.md` → `day-16-capstone.md` |
| Rename | `labs/module-3-promql/lab-15-capstone.md` → `lab-16-capstone.md` |
| Rename | `labs/module-3-promql/solutions/lab-15-solution.md` → `lab-16-solution.md` |
| Update | `Makefile` — rename `verify-day-15` → `verify-day-16`, add new `verify-day-15` |
| Update | `COURSE_INDEX.md` — insert Day 15, renumber capstone to Day 16 |
| Update | `labs/module-3-promql/README.md` — add Day 15 row, update Day 16 |

---

## Day Guide: `day-15-slos-burn-rates.md`

**Time:** 60-90 minutes  
**Prerequisites:** Day 14 (Histograms), running stack with sample-app traffic

### Part 1: Availability SLI

Introduce SLI as a measurement of user experience. Availability = good requests / total requests.

```promql
sum(rate(http_requests_total{status!~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

Explain: non-5xx = "good". Result is a ratio (0.0–1.0). Complement is error ratio:

```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

### Part 2: Define an SLO

SLO = the target. Introduce 99% availability SLO as a beginner-friendly concrete example.

- Availability SLO: 99% (0.99)
- Error budget: 1% (0.01) — allowed failure rate
- Remaining budget query:

```promql
1 - (
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
)
```

Explain why alerting on raw error rate is wrong: a 1% error rate at 10 req/s is very different from 1% at 10,000 req/s.

### Part 3: Burn Rate

Burn rate = how fast the error budget is being consumed relative to the allowed rate.

```promql
(
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
)
/
0.01
```

Interpretation table (include in day guide):

| Burn rate | Meaning |
|-----------|---------|
| 0 | No budget consumption |
| 1 | Consuming budget at exactly the allowed rate |
| 10 | Consuming budget 10× faster than allowed |
| 14 | Budget exhausted in ~1/14 of the window — page now |

### Part 4: Multi-Window Alerting

Simple fast-burn alert (5m window):

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

Advanced multi-window variant (fast-burn must be confirmed by 1h window — reduces false positives):

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

Explain: 5m window detects fast spikes, 1h window confirms the problem is real (not a blip). Both must be true to fire.

### Part 5: Latency SLO

Use histogram bucket to define latency SLI: fraction of requests completing under 500ms.

```promql
sum(rate(http_request_duration_seconds_bucket{le="0.5"}[5m]))
/
sum(rate(http_request_duration_seconds_count[5m]))
```

Define latency SLO: 95% of requests complete under 500ms. Result must be ≥ 0.95.

---

## Lab: `lab-15-slos-burn-rates.md`

**Time:** 30-40 minutes  
**Goal:** Build a complete SLO monitoring setup for the sample-app using the running stack.

### Exercise 1: Availability SLI
Run the availability SLI query in Prometheus UI. Record the value. Confirm error ratio + availability = 1.0.

### Exercise 2: Error Ratio
Run the error ratio query. Confirm it is the complement of Exercise 1.

### Exercise 3: Burn Rate
Run the burn rate query. Interpret the result:
- What does your burn rate mean in plain English?
- At this rate, how long until the monthly error budget is exhausted?

### Exercise 4: Latency SLI
Run the latency SLI query (le="0.5"). Is it above 0.95? If so, the latency SLO is currently met.

### Exercise 5: Alert Rule
Add `HighErrorBudgetBurn` to `labs/alert_rules.yml`. Reload Prometheus config. Verify the alert appears in Status → Rules.

### Exercise 6: Grafana Panel
Create a Grafana panel showing SLO percentage (availability SLI × 100). Add a threshold line at 99 (red below, green above). Take a screenshot — this is your exit artifact.

---

## Solution: `lab-15-solution.md`

Contains:
- All 5 queries with expected output ranges (e.g., availability SLI ≈ 0.95–1.0, burn rate ≈ 0–2 on a healthy stack)
- Complete `HighErrorBudgetBurn` alert YAML (simple version, threshold 10)
- Multi-window variant YAML (threshold 14, `and` condition) in an "Advanced" callout box
- Burn rate interpretation: "burn rate N means budget exhausted in 30d/N days"
- Grafana panel: step-by-step (add panel → Time series → paste availability SLI query → add threshold at 99, color red below)

---

## Makefile: `verify-day-15`

```makefile
verify-day-15:
	@echo "Verifying Day 15 (SLOs and burn rates)..."
	cd labs && docker compose exec prometheus wget -q -O - \
	  'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%7Bstatus!~%225..%22%7D%5B5m%5D))%2Fsum(rate(http_requests_total%5B5m%5D))' \
	  | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null \
	  && echo "✓ availability SLI query returns data" \
	  || (echo "✗ availability SLI query failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - \
	  'http://localhost:9090/api/v1/query?query=(sum(rate(http_requests_total%7Bstatus%3D~%225..%22%7D%5B5m%5D))%2Fsum(rate(http_requests_total%5B5m%5D)))%2F0.01' \
	  | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null \
	  && echo "✓ burn rate query executes" \
	  || (echo "✗ burn rate query failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - \
	  'http://localhost:9090/api/v1/rules' \
	  | jq -e '[.data.groups[].rules[] | select(.name == "HighErrorBudgetBurn")] | length > 0' > /dev/null \
	  && echo "✓ HighErrorBudgetBurn alert loaded" \
	  || (echo "✗ HighErrorBudgetBurn alert not found — add it to alert_rules.yml"; exit 1)
```

---

## COURSE_INDEX.md Changes

- Insert Day 15 entry: SLOs and Burn Rates, `day-15-slos-burn-rates.md`, `lab-15-slos-burn-rates.md`, `lab-15-solution.md`
- Rename Day 15 capstone → Day 16
- Update Module 3 total time (+90 min)

---

## What Does NOT Change

- Sample-app code (no new instrumentation needed)
- Docker Compose
- Any Module 1, 2 content
- Existing alert_rules.yml default content (students add to it in Exercise 5)
- `verify-day-16` behavior (same capstone checks, just renumbered)
