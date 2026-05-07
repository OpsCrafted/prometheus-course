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
