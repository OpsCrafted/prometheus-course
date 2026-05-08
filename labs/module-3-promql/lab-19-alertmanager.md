# Lab 19: Alertmanager — Routing and Delivery

**Time:** 30 minutes
**Goal:** Configure severity-based routing, add an inhibition rule, and practice silencing.

## Background

`labs/alertmanager.yml` is mounted in the Alertmanager container. Edit it and reload — no restart needed. The Alertmanager UI is at http://localhost:9093.

---

## Exercise 1: Explore Current State

Open http://localhost:9093.

1. Click **Alerts** — which of your Day 17 alerts are currently firing?
2. Click **Status** → **Config** — confirm the current receiver is `null`

**Question:** Why are your Day 17 alerts not sending any notifications right now?

*(Answer: null receiver drops everything silently.)*

---

## Exercise 2: Configure Routing

Replace `labs/alertmanager.yml` with this routing config:

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

Reload:

```bash
curl -X POST http://localhost:9093/-/reload
```

Verify config loaded:

```bash
curl -s http://localhost:9093/api/v1/status | jq '.data.configYAML' | grep -c "receiver"
```

Expected: `4` or more (one per receiver definition + route entries).

---

## Exercise 3: Verify Routing

Open http://localhost:9093 → **Status** → **Config**.

**Questions:**
1. Which receiver handles `severity: page` alerts?
2. Which receiver handles `severity: critical` alerts? *(Hint: check which route matches — or doesn't.)*
3. What happens to an alert with no severity label?

*(Answers in solution.)*

---

## Exercise 4: Inhibition

The inhibition rule suppresses `warning` alerts when `InstanceDown` fires for the same `job`.

To test it:
1. Go to Prometheus UI → Status → Targets
2. Note all targets are UP
3. In the Alertmanager UI → **Alerts** — observe which severity: warning alerts are active
4. The inhibition rule will only fire when `InstanceDown` is active — no manual testing needed in the lab; understanding the config is the goal

**Question:** Why is `equal: ['job']` important in the inhibition rule?

*(Answer in solution.)*

---

## Exercise 5: Create and Expire a Silence

In the Alertmanager UI at http://localhost:9093:

1. Click **Silences** → **New Silence**
2. Add matcher: `alertname = TrafficDrop`
3. Duration: 1 hour
4. Creator: your name
5. Comment: "Testing silence functionality"
6. Click **Preview Alerts** — confirm `TrafficDrop` appears in the preview
7. Click **Create**

Verify it works:
- Go to **Alerts** — `TrafficDrop` should show as silenced (grayed out or absent)
- Go to **Silences** — confirm the silence is listed as Active

Expire the silence: click **Expire** to clean up.

---

## Solution

See `labs/module-3-promql/solutions/lab-19-solution.md`

## Exit Criteria

- [ ] `labs/alertmanager.yml` has 3 receivers and 2 routes
- [ ] Reload returns HTTP 200
- [ ] Can answer Exercise 3 routing questions
- [ ] Successfully created and expired a silence
- [ ] `make verify-day-19` passes
