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
