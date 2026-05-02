#!/bin/bash

# Test Prometheus Alerts
# Forces alert conditions and verifies Alertmanager fires notifications

set -e

PROMETHEUS_URL="http://localhost:9090"
ALERTMANAGER_URL="http://localhost:9093"
SAMPLE_APP_URL="http://localhost:8080"

echo "=== Prometheus Alert Testing ==="
echo ""

# Check connectivity
echo "1. Checking connectivity..."
if ! curl -s $PROMETHEUS_URL/api/v1/status/config > /dev/null; then
    echo "❌ Prometheus not reachable at $PROMETHEUS_URL"
    exit 1
fi
echo "✓ Prometheus OK"

if ! curl -s $ALERTMANAGER_URL > /dev/null; then
    echo "❌ Alertmanager not reachable at $ALERTMANAGER_URL"
    exit 1
fi
echo "✓ Alertmanager OK"

# Test 1: Target Down Alert (TargetDown)
echo ""
echo "2. Testing TargetDown alert..."
echo "   Stopping node-exporter to trigger up == 0 condition..."
docker compose stop node-exporter
sleep 10

FIRING=$(curl -s "$ALERTMANAGER_URL/api/v1/alerts?status=firing" | grep -c "TargetDown" || true)
if [ "$FIRING" -gt 0 ]; then
    echo "✓ TargetDown alert FIRED"
else
    echo "❌ TargetDown alert did NOT fire"
fi

docker compose start node-exporter
sleep 5

# Test 2: High Error Rate Alert
echo ""
echo "3. Testing HighErrorRate alert..."
echo "   Generating 500 errors to sample-app..."
for i in {1..100}; do
    curl -s "$SAMPLE_APP_URL/api/notfound" > /dev/null 2>&1 || true
done

sleep 30

FIRING=$(curl -s "$ALERTMANAGER_URL/api/v1/alerts?status=firing" | grep -c "HighErrorRate" || true)
if [ "$FIRING" -gt 0 ]; then
    echo "✓ HighErrorRate alert FIRED"
else
    echo "❌ HighErrorRate alert did NOT fire (may need more errors)"
fi

# Test 3: Check Alertmanager is routing alerts
echo ""
echo "4. Checking Alertmanager routing..."
curl -s $ALERTMANAGER_URL/api/v1/alerts | jq '.data | length'
echo "   (should see fired alerts in output above)"

echo ""
echo "=== Alert Testing Complete ==="
echo "View alerts in Alertmanager UI: $ALERTMANAGER_URL"
echo "View fired alerts in Prometheus: $PROMETHEUS_URL/alerts"
