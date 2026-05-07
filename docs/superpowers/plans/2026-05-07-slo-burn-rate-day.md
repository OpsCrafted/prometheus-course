# SLO and Burn Rate — Day 15 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Insert Day 15 (SLOs and Burn Rates) between Day 14 (Histograms) and the current capstone, renumbering the capstone to Day 16 throughout.

**Architecture:** Five sequential tasks — rename capstone files first (establishes clean state), then create new Day 15 content (guide, lab, solution), then wire up verification and update navigation. No code changes; all work is markdown and Makefile.

**Tech Stack:** Markdown, YAML (alert rule), GNU Make, Prometheus HTTP API, jq, wget.

---

## File Map

| Action | Path |
|--------|------|
| `git mv` | `docs/module-3-promql/day-15-capstone.md` → `day-16-capstone.md` |
| `git mv` | `labs/module-3-promql/lab-15-capstone.md` → `lab-16-capstone.md` |
| `git mv` | `labs/module-3-promql/solutions/lab-15-solution.md` → `lab-16-solution.md` |
| Modify | `docs/module-3-promql/day-16-capstone.md` — fix internal link |
| Modify | `Makefile` — rename verify-day-15 → verify-day-16, add new verify-day-15 |
| Modify | `COURSE_INDEX.md` — rename Day 15 → Day 16, insert Day 15, update stats |
| Modify | `labs/module-3-promql/README.md` — rename Lab 15 → Lab 16, insert Lab 15 row |
| Create | `docs/module-3-promql/day-15-slos-burn-rates.md` |
| Create | `labs/module-3-promql/lab-15-slos-burn-rates.md` |
| Create | `labs/module-3-promql/solutions/lab-15-solution.md` |

---

### Task 1: Rename capstone 15 → 16

**Files:**
- `git mv` three files
- Modify: `docs/module-3-promql/day-16-capstone.md` (fix internal link)
- Modify: `Makefile` (rename target + .PHONY + help)
- Modify: `COURSE_INDEX.md` (rename Day 15 entry)
- Modify: `labs/module-3-promql/README.md` (rename row)

- [ ] **Step 1: Rename the three files**

```bash
git mv docs/module-3-promql/day-15-capstone.md docs/module-3-promql/day-16-capstone.md
git mv labs/module-3-promql/lab-15-capstone.md labs/module-3-promql/lab-16-capstone.md
git mv labs/module-3-promql/solutions/lab-15-solution.md labs/module-3-promql/solutions/lab-16-solution.md
```

- [ ] **Step 2: Fix internal link in day-16-capstone.md**

In `docs/module-3-promql/day-16-capstone.md`, find:
```
See [lab-15-capstone.md](../../labs/module-3-promql/lab-15-capstone.md)
```

Replace with:
```
See [lab-16-capstone.md](../../labs/module-3-promql/lab-16-capstone.md)
```

Also update the title line from:
```
# Day 15: PromQL Capstone & Review
```
To:
```
# Day 16: PromQL Capstone & Review
```

Also update the prerequisites line from:
```
**Time:** 90 minutes | **Prerequisites:** Days 9-14 completed
```
To:
```
**Time:** 90 minutes | **Prerequisites:** Days 9-15 completed
```

- [ ] **Step 3: Update lab-16-capstone.md title**

In `labs/module-3-promql/lab-16-capstone.md`, update the title:
```
# Lab 15: PromQL Capstone Challenges
```
To:
```
# Lab 16: PromQL Capstone Challenges
```

- [ ] **Step 4: Update lab-16-solution.md title and count(up) value**

In `labs/module-3-promql/solutions/lab-16-solution.md`, update:
```
# Lab 15 Solution: PromQL Capstone
```
To:
```
# Lab 16 Solution: PromQL Capstone
```

Also fix the stale count value on line 15:
```
Returns: 2 (or your count)
```
To:
```
Returns: 6 (one per scrape job)
```

- [ ] **Step 5: Update Makefile — rename verify-day-15 → verify-day-16**

In `Makefile` line 1, replace:
```
.PHONY: setup verify down clean reset logs-prometheus logs-grafana logs-app verify-rules verify-day-5 verify-day-9 verify-day-10 verify-day-12 verify-day-13 verify-day-15 verify-day-11 verify-day-14 help
```
With:
```
.PHONY: setup verify down clean reset logs-prometheus logs-grafana logs-app verify-rules verify-day-5 verify-day-9 verify-day-10 verify-day-12 verify-day-13 verify-day-15 verify-day-16 verify-day-11 verify-day-14 help
```

In the `help` target, replace:
```
	@echo "  make verify-day-15      — Verify Day 15 (PromQL capstone)"
```
With:
```
	@echo "  make verify-day-16      — Verify Day 16 (PromQL capstone)"
```

(The `verify-day-15` help line for SLOs is added in Task 5, once that target exists.)

Rename the `verify-day-15` target block (lines 72–75) to `verify-day-16` and update its echo:

Find:
```makefile
verify-day-15:
	@echo "Verifying Day 15 (PromQL capstone)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=count(up%20%3D%3D%201)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ boolean comparison (up == 1) works" || (echo "✗ boolean comparison failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%5B5m%5D))%20by%20(endpoint)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ rate by endpoint works" || (echo "✗ rate by endpoint failed — stack may need 5+ minutes of uptime"; exit 1)
```

Replace with:
```makefile
verify-day-16:
	@echo "Verifying Day 16 (PromQL capstone)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=count(up%20%3D%3D%201)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ boolean comparison (up == 1) works" || (echo "✗ boolean comparison failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%5B5m%5D))%20by%20(endpoint)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ rate by endpoint works" || (echo "✗ rate by endpoint failed — stack may need 5+ minutes of uptime"; exit 1)
```

- [ ] **Step 6: Update COURSE_INDEX.md — rename Day 15 entry**

Find:
```markdown
### Day 15: PromQL Capstone
- **Guide:** `docs/module-3-promql/day-15-capstone.md`
- **Lab:** `labs/module-3-promql/lab-15-capstone.md`
- **Solution:** `labs/module-3-promql/solutions/lab-15-solution.md`
- **Topics:** Multi-step queries, health checks, SLA monitoring, capacity planning
- **Time:** 90 minutes
```

Replace with:
```markdown
### Day 16: PromQL Capstone
- **Guide:** `docs/module-3-promql/day-16-capstone.md`
- **Lab:** `labs/module-3-promql/lab-16-capstone.md`
- **Solution:** `labs/module-3-promql/solutions/lab-16-solution.md`
- **Topics:** Multi-step queries, health checks, SLA monitoring, capacity planning
- **Time:** 90 minutes
```

- [ ] **Step 7: Update labs/module-3-promql/README.md — rename Lab 15 row**

Find:
```
| Lab 15 | [lab-15-capstone.md](lab-15-capstone.md) | Multi-step real-world queries: SLA monitoring, capacity planning |
```

Replace with:
```
| Lab 16 | [lab-16-capstone.md](lab-16-capstone.md) | Multi-step real-world queries: SLA monitoring, capacity planning |
```

Also update the module scope line at the top from:
```
Labs for Days 9–15. Run queries at http://localhost:9090.
```
To:
```
Labs for Days 9–16. Run queries at http://localhost:9090.
```

- [ ] **Step 8: Verify renames**

```bash
grep -r "day-15-capstone\|lab-15-capstone\|lab-15-solution" --include="*.md" --include="Makefile" . | grep -v "superpowers"
```
Expected: (empty — all old references gone)

```bash
grep -r "day-16-capstone\|lab-16-capstone\|lab-16-solution\|verify-day-16" --include="*.md" --include="Makefile" . | grep -v "superpowers"
```
Expected: several matches confirming the renames took effect

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat: renumber capstone from Day 15 to Day 16 to make room for SLO day"
```

---

### Task 2: Create Day 15 guide

**Files:**
- Create: `docs/module-3-promql/day-15-slos-burn-rates.md`

- [ ] **Step 1: Create the guide**

Create `docs/module-3-promql/day-15-slos-burn-rates.md` with this exact content:

```markdown
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
```

- [ ] **Step 2: Verify**

```bash
grep "HighErrorBudgetBurn\|burn rate\|SLI\|SLO" docs/module-3-promql/day-15-slos-burn-rates.md | wc -l
```
Expected: at least 10 matches

```bash
grep "## Exit Criteria" docs/module-3-promql/day-15-slos-burn-rates.md
```
Expected: one match

- [ ] **Step 3: Commit**

```bash
git add docs/module-3-promql/day-15-slos-burn-rates.md
git commit -m "feat: add Day 15 guide — SLOs and burn rates"
```

---

### Task 3: Create Lab 15

**Files:**
- Create: `labs/module-3-promql/lab-15-slos-burn-rates.md`

- [ ] **Step 1: Create the lab**

Create `labs/module-3-promql/lab-15-slos-burn-rates.md` with this exact content:

```markdown
# Lab 15: SLOs and Burn Rates

**Time:** 30-40 minutes
**Goal:** Build a complete SLO monitoring setup for the sample-app.

## Background

You have a running sample-app exposing `http_requests_total` and `http_request_duration_seconds_bucket`. In this lab you will write the SLI queries, define an SLO, calculate burn rate, add a real alert rule, and create a Grafana panel showing live SLO status.

SLO: **99% of requests succeed** (availability). Allowed error ratio: 0.01.

## Exercise 1: Availability SLI

Run this query in the Prometheus UI at http://localhost:9090:

```promql
sum(rate(http_requests_total{status!~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

**Record your result:** `_______`

This is your availability SLI. A value of 1.0 means 100% of requests succeeded in the last 5 minutes.

## Exercise 2: Error Ratio

Run the complement query:

```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

**Verify:** availability SLI + error ratio = 1.0 (they must sum to exactly 1).

**Question:** If your error ratio is 0.02, are you within your 1% error budget? Why or why not?

*(Answer: No — 0.02 = 2% error rate, double the 1% budget.)*

## Exercise 3: Burn Rate

Run the burn rate query for a 99% SLO (allowed error ratio = 0.01):

```promql
(
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
)
/
0.01
```

**Interpret your result:**
- Burn rate 0 → no errors, budget untouched
- Burn rate 1 → consuming budget at exactly the allowed rate
- Burn rate 10 → consuming 10× faster than allowed

**Question:** At your current burn rate, how many days would it take to exhaust a 30-day error budget?

*(Formula: 30 / burn_rate. If burn rate is 0, budget never exhausts.)*

## Exercise 4: Latency SLI

Run the latency SLI query (fraction of requests completing under 500ms):

```promql
sum(rate(http_request_duration_seconds_bucket{le="0.5"}[5m]))
/
sum(rate(http_request_duration_seconds_count[5m]))
```

**Record your result:** `_______`

**Latency SLO:** 95% of requests complete under 500ms. Is your stack meeting this SLO?
- Result ≥ 0.95 → SLO met ✓
- Result < 0.95 → SLO breached ✗

## Exercise 5: Add the Alert Rule

Add the `HighErrorBudgetBurn` alert to `labs/alert_rules.yml`. Open the file and add a new group **after** the existing `app_alerts` group:

```yaml
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

Reload Prometheus to pick up the new rule:

```bash
cd labs && docker compose exec prometheus kill -HUP 1
```

Wait 5 seconds, then verify the alert loaded:

```bash
curl -s http://localhost:9090/api/v1/rules | jq '[.data.groups[].rules[] | select(.name == "HighErrorBudgetBurn")] | length'
```

Expected: `1`

Then open Prometheus UI → Status → Rules. You should see `HighErrorBudgetBurn` listed under `slo-alerts`.

## Exercise 6: Grafana Panel

Create a Grafana panel showing the live SLO percentage.

1. Open Grafana at http://localhost:3000 (admin/admin)
2. Click **Dashboards → New → New Dashboard → Add visualization**
3. Select **Prometheus** as the data source
4. In the query field, enter:

```promql
(
  sum(rate(http_requests_total{status!~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
) * 100
```

5. Set **Panel title** to: `Availability SLO %`
6. Under **Thresholds**, add:
   - Base color: red
   - Threshold at `99`: green
7. Click **Apply**

**Exit artifact:** Take a screenshot of the panel showing the SLO percentage with the 99% threshold line.

## Solution

See `labs/module-3-promql/solutions/lab-15-solution.md`

## Exit Criteria

- [ ] Availability SLI query returns a value between 0 and 1
- [ ] Error ratio + availability SLI = 1.0
- [ ] Can interpret burn rate value in plain English
- [ ] Latency SLI query returns a value between 0 and 1
- [ ] `HighErrorBudgetBurn` alert appears in Prometheus Status → Rules
- [ ] Grafana panel shows SLO % with 99% threshold line
```

- [ ] **Step 2: Verify**

```bash
grep "Exercise\|Exit Criteria\|HighErrorBudgetBurn" labs/module-3-promql/lab-15-slos-burn-rates.md | wc -l
```
Expected: at least 10 matches

- [ ] **Step 3: Commit**

```bash
git add labs/module-3-promql/lab-15-slos-burn-rates.md
git commit -m "feat: add Lab 15 — SLOs and burn rates exercises"
```

---

### Task 4: Create Lab 15 Solution

**Files:**
- Create: `labs/module-3-promql/solutions/lab-15-solution.md`

- [ ] **Step 1: Create the solution**

Create `labs/module-3-promql/solutions/lab-15-solution.md` with this exact content:

```markdown
# Lab 15 Solution: SLOs and Burn Rates

## Exercise 1: Availability SLI

```promql
sum(rate(http_requests_total{status!~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

**Expected result on healthy stack:** 0.95–1.0 (95–100% of requests succeed)

If result is exactly 1.0: no errors in the last 5 minutes. Normal for the demo stack.
If result is below 0.95: something is generating 5xx responses — check sample-app logs.

## Exercise 2: Error Ratio

```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

**Expected result on healthy stack:** 0.0 (no errors)

Verification: Exercise 1 result + Exercise 2 result = 1.0 (always true by definition).

**Answer:** Error ratio 0.02 = 2% errors. Allowed budget is 1% (0.01). Budget exceeded. 2× over budget.

## Exercise 3: Burn Rate

```promql
(
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
)
/
0.01
```

**Expected result on healthy stack:** 0 (no errors means zero burn rate)

**Burn rate interpretation table:**

| Burn rate | Budget exhausted in (30d window) | Action |
|-----------|----------------------------------|--------|
| 0 | Never | No action |
| 1 | 30 days | Monitor |
| 5 | 6 days | Investigate |
| 10 | 3 days | Escalate |
| 14 | ~2 days | Page on-call |
| 30 | 1 day | Incident |
| 100+ | Hours | All-hands |

**Formula:** days_until_exhausted = 30 / burn_rate

## Exercise 4: Latency SLI

```promql
sum(rate(http_request_duration_seconds_bucket{le="0.5"}[5m]))
/
sum(rate(http_request_duration_seconds_count[5m]))
```

**Expected result on healthy stack:** 0.95–1.0 (most requests complete under 500ms)

The `le="0.5"` bucket holds counts of requests completing in ≤ 0.5 seconds. Dividing by total count gives the fraction.

**Latency SLO evaluation:** result ≥ 0.95 = SLO met ✓

## Exercise 5: Alert Rule

Add to `labs/alert_rules.yml` after the closing `rules:` block of `app_alerts`:

```yaml
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

Reload: `cd labs && docker compose exec prometheus kill -HUP 1`

Verify: `curl -s http://localhost:9090/api/v1/rules | jq '[.data.groups[].rules[] | select(.name == "HighErrorBudgetBurn")] | length'`

Expected: `1`

### Advanced: Multi-Window Alert

Replace the `expr` above with this two-window variant to reduce false positives:

```yaml
        expr: |
          (
            (
              sum(rate(http_requests_total{status=~"5.."}[5m]))
              /
              sum(rate(http_requests_total[5m]))
            ) / 0.01 > 14
          )
          and
          (
            (
              sum(rate(http_requests_total{status=~"5.."}[1h]))
              /
              sum(rate(http_requests_total[1h]))
            ) / 0.01 > 14
          )
```

This fires only when both the 5-minute and 1-hour burn rates exceed 14× — eliminating brief spikes from paging.

## Exercise 6: Grafana Panel (Step-by-Step)

1. Open http://localhost:3000, log in (admin/admin)
2. Left sidebar → **Dashboards** → **New** → **New Dashboard**
3. Click **Add visualization**
4. Data source: **Prometheus**
5. Query A:
   ```promql
   (
     sum(rate(http_requests_total{status!~"5.."}[5m]))
     /
     sum(rate(http_requests_total[5m]))
   ) * 100
   ```
6. **Panel title** (top right): `Availability SLO %`
7. Right panel → **Standard options** → **Unit**: `Percent (0-100)`
8. Right panel → **Thresholds**:
   - Click the existing red base threshold
   - Add threshold: value `99`, color green
9. Click **Apply** (top right)

Your panel now shows SLO % with a red/green threshold at 99%.

## Key Patterns

- SLI = ratio (good / total), always 0.0–1.0
- Error budget = 1 - SLO_target (e.g., 0.01 for a 99% SLO)
- Burn rate = error_ratio / error_budget
- Burn rate 14 = exhausts monthly budget in ~2 days = page now
- Always use `status!~"5.."` for "good" (not `status="200"` — catches 2xx and 3xx)
- Multi-window alerting: 5m detects, 1h confirms
```

- [ ] **Step 2: Verify**

```bash
grep "Exercise\|burn rate\|HighErrorBudgetBurn\|Advanced" labs/module-3-promql/solutions/lab-15-solution.md | wc -l
```
Expected: at least 10 matches

- [ ] **Step 3: Commit**

```bash
git add labs/module-3-promql/solutions/lab-15-solution.md
git commit -m "feat: add Lab 15 solution — SLO burn rate queries and alert"
```

---

### Task 5: Wire up verify-day-15 and update navigation

**Files:**
- Modify: `Makefile` — add new `verify-day-15` target block
- Modify: `COURSE_INDEX.md` — insert Day 15 entry, update stats
- Modify: `labs/module-3-promql/README.md` — insert Lab 15 row

- [ ] **Step 1: Add verify-day-15 target to Makefile**

In `Makefile`, add the new `verify-day-15` block immediately before the `verify-day-16` block (which was renamed from `verify-day-15` in Task 1):

```makefile
verify-day-15:
	@echo "Verifying Day 15 (SLOs and burn rates)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%7Bstatus!~%225..%22%7D%5B5m%5D))%2Fsum(rate(http_requests_total%5B5m%5D))' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ availability SLI query returns data" || (echo "✗ availability SLI query failed — stack may need 5+ minutes of uptime"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=(sum(rate(http_requests_total%7Bstatus%3D~%225..%22%7D%5B5m%5D))%2Fsum(rate(http_requests_total%5B5m%5D)))%2F0.01' | jq -e '.status == "success"' > /dev/null && echo "✓ burn rate query executes" || (echo "✗ burn rate query failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "HighErrorBudgetBurn")] | length > 0' > /dev/null && echo "✓ HighErrorBudgetBurn alert loaded" || (echo "✗ HighErrorBudgetBurn alert not found — add it to labs/alert_rules.yml and reload"; exit 1)
```

Note: The burn rate check uses `.status == "success"` only (no length check) because on a zero-error stack the 5xx numerator returns empty, which is expected and correct.

- [ ] **Step 1b: Add verify-day-15 help line to Makefile**

In the `help` target, find:
```
	@echo "  make verify-day-16      — Verify Day 16 (PromQL capstone)"
```

Replace with:
```
	@echo "  make verify-day-15      — Verify Day 15 (SLOs and burn rates)"
	@echo "  make verify-day-16      — Verify Day 16 (PromQL capstone)"
```

- [ ] **Step 2: Insert Day 15 entry in COURSE_INDEX.md**

In `COURSE_INDEX.md`, find:

```markdown
### Day 16: PromQL Capstone
```

Insert this block immediately before it:

```markdown
### Day 15: SLOs and Burn Rates
- **Guide:** `docs/module-3-promql/day-15-slos-burn-rates.md`
- **Lab:** `labs/module-3-promql/lab-15-slos-burn-rates.md`
- **Solution:** `labs/module-3-promql/solutions/lab-15-solution.md`
- **Topics:** SLI, SLO, error budget, burn rate, multi-window alerting, latency SLO
- **Time:** 90 minutes

```

- [ ] **Step 3: Update COURSE_INDEX.md stats**

Find:
```
**Total Module 3:** 10.5 hours
```
Replace with:
```
**Total Module 3:** 12 hours
```

Find:
```
| Day guides | 15 |
| Labs | 15 |
| Solutions | 15 |
```
Replace with:
```
| Day guides | 16 |
| Labs | 16 |
| Solutions | 16 |
```

Find:
```
| Module 3: PromQL | 10.5 hours |
```
Replace with:
```
| Module 3: PromQL | 12 hours |
```

Find:
```
| **Total (core path)** | **~28 hours** |
```
Replace with:
```
| **Total (core path)** | **~29.5 hours** |
```

- [ ] **Step 4: Insert Lab 15 row in module README**

In `labs/module-3-promql/README.md`, find:

```
| Lab 16 | [lab-16-capstone.md](lab-16-capstone.md) | Multi-step real-world queries: SLA monitoring, capacity planning |
```

Insert this row immediately before it:

```
| Lab 15 | [lab-15-slos-burn-rates.md](lab-15-slos-burn-rates.md) | SLI queries, error budget, burn rate, multi-window alert, Grafana SLO panel |
```

- [ ] **Step 5: Verify Makefile target (requires running stack)**

```bash
make verify-day-15
```

If `HighErrorBudgetBurn` is not yet in `alert_rules.yml` (Task 4 adds it as student work, not as shipped content), this check will fail with:
```
✗ HighErrorBudgetBurn alert not found — add it to labs/alert_rules.yml and reload
```

That is expected — `verify-day-15` is a student completion check, not a CI check. The first two checks (SLI query + burn rate syntax) should pass on any running stack.

To test all three pass, temporarily add `HighErrorBudgetBurn` to `alert_rules.yml`, run `make verify-day-15`, then remove it:

```bash
# Temporarily add alert for testing
cat >> labs/alert_rules.yml << 'EOF'

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
EOF
cd labs && docker compose exec prometheus kill -HUP 1
sleep 5
make verify-day-15
```

Expected output:
```
Verifying Day 15 (SLOs and burn rates)...
✓ availability SLI query returns data
✓ burn rate query executes
✓ HighErrorBudgetBurn alert loaded
```

After confirming, revert `alert_rules.yml` to its pre-test state:

```bash
git checkout labs/alert_rules.yml
cd labs && docker compose exec prometheus kill -HUP 1
```

- [ ] **Step 6: Commit**

```bash
git add Makefile COURSE_INDEX.md labs/module-3-promql/README.md
git commit -m "feat: add verify-day-15 target and update course navigation for Day 15/16"
```
