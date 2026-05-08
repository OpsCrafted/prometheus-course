# Day 19: Alertmanager — Routing and Delivery

**Time:** 60 minutes | **Prerequisites:** Day 17 completed (5 production alerts wired)

## Learning Outcomes

- [ ] Understand Alertmanager's role: routing, grouping, silencing, inhibition
- [ ] Configure a routing tree with severity-based routing
- [ ] Add a webhook receiver
- [ ] Create an inhibition rule to suppress downstream alerts
- [ ] Silence a firing alert via the Alertmanager UI

---

## Where Alerts Go

In Day 17 you wired 5 alerts into `alert_rules.yml`. Prometheus evaluates those rules and fires alerts — but Prometheus does not send notifications. That is Alertmanager's job.

```
alert_rules.yml → Prometheus evaluates → fires alert → Alertmanager routes → receiver (Slack, PagerDuty, email, webhook)
```

Alertmanager is running at http://localhost:9093. Right now it uses a `null` receiver — it receives everything and drops it silently. Today you change that.

---

## Key Concepts

### Routing Tree

Every alert flows through the routing tree. The tree is a set of `match` rules that decide which receiver handles an alert.

```yaml
route:
  receiver: default          # catch-all if nothing else matches
  routes:
    - match:
        severity: page
      receiver: pagerduty    # critical/page alerts → PagerDuty
    - match:
        severity: warning
      receiver: slack        # warning alerts → Slack
```

Alerts match the first route that fits. Unmatched alerts fall through to the top-level `receiver`.

### Grouping

Alertmanager batches related alerts into one notification instead of sending one message per alert.

```yaml
route:
  group_by: ['alertname', 'job']
  group_wait: 30s       # wait before sending first notification (more alerts may arrive)
  group_interval: 5m    # how long to wait before re-notifying a group
  repeat_interval: 4h   # how long before re-sending a resolved alert
```

Without grouping: 50 pods go down → 50 separate pages. With grouping: 1 page with "50 instances down."

### Inhibition

Inhibition suppresses lower-priority alerts when a higher-priority alert is already firing. Example: if `InstanceDown` is firing, suppress `HighP99Latency` for the same instance — the service is down, the latency alert is noise.

```yaml
inhibit_rules:
  - source_match:
      alertname: InstanceDown
    target_match:
      severity: warning
    equal: ['job', 'instance']
```

This says: when `InstanceDown` fires, suppress all `warning` alerts with the same `job` and `instance` labels.

### Silences

A silence suppresses notifications for a time window — useful during maintenance or known incidents. You create silences via the Alertmanager UI at http://localhost:9093 or via API. Silences do not stop alert evaluation in Prometheus; they only stop notifications.

---

## Receiver Types

| Receiver | When to use |
|----------|-------------|
| `webhook_configs` | Any HTTP endpoint — Slack incoming webhooks, PagerDuty, custom systems |
| `slack_configs` | Native Slack integration with richer formatting |
| `pagerduty_configs` | Native PagerDuty routing |
| `email_configs` | SMTP email |
| `null` | Intentional drop (e.g., for alerts you're not ready to act on yet) |

For this lab you'll use `webhook_configs` — it works with any HTTP endpoint and is the most portable receiver type.

---

## Hands-On

**Step 1:** Open http://localhost:9093 and explore the current state.

- Click **Alerts** — see which alerts are currently firing
- Click **Status** → **Config** — see the current null routing config

**Step 2:** Update `labs/alertmanager.yml` with severity-based routing:

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
      group_wait: 10s       # pages go faster

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
      - url: 'http://localhost:9091/metrics/job/alertmanager_test'
        send_resolved: true

  - name: 'page-webhook'
    webhook_configs:
      - url: 'http://localhost:9091/metrics/job/alertmanager_test'
        send_resolved: true

  - name: 'warning-webhook'
    webhook_configs:
      - url: 'http://localhost:9091/metrics/job/alertmanager_test'
        send_resolved: true
```

> **Note:** This routes all receivers to the Pushgateway endpoint as a webhook sink — requests will return 200 (Pushgateway accepts arbitrary POST bodies) and act as a no-op delivery target. In production, replace with a real Slack/PagerDuty URL.

**Step 3:** Reload Alertmanager:

```bash
curl -X POST http://localhost:9093/-/reload
```

**Step 4:** Verify the config loaded:

```bash
curl -s http://localhost:9093/api/v1/status | jq '.data.configYAML' | head -5
```

Or open http://localhost:9093 → Status → Config and confirm the routing tree is visible.

**Step 5:** Create a silence.

In the Alertmanager UI at http://localhost:9093:
1. Click **Silences** → **New Silence**
2. Add matcher: `alertname = TrafficDrop`
3. Set duration: 1 hour
4. Add creator and comment: "Testing silences"
5. Click **Create**

The `TrafficDrop` alert will continue firing in Prometheus but notifications are suppressed.

**Step 6:** Expire the silence.

Find the silence in the list and click **Expire**. Notifications resume.

---

## Lab

See [lab-19-alertmanager.md](../../labs/module-3-promql/lab-19-alertmanager.md)

## Exit Criteria

- [ ] Alertmanager routing tree has 2+ routes (severity: page, severity: warning)
- [ ] Inhibition rule configured for InstanceDown → warning suppression
- [ ] `curl http://localhost:9093/-/reload` returns 200
- [ ] Successfully created and expired a silence via UI
- [ ] `make verify-day-19` passes
