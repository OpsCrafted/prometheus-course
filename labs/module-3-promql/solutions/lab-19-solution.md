# Lab 19 Solution: Alertmanager

## Exercise 2: Complete alertmanager.yml

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: 'default-webhook'
  group_by: ['alertname', 'job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h

  routes:
    - match:
        severity: page
      receiver: 'page-webhook'
      group_wait: 10s

    - match:
        severity: warning
      receiver: 'warning-webhook'

inhibit_rules:
  - source_match:
      alertname: InstanceDown
    target_match:
      severity: warning
    equal: ['job']

receivers:
  - name: 'default-webhook'
    webhook_configs:
      - url: 'http://pushgateway:9091/metrics/job/alertmanager_test'
        send_resolved: true

  - name: 'page-webhook'
    webhook_configs:
      - url: 'http://pushgateway:9091/metrics/job/alertmanager_test'
        send_resolved: true

  - name: 'warning-webhook'
    webhook_configs:
      - url: 'http://pushgateway:9091/metrics/job/alertmanager_test'
        send_resolved: true
```

## Exercise 3: Routing questions

**Which receiver handles `severity: page`?**
`page-webhook` — matched by `match: {severity: page}`.

**Which receiver handles `severity: critical`?**
`default-webhook` — no route matches `severity: critical`, so it falls through to the top-level catch-all receiver.

**What happens to an alert with no severity label?**
Same as critical: no route matches, falls through to `default-webhook`.

**Takeaway:** Always add a catch-all receiver at the top level. Alerts without matching routes are not silently dropped — they go to the default. But if you have no default, Alertmanager returns an error and drops the alert.

## Exercise 4: Inhibition answer

**Why is `equal: ['job']` important?**

The `equal` field specifies which labels must match between the source alert (InstanceDown) and the target alerts (severity: warning) for inhibition to apply.

Without `equal: ['job']`: if *any* instance goes down, *all* warning alerts across *all* jobs are suppressed — including unrelated services. `equal: ['job']` scopes the suppression: only warning alerts for the *same job* as the downed instance are suppressed.

Example:
- `InstanceDown{job="sample-app"}` fires
- `HighP99Latency{job="sample-app", severity="warning"}` → suppressed ✓
- `HighMemorySaturation{job="node", severity="warning"}` → NOT suppressed ✓ (different job)

## Exercise 5: Silence verification

After creating the silence, the Alertmanager UI shows `TrafficDrop` in the **Silenced** state. The Prometheus UI still shows the alert as `FIRING` — silences only suppress notifications, not evaluation.

This distinction is important: a silenced alert is still real. It will refire as soon as the silence expires.
