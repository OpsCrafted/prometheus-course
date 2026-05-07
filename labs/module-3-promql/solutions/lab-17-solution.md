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
Filled in by: [your name]

## Metrics Hygiene
- [x] Request counter exposed (http_requests_total)
- [x] Error counter or error label on request counter (status label with 5xx values)
- [x] Latency histogram exposed (http_request_duration_seconds_bucket)
- [x] Saturation gauge (node_memory_MemAvailable_bytes via node-exporter)
- [x] All labels have bounded cardinality (method, status, endpoint — all finite)

## Alerting
- [x] InstanceDown alert (target not scraping — production-readiness group)
- [x] HighP99Latency alert (p99 > 1s)
- [x] ErrorBudgetBurning alert (burn rate, not raw rate)
- [x] TrafficDrop alert (< 1 req/s)
- [x] HighMemorySaturation alert (> 85%)
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
