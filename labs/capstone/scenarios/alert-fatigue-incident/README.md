# Alert Fatigue Incident Lab

**Scenario:** Your on-call team is receiving 500+ alerts per day. Analysis shows 80% are false positives — transient spikes that self-resolve within seconds. The team has started ignoring the alert channel entirely. During a recent real outage, the critical alert fired but was dismissed as noise. The outage lasted 4 hours before someone noticed manually.

**Task:** Fix the alert rules to eliminate noise while keeping real incidents visible.

---

## Bad Alert Rules

These three rules are the primary source of noise. None of them have a `for:` duration, so every threshold crossing — no matter how brief — fires an alert.

```yaml
groups:
  - name: noisy-alerts
    rules:

      - alert: HighCPU
        expr: node_cpu_usage_percent > 75
        for: 0s
        labels:
          severity: critical
        annotations:
          summary: "High CPU on {{ $labels.instance }}"

      - alert: HighMemory
        expr: node_memory_usage_percent > 85
        for: 0s
        labels:
          severity: critical
        annotations:
          summary: "High memory on {{ $labels.instance }}"

      - alert: ElevatedErrorRate
        expr: |
          rate(http_requests_total{status=~"5.."}[1m]) > 0.01
        for: 0s
        labels:
          severity: critical
        annotations:
          summary: "Errors on {{ $labels.job }}"
```

Why these are bad:

- `HighCPU`: fires on any CPU spike above 75%. Normal batch jobs, cron tasks, and deploys routinely hit 75% for 5–10 seconds.
- `HighMemory`: fires on any memory reading above 85%. JVM garbage collection causes brief spikes past this threshold dozens of times per hour.
- `ElevatedErrorRate`: threshold of `0.01` req/s means a single HTTP 500 in a quiet window fires the alert. The 1-minute rate window is too short to distinguish noise from a real error spike.

---

## Fix

Apply proper `for:` durations to each rule and raise the error rate threshold to a meaningful value:

```yaml
groups:
  - name: tuned-alerts
    rules:

      - alert: HighCPUSustained
        expr: node_cpu_usage_percent > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Sustained high CPU on {{ $labels.instance }}"
          description: "CPU has exceeded 80% for more than 5 minutes. Investigate running processes."

      - alert: HighMemorySustained
        expr: node_memory_usage_percent > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Sustained high memory on {{ $labels.instance }}"
          description: "Memory has exceeded 90% for more than 5 minutes. Check for memory leaks."

      - alert: ElevatedErrorRate
        expr: |
          rate(http_requests_total{status=~"5.."}[5m])
          / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Error rate above 5% on {{ $labels.job }}"
          description: "More than 5% of requests are returning 5xx errors."
```

What changed:

| Rule | Before | After |
|---|---|---|
| `HighCPU` | threshold 75%, `for: 0s` | threshold 80%, `for: 5m` |
| `HighMemory` | threshold 85%, `for: 0s` | threshold 90%, `for: 5m` |
| `ElevatedErrorRate` | absolute count, 1m window, `for: 0s` | ratio > 5%, 5m window, `for: 5m` |

---

## Verification

After applying the fixed rules, reload Prometheus and observe for 24 hours:

| Metric | Before fix | After fix |
|---|---|---|
| Alerts fired per day | ~500 | ~5 |
| False positive rate | ~80% | < 5% |
| Mean time to acknowledge real alerts | 4+ hours (ignored) | < 15 minutes |
| Team confidence in alerts | Low (ignoring channel) | High (every alert is actionable) |

To reload rules without restarting Prometheus:

```bash
curl -X POST http://localhost:9090/-/reload
```

Confirm the new rules are loaded:

```bash
curl -s http://localhost:9090/api/v1/rules | jq '.data.groups[].rules[].name'
```

You should see `HighCPUSustained`, `HighMemorySustained`, and `ElevatedErrorRate` in the output, and the old noisy rule names (`HighCPU`, `HighMemory`) should be gone.
