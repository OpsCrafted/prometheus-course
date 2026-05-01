#!/bin/bash
set -e
cd "$(dirname "$0")"
docker-compose up -d
echo "Waiting for Prometheus to start..."
sleep 3
curl -s http://localhost:9090/api/v1/query?query=up | jq . > /dev/null && echo "✓ Prometheus running" || echo "✗ Prometheus not responding"
echo "Prometheus UI: http://localhost:9090"
echo "Node Exporter: http://localhost:9100"
