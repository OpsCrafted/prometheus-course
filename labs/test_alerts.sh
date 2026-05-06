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
    set +e
    echo ""
    echo "Restoring original alert rules..."
    docker compose cp alert_rules.yml prometheus:/etc/prometheus/alert_rules.yml
    curl -s -X POST "$PROMETHEUS_URL/-/reload" > /dev/null
    echo "✓ Original rules restored"
}

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
trap cleanup EXIT

RELOAD_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$PROMETHEUS_URL/-/reload")
if [ "$RELOAD_STATUS" != "200" ]; then
    echo "❌ Prometheus reload failed (HTTP $RELOAD_STATUS)"
    exit 1
fi
echo "✓ Test rules loaded — waiting 5s for Prometheus to apply..."
sleep 5

# Test 1: TargetDown
echo ""
echo "3. Testing TargetDown alert..."
echo "   Stopping node-exporter..."
docker compose stop node-exporter
echo "   Waiting 35s for alert to fire (for: 15s + scrape interval)..."
sleep 35

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
echo "   Waiting 35s for alert to fire (for: 15s + scrape interval)..."
sleep 35

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
