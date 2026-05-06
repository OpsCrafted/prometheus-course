# Docker Setup

## Quick Start

From the repo root:

```bash
make setup
```

This runs `labs/setup.sh`, which:
1. Starts Docker Compose (full observability stack: 12 services)
2. Waits 3 seconds for services to boot
3. Retries up to 10 times with 2-second delays if Prometheus doesn't respond
4. Verifies Prometheus responds to a health check

## Manual Setup (if `make setup` fails)

```bash
cd labs
docker compose up -d
```

Then verify:
```bash
curl -s http://localhost:9090/api/v1/query?query=up | jq .
```

Expected output: JSON with `"status":"success"` and data showing which targets are up.

## Verify Services

- **Prometheus:** http://localhost:9090 (query UI)
- **Node Exporter:** http://localhost:9100/metrics (raw metrics endpoint)
- **Sample Endpoint:** http://localhost:8080 (dummy service)

## Stopping Services

```bash
cd labs && docker compose down
```

This stops containers but keeps data.

## Reset Everything

```bash
make reset
```

This stops, removes volumes, and restarts fresh.

## Troubleshooting

**Containers won't start:**
- Check logs: `docker compose logs`
- Verify Docker is running: `docker ps`

**Port already in use:**
- Port 9090, 9100, or 8080 may be taken
- Run: `lsof -i :9090` to see what's using the port
- Either stop that service or modify docker compose.yml port mappings

**Prometheus shows "DOWN" targets:**
- Wait 30 seconds and refresh UI
- Check logs: `docker compose logs prometheus`
