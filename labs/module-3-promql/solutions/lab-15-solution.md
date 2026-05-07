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
