# Testing Alerts: Force & Verify

**Goal:** See your alert rules fire in real-time. Confirm Alertmanager is working.

## Why This Matters

Many students build alert rules but never see them fire. This lab forces alert conditions and verifies the full pipeline (Prometheus → Rules → Alertmanager).

## Prerequisites

- Docker stack running (`docker compose up -d`)
- Alert rules loaded (`labs/alert_rules.yml`)
- Alertmanager running on :9093

## Method 1: Automated Test Script

```bash
cd labs/
chmod +x test_alerts.sh
./test_alerts.sh
```

Expected output:
```
=== Prometheus Alert Testing ===

1. Checking connectivity...
✓ Prometheus OK
✓ Alertmanager OK

2. Testing TargetDown alert...
   Stopping node-exporter to trigger up == 0 condition...
✓ TargetDown alert FIRED

3. Testing HighErrorRate alert...
   Generating 500 errors to sample-app...
✓ HighErrorRate alert FIRED

4. Checking Alertmanager routing...
   (should see fired alerts in output above)
```

## Method 2: Manual Testing

### Test 1: Force TargetDown Alert

Stop a scrape target:
```bash
docker compose stop node-exporter
```

Wait 1 minute, then check Prometheus alerts:
```bash
curl http://localhost:9090/alerts
```

Should see:
```
TargetDown: up == 0 for node-exporter (firing)
```

Restart:
```bash
docker compose start node-exporter
```

### Test 2: Force HighErrorRate Alert

Generate 500 errors by hitting a nonexistent endpoint:
```bash
for i in {1..100}; do
  curl http://localhost:8080/api/notfound 2>/dev/null
done
```

Wait 5 minutes (for rate window + `for: 5m` duration), then check:
```bash
curl http://localhost:9093/api/v1/alerts | jq '.data[] | select(.labels.alertname=="HighErrorRate")'
```

Should see:
```json
{
  "status": "firing",
  "labels": {
    "alertname": "HighErrorRate",
    "severity": "warning"
  }
}
```

### Test 3: Verify Alertmanager Routing

View all active alerts:
```bash
curl http://localhost:9093/api/v1/alerts | jq '.data'
```

View Alertmanager UI:
```
http://localhost:9093
```

## Verification Checklist

- [ ] Run `./test_alerts.sh` without errors
- [ ] See "✓ TargetDown alert FIRED" in output
- [ ] See "✓ HighErrorRate alert FIRED" in output
- [ ] Alertmanager UI shows active alerts
- [ ] Prometheus `/alerts` page shows rules in FIRING state

## What's Happening

1. **Prometheus Rules Engine** (every 30s) evaluates alert expressions
2. **Rule Fires** when condition is true for the `for:` duration
3. **Alertmanager Receives** the alert from Prometheus
4. **Alertmanager Routes** based on routing rules (in this case, prints to stdout)

If Alertmanager doesn't show alerts:
- Check Prometheus rule evaluation: `curl http://localhost:9090/alerts`
- Check Alertmanager logs: `docker compose logs alertmanager`
- Verify alert_rules.yml is mounted: `docker compose ps | grep prometheus`

## Next: Real Notifications

In production, Alertmanager routes to Slack, PagerDuty, email, etc. See Alertmanager docs for routing configuration.

For now, you've verified the full alert pipeline works end-to-end.
