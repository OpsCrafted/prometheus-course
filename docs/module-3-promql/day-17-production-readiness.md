# Day 17: Production Readiness Checklist

**Time:** 90 minutes | **Prerequisites:** Days 9-16 completed (all PromQL labs and capstone)

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
| No severity routing | Everything pages on-call at 3am | Use `severity: page` for immediate action, `warning` for investigate-later |

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
