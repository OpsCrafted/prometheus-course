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
