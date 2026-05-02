# Lesson 2: Alert Fatigue

**Time:** 30 minutes

## The Mistake

A common pitfall when writing Prometheus alert rules is omitting the `for:` duration entirely, or setting it to `0s`. This causes the alert to fire on every single spike, no matter how brief.

```yaml
groups:
  - name: cpu-alerts
    rules:
      - alert: HighCPU
        expr: node_cpu_usage_percent > 80
        # for: is missing — fires the instant the threshold is crossed
        labels:
          severity: critical
        annotations:
          summary: "CPU is high on {{ $labels.instance }}"
```

With `for: 0s` (or no `for:` at all), every momentary CPU spike above 80% immediately triggers a `FIRING` alert. A single busy minute can produce dozens of alert notifications.

## Why It's Bad

Alert fatigue is the organizational consequence of too much noise:

- **Volume:** 100+ alerts per day flood Slack, PagerDuty, or email.
- **False positives:** 90% of those alerts resolve themselves within seconds — they were never real incidents.
- **Desensitization:** Engineers learn to ignore the channel. They stop reading alert messages.
- **Missed outages:** When a real incident fires, it looks identical to the noise. The team ignores it. The outage runs for hours.

The pattern is self-reinforcing: the more alerts people ignore, the more dangerous each ignored alert becomes.

## The Fix

Add a `for:` duration to every alert rule. The alert only fires if the condition stays true for the entire duration. Transient spikes clear before the timer expires, so they never produce a notification.

```yaml
groups:
  - name: cpu-alerts
    rules:
      - alert: HighCPU
        expr: node_cpu_usage_percent > 80
        for: 5m          # must stay above 80% for 5 full minutes
        labels:
          severity: warning
        annotations:
          summary: "CPU sustained above 80% on {{ $labels.instance }}"
          description: "CPU has been above 80% for more than 5 minutes."
```

### Recommended `for:` durations by alert type

| Alert type | Recommended `for:` | Rationale |
|---|---|---|
| High CPU | `5m` | Short spikes are normal; sustained load is the problem |
| High memory | `5m` | GC pauses and burst allocations cause brief spikes |
| Elevated error rate | `5m` | Retries and deploys cause transient error bursts |
| Disk filling fast | `1m` | Disk issues can escalate quickly, but 1m filters noise |
| Service down / no data | `1m` | One missed scrape is common; two in a row is real |

### Full example with multiple rules

```yaml
groups:
  - name: infrastructure
    rules:

      - alert: HighCPUSustained
        expr: node_cpu_usage_percent > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Sustained high CPU on {{ $labels.instance }}"

      - alert: HighMemorySustained
        expr: node_memory_usage_percent > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Sustained high memory on {{ $labels.instance }}"

      - alert: ElevatedErrorRate
        expr: |
          rate(http_requests_total{status=~"5.."}[5m])
          / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Error rate above 5% on {{ $labels.job }}"

      - alert: DiskFillingFast
        expr: |
          predict_linear(node_filesystem_avail_bytes[1h], 4 * 3600) < 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Disk will be full in < 4 hours on {{ $labels.instance }}"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "{{ $labels.job }} on {{ $labels.instance }} is unreachable"
```

By tuning `for:` durations you keep alerts actionable. Every alert that fires represents a condition that persisted long enough to be worth a human's attention.

## Lab: Alert Fatigue Incident

Hands-on practice for this lesson is in the companion lab:

```
labs/capstone/scenarios/alert-fatigue-incident/
```

In the lab you will:

1. Inspect a set of badly configured alert rules that generate 500+ alerts per day.
2. Identify which rules are missing `for:` durations or have thresholds that are too sensitive.
3. Apply the fixes from this lesson.
4. Verify that the alert rate drops from ~500/day to ~5/day.
