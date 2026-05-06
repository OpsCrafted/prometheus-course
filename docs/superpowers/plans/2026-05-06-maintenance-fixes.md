# Maintenance Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 6 bugs across Makefile, test script, lab content, docs, and repo hygiene.

**Architecture:** All fixes are independent. Each touches 1-2 files. No new dependencies introduced. Prometheus reload works via `curl -X POST http://localhost:9090/-/reload` from the host.

**Tech Stack:** Bash, Make, Docker Compose v2, Prometheus, PromQL, Markdown

---

## File Map

| File | Action | Reason |
|------|--------|--------|
| `Makefile` | Modify | Add `cd labs &&` to 3 verify targets |
| `labs/alert_rules_test.yml` | Create | Test-mode alert rules with `for: 15s` |
| `labs/test_alerts.sh` | Modify | Fix endpoint, timing, docker compose context, restore rules |
| `labs/module-3-promql/lab-12-joins.md` | Modify | Fix Query 2, 3 (add sum()), Query 5 (replace nonexistent metric) |
| `labs/module-3-promql/solutions/lab-12-solution.md` | Modify | Match lab fixes |
| `docs/getting-started/verify-setup.md` | Modify | Replace `docker-compose` with `docker compose` in code blocks |
| `labs/setup.sh` | Modify | Replace `docker-compose`, add full URL list |
| `.gitignore` | Modify | Add `labs/sample-app/main` |
| `labs/sample-app/main` | Delete | Remove tracked binary |

---

### Task 1: Fix Makefile Verify Targets

**Files:**
- Modify: `Makefile:37-50`

- [ ] **Step 1: Update verify-rules target**

In `Makefile`, change:
```makefile
verify-rules:
	docker compose exec prometheus promtool check rules /etc/prometheus/alert_rules.yml
```
To:
```makefile
verify-rules:
	cd labs && docker compose exec prometheus promtool check rules /etc/prometheus/alert_rules.yml
```

- [ ] **Step 2: Update verify-day-11 target**

Change:
```makefile
verify-day-11:
	@echo "Verifying Day 11 PromQL (rate/increase functions)..."
	docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=rate(http_requests_total%5B5m%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ rate() query OK" || (echo "✗ rate() query failed"; exit 1)
	docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=increase(http_requests_total%5B1h%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ increase() query OK" || (echo "✗ increase() query failed"; exit 1)
```
To:
```makefile
verify-day-11:
	@echo "Verifying Day 11 PromQL (rate/increase functions)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=rate(http_requests_total%5B5m%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ rate() query OK" || (echo "✗ rate() query failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=increase(http_requests_total%5B1h%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ increase() query OK" || (echo "✗ increase() query failed"; exit 1)
```

- [ ] **Step 3: Update verify-day-14 target**

Change:
```makefile
verify-day-14:
	@echo "Verifying Day 14 PromQL (histogram_quantile)..."
	docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=histogram_quantile(0.95,%20sum(rate(http_request_duration_seconds_bucket%5B5m%5D))%20by%20(le))' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ histogram_quantile() query OK" || (echo "✗ histogram_quantile() query failed"; exit 1)
	docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_request_duration_seconds_bucket' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ histogram buckets exist" || (echo "✗ histogram buckets not found"; exit 1)
```
To:
```makefile
verify-day-14:
	@echo "Verifying Day 14 PromQL (histogram_quantile)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=histogram_quantile(0.95,%20sum(rate(http_request_duration_seconds_bucket%5B5m%5D))%20by%20(le))' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ histogram_quantile() query OK" || (echo "✗ histogram_quantile() query failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_request_duration_seconds_bucket' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ histogram buckets exist" || (echo "✗ histogram buckets not found"; exit 1)
```

- [ ] **Step 4: Verify**

```bash
make verify-rules
```
Expected: promtool output with no errors (exit 0)

```bash
make verify-day-11
```
Expected:
```
✓ rate() query OK
✓ increase() query OK
```

- [ ] **Step 5: Commit**

```bash
git add Makefile
git commit -m "fix: add cd labs to Makefile verify targets"
```

---

### Task 2: Create Test-Mode Alert Rules

**Files:**
- Create: `labs/alert_rules_test.yml`

- [ ] **Step 1: Create the file**

Create `labs/alert_rules_test.yml`:
```yaml
groups:
  - name: app_alerts
    interval: 10s
    rules:
      - alert: TargetDown
        expr: up == 0
        for: 15s
        labels:
          severity: critical
        annotations:
          summary: "Target {{ $labels.instance }} is down"

      - alert: HighErrorRate
        expr: (sum(rate(http_requests_total{status=~"5.."}[1m])) by (job)) / (sum(rate(http_requests_total[1m])) by (job)) > 0.05
        for: 15s
        labels:
          severity: warning
        annotations:
          summary: "High error rate (>5%) on {{ $labels.job }}"

      - alert: HighP95Latency
        expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[1m])) by (le, job)) > 1.5
        for: 15s
        labels:
          severity: warning
        annotations:
          summary: "P95 latency >1.5s on {{ $labels.job }}"

      - alert: LowTraffic
        expr: sum(rate(http_requests_total[1m])) by (job) < 0.1
        for: 15s
        labels:
          severity: warning
        annotations:
          summary: "Low traffic (<0.1 req/s) on {{ $labels.job }}"
```

Note: rate windows shortened to `[1m]` (from `[5m]`) so they compute quickly in tests.

- [ ] **Step 2: Validate the file**

```bash
cd labs && docker compose cp alert_rules_test.yml prometheus:/tmp/alert_rules_test.yml && docker compose exec prometheus promtool check rules /tmp/alert_rules_test.yml
```
Expected: `SUCCESS: 4 rules found`

- [ ] **Step 3: Commit**

```bash
git add labs/alert_rules_test.yml
git commit -m "feat: add test-mode alert rules with 15s for-durations"
```

---

### Task 3: Fix test_alerts.sh

**Files:**
- Modify: `labs/test_alerts.sh`

- [ ] **Step 1: Rewrite the script**

Replace the entire contents of `labs/test_alerts.sh` with:

```bash
#!/bin/bash

# Test Prometheus Alerts using short-duration test rules.
# Swaps in alert_rules_test.yml (for: 15s), runs assertions, restores originals.

set -e

cd "$(dirname "$0")"

PROMETHEUS_URL="http://localhost:9090"
ALERTMANAGER_URL="http://localhost:9093"
SAMPLE_APP_URL="http://localhost:8080"

# Restore original rules on exit (success or failure)
cleanup() {
    echo ""
    echo "Restoring original alert rules..."
    docker compose cp alert_rules.yml prometheus:/etc/prometheus/alert_rules.yml
    curl -s -X POST "$PROMETHEUS_URL/-/reload" > /dev/null
    echo "✓ Original rules restored"
}
trap cleanup EXIT

echo "=== Prometheus Alert Testing ==="
echo ""

# Check connectivity
echo "1. Checking connectivity..."
if ! curl -sf "$PROMETHEUS_URL/api/v1/status/config" > /dev/null; then
    echo "❌ Prometheus not reachable at $PROMETHEUS_URL"
    exit 1
fi
echo "✓ Prometheus OK"

if ! curl -sf "$ALERTMANAGER_URL" > /dev/null; then
    echo "❌ Alertmanager not reachable at $ALERTMANAGER_URL"
    exit 1
fi
echo "✓ Alertmanager OK"

# Install test-mode rules (for: 15s)
echo ""
echo "2. Installing test-mode alert rules (for: 15s)..."
docker compose cp alert_rules_test.yml prometheus:/etc/prometheus/alert_rules.yml
curl -s -X POST "$PROMETHEUS_URL/-/reload" > /dev/null
echo "✓ Test rules loaded — waiting 5s for Prometheus to apply..."
sleep 5

# Test 1: TargetDown
echo ""
echo "3. Testing TargetDown alert..."
echo "   Stopping node-exporter..."
docker compose stop node-exporter
echo "   Waiting 25s for alert to fire (for: 15s + scrape interval)..."
sleep 25

FIRING=$(curl -s "$ALERTMANAGER_URL/api/v2/alerts?filter=alertname%3DTargetDown" | jq '. | length' 2>/dev/null || echo "0")
if [ "$FIRING" -gt 0 ]; then
    echo "✓ TargetDown alert FIRED ($FIRING active)"
else
    echo "❌ TargetDown alert did NOT fire"
fi

docker compose start node-exporter
sleep 5

# Test 2: HighErrorRate
echo ""
echo "4. Testing HighErrorRate alert..."
echo "   Generating 500 errors via /error endpoint..."
for i in $(seq 1 500); do
    curl -s "$SAMPLE_APP_URL/error" > /dev/null 2>&1 || true
done
echo "   Waiting 25s for alert to fire (for: 15s + scrape interval)..."
sleep 25

FIRING=$(curl -s "$ALERTMANAGER_URL/api/v2/alerts?filter=alertname%3DHighErrorRate" | jq '. | length' 2>/dev/null || echo "0")
if [ "$FIRING" -gt 0 ]; then
    echo "✓ HighErrorRate alert FIRED ($FIRING active)"
else
    echo "❌ HighErrorRate alert did NOT fire (check /error endpoint returns 5xx)"
fi

# Summary
echo ""
echo "5. All active alerts:"
curl -s "$ALERTMANAGER_URL/api/v2/alerts" | jq '[.[] | {alert: .labels.alertname, state: .status.state}]'

echo ""
echo "=== Alert Testing Complete ==="
echo "Alertmanager UI: $ALERTMANAGER_URL"
echo "Prometheus alerts: $PROMETHEUS_URL/alerts"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x labs/test_alerts.sh
```

- [ ] **Step 3: Verify the /error endpoint returns 5xx**

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/error
```
Expected: `500` (or any 5xx). If it returns 200, the HighErrorRate test will not fire — investigate the sample-app code before proceeding.

- [ ] **Step 4: Commit**

```bash
git add labs/test_alerts.sh
git commit -m "fix: rewrite test_alerts.sh with test-mode rules and correct error endpoint"
```

---

### Task 4: Fix Lab 12 PromQL

**Files:**
- Modify: `labs/module-3-promql/lab-12-joins.md`
- Modify: `labs/module-3-promql/solutions/lab-12-solution.md`

- [ ] **Step 1: Fix Query 2 in the lab**

In `labs/module-3-promql/lab-12-joins.md`, replace:
```
**Query 2:** Success percentage
```
rate(http_requests_total{status="200"}[5m]) /
rate(http_requests_total[5m])
```
Result: Fraction (0.95 = 95%)
```
With:
```
**Query 2:** Success percentage
```
sum(rate(http_requests_total{status="200"}[5m]))
/
sum(rate(http_requests_total[5m]))
```
Result: Fraction (0.95 = 95%) — sum() ensures label sets match before dividing
```

- [ ] **Step 2: Fix Query 3 in the lab**

Replace:
```
**Query 3:** Error rate
```
rate(http_requests_total{status=~"5.."}[5m]) /
rate(http_requests_total[5m])
```
Result: Fraction of 5XX errors
```
With:
```
**Query 3:** Error rate
```
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```
Result: Fraction of 5XX errors — sum() collapses labels before dividing
```

- [ ] **Step 3: Fix Query 5 in the lab**

Replace:
```
**Query 5:** Math (KB/s)
```
rate(http_response_size_bytes[5m]) / 1024
```
Result: Throughput in KB/s
```
With:
```
**Query 5:** Request throughput
```
rate(http_requests_total[5m]) * 60
```
Result: Requests per minute
```

- [ ] **Step 4: Fix solution file — Query 2**

In `labs/module-3-promql/solutions/lab-12-solution.md`, replace:
```
**Query 2:** Success percentage
```
rate(http_requests_total{status="200"}[5m]) / rate(http_requests_total[5m])
Result: 0.95  (95% successful)
```
```
With:
```
**Query 2:** Success percentage
```
sum(rate(http_requests_total{status="200"}[5m]))
/
sum(rate(http_requests_total[5m]))
Result: 0.95  (95% successful)
```
```

- [ ] **Step 5: Fix solution file — Query 3**

Replace:
```
**Query 3:** Error rate (5XX)
```
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
Result: 0.05  (5% error rate)
```
```
With:
```
**Query 3:** Error rate (5XX)
```
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
Result: 0.05  (5% error rate)
```
```

- [ ] **Step 6: Fix solution file — Query 5**

Replace:
```
**Query 5:** Throughput KB/s
```
rate(http_response_size_bytes[5m]) / 1024
Result: 10.5  (10.5 KB/s)
```
```
With:
```
**Query 5:** Request throughput
```
rate(http_requests_total[5m]) * 60
Result: ~1.2  (requests per minute)
```
```

- [ ] **Step 7: Verify queries run in Prometheus**

```bash
curl -sg 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%7Bstatus%3D"200"%7D%5B5m%5D))%2Fsum(rate(http_requests_total%5B5m%5D))' | jq '.status'
```
Expected: `"success"`

```bash
curl -sg 'http://localhost:9090/api/v1/query?query=rate(http_requests_total%5B5m%5D)*60' | jq '.status'
```
Expected: `"success"`

- [ ] **Step 8: Commit**

```bash
git add labs/module-3-promql/lab-12-joins.md labs/module-3-promql/solutions/lab-12-solution.md
git commit -m "fix: correct Lab 12 PromQL queries (sum wrappers, real metric for Q5)"
```

---

### Task 5: Fix verify-setup.md

**Files:**
- Modify: `docs/getting-started/verify-setup.md`

- [ ] **Step 1: Replace docker-compose with docker compose**

In `docs/getting-started/verify-setup.md`, replace:
```
docker-compose ps
```
With:
```
docker compose ps
```

- [ ] **Step 2: Verify no other v1 CLI references remain**

```bash
grep -n "docker-compose" docs/getting-started/verify-setup.md
```
Expected: no output

- [ ] **Step 3: Commit**

```bash
git add docs/getting-started/verify-setup.md
git commit -m "fix: replace docker-compose with docker compose in verify-setup docs"
```

---

### Task 6: Fix setup.sh

**Files:**
- Modify: `labs/setup.sh`

- [ ] **Step 1: Rewrite setup.sh**

Replace the entire contents of `labs/setup.sh` with:

```bash
#!/bin/bash
set -e
cd "$(dirname "$0")"

docker compose up -d
echo "Waiting for Prometheus to start..."

max_retries=10
retry=0
while [ $retry -lt $max_retries ]; do
  if curl -sf http://localhost:9090/api/v1/query?query=up > /dev/null 2>&1; then
    echo "✓ Prometheus running"
    break
  fi
  retry=$((retry + 1))
  if [ $retry -lt $max_retries ]; then
    echo "Waiting for Prometheus... (attempt $retry/$max_retries)"
    sleep 2
  fi
done

if [ $retry -eq $max_retries ]; then
  echo "✗ Prometheus did not respond after $max_retries attempts"
  exit 1
fi

echo ""
echo "Services running:"
echo "  Prometheus:   http://localhost:9090"
echo "  Grafana:      http://localhost:3000"
echo "  Alertmanager: http://localhost:9093"
echo "  Sample App:   http://localhost:8080"
```

- [ ] **Step 2: Verify no docker-compose references remain**

```bash
grep -n "docker-compose" labs/setup.sh
```
Expected: no output

- [ ] **Step 3: Commit**

```bash
git add labs/setup.sh
git commit -m "fix: update setup.sh to docker compose v2 and add full service URLs"
```

---

### Task 7: Remove Binary Artifact

**Files:**
- Delete: `labs/sample-app/main`
- Modify: `.gitignore`

- [ ] **Step 1: Remove the binary from git**

```bash
git rm labs/sample-app/main
```
Expected: `rm 'labs/sample-app/main'`

- [ ] **Step 2: Add to .gitignore**

Append to `.gitignore`:
```
labs/sample-app/main
```

- [ ] **Step 3: Verify binary is gone and ignored**

```bash
git status labs/sample-app/main
```
Expected: nothing (not tracked, not showing as untracked)

```bash
# Simulate rebuild to confirm it would be ignored
touch labs/sample-app/main
git status labs/sample-app/main
```
Expected: no output (file is ignored)

```bash
rm labs/sample-app/main
```

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git commit -m "chore: remove compiled binary and add to .gitignore"
```
