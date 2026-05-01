#!/bin/bash
set -e
cd "$(dirname "$0")"
docker-compose up -d
echo "Waiting for Prometheus to start..."

# Retry health check up to 10 times
max_retries=10
retry=0
while [ $retry -lt $max_retries ]; do
  if curl -s http://localhost:9090/api/v1/query?query=up | jq . > /dev/null 2>&1; then
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

echo "Prometheus UI: http://localhost:9090"
echo "Node Exporter: http://localhost:9100"
echo "Sample Endpoint: http://localhost:8080"
