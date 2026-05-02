#!/bin/bash
# Validation script for Prometheus course setup

set -e
cd "$(dirname "$0")"

echo "=== Prometheus Course Setup Validator ==="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILED=0

# Helper function to print success
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Helper function to print failure
fail() {
    echo -e "${RED}✗${NC} $1"
    FAILED=1
}

# Check Docker installed
echo -n "Checking Docker installation... "
if command -v docker &> /dev/null; then
    success "installed"
else
    fail "Docker not found. Install from https://docs.docker.com/get-docker/"
    exit 1
fi

# Check Docker running
echo -n "Checking Docker daemon... "
if docker ps &> /dev/null; then
    success "running"
else
    fail "Docker not running. Start Docker and try again."
    exit 1
fi

# Check Docker Compose
echo -n "Checking Docker Compose... "
if docker compose version &> /dev/null; then
    success "installed"
else
    fail "Docker Compose not found. Install: https://docs.docker.com/compose/install/"
    exit 1
fi

# Check curl availability
echo -n "Checking curl... "
if command -v curl &> /dev/null; then
    success "installed"
else
    fail "curl is required but not installed."
    exit 1
fi

# Check docker-compose.yml validity
echo -n "Validating docker-compose.yml... "
if docker compose config > /dev/null 2>&1; then
    success "valid"
else
    fail "docker-compose.yml has errors. Run: docker compose config"
    exit 1
fi

# Start services
echo -n "Starting Docker Compose services... "
docker compose up -d || { fail "docker compose up failed"; exit 1; }
success "started (waiting for Prometheus to be ready...)"

for i in $(seq 1 15); do
  if curl -s --max-time 2 --connect-timeout 2 "http://localhost:9090/-/ready" > /dev/null 2>&1; then
    break
  fi
  [ "$i" -eq 15 ] && { fail "Prometheus not ready after 30s"; exit 1; }
  sleep 2
done

# Check services are running
echo -n "Checking service status... "
if docker compose ps | grep -q "prometheus"; then
    success "services running"
else
    fail "Services failed to start"
    exit 1
fi

# Check Prometheus health
echo -n "Checking Prometheus health... "
if curl -s --max-time 5 "http://localhost:9090/api/v1/query?query=up" | grep -q prometheus; then
    success "responding"
else
    fail "Prometheus not responding. Check: docker compose logs prometheus"
    exit 1
fi

# Check for at least 2 UP targets
echo -n "Checking Prometheus targets... "
TARGET_COUNT=$(curl -s --max-time 5 "http://localhost:9090/api/v1/query?query=up" | jq '[.data.result[] | select(.value[1]=="1")] | length // 0' 2>/dev/null || curl -s --max-time 5 "http://localhost:9090/api/v1/query?query=up" | grep -o '"value":\[[^]]*"[01]"' | wc -l)
if [ "$TARGET_COUNT" -ge 2 ]; then
    success "$TARGET_COUNT targets UP"
else
    fail "Less than 2 targets UP (found: $TARGET_COUNT). Check: http://localhost:9090/targets"
    FAILED=1
fi

# Check sample app
echo -n "Checking sample-app... "
if curl -s --max-time 5 "http://localhost:8080" | grep -q "Hello"; then
    success "responding"
else
    fail "sample-app not responding. Check: docker compose logs sample-app"
    FAILED=1
fi

# Check metrics endpoint
echo -n "Checking metrics endpoint... "
if curl -s --max-time 5 "http://localhost:8080/metrics" | grep -q "http_requests_total"; then
    success "exposing metrics"
else
    fail "Metrics not available. Check: docker compose logs sample-app"
    FAILED=1
fi

# Check Grafana
echo -n "Checking Grafana... "
if curl -s --max-time 5 "http://localhost:3000" | grep -q "Grafana"; then
    success "responding"
else
    fail "Grafana not responding. Check: docker compose logs grafana"
    FAILED=1
fi

echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}=== ✓ Setup validation passed! ===${NC}"
    echo ""
    echo "Services available at:"
    echo "  Prometheus: http://localhost:9090"
    echo "  Grafana:    http://localhost:3000 (admin/admin)"
    echo "  Sample App: http://localhost:8080"
    echo ""
    exit 0
else
    echo -e "${RED}=== ✗ Setup validation failed ===${NC}"
    echo ""
    echo "Troubleshooting tips:"
    echo "  • Check logs: docker compose logs <service-name>"
    echo "  • Ensure ports 3000, 8080, 9090, 5432, 6379 are available"
    echo "  • Try restarting: make clean && make setup"
    echo ""
    exit 1
fi
