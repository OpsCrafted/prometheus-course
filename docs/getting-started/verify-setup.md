# Verify Setup

Run these checks to confirm everything is working:

## 1. Docker Containers Running

```bash
docker-compose ps
```

Expected: 12 containers running:
- prometheus, grafana, alertmanager
- node-exporter, blackbox-exporter, pushgateway
- sample-app, load-generator
- postgres, postgres-exporter, redis, redis-exporter

All should show status `Up`.

## 2. Prometheus Health Check

```bash
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length'
```

Expected: `6` (prometheus, node-exporter, sample-app, postgres-exporter, redis-exporter, blackbox)

## 3. Prometheus UI

Open http://localhost:9090 in your browser.

### Check Targets Tab
- Click **Status** > **Targets**
- Expected: all 6 targets showing "UP" (prometheus, node-exporter, sample-app, postgres-exporter, redis-exporter, blackbox)
- Check **Last Scrape** times — should be recent (within last 15 seconds)

### Check Graph Tab
- Click **Graph** tab
- Type `up` in the query box
- Click **Execute**
- Expected: Graph showing metrics for each target (should be 6 lines, all at value 1)

## 4. First Query

In the Graph tab, type this query and click **Execute**:

```
node_memory_MemFree_bytes
```

Expected: Graph showing free memory over time (one line per target)

You should see the line fluctuating as the system's memory usage changes.

## 5. Count Query

In the Graph tab, type:

```
count(up)
```

Expected: Flat line at value `6` (you have 6 targets)

## Troubleshooting

**Prometheus UI doesn't load (ERR_CONNECTION_REFUSED):**
- Check: `docker-compose ps` — is prometheus running?
- If not running, restart: `make setup`
- Wait 30 seconds for startup

**Targets showing "DOWN":**
- Wait 30 seconds, refresh page
- Check Prometheus logs: `docker-compose logs prometheus`
- Node Exporter may take longer to start

**curl command fails (`Connection refused`):**
- Check Prometheus is running: `docker ps | grep prometheus`
- Try different URL: sometimes localhost doesn't work; try `http://127.0.0.1:9090`

**Query returns empty graph:**
- Prometheus may not have collected metrics yet
- Wait 30 seconds for at least one scrape cycle
- Check "Targets" tab to confirm targets are UP

## Next Steps

You're done with Getting Started!

Next: Head to Module 1, Day 1: [docs/module-1-fundamentals/day-1-architecture.md](../module-1-fundamentals/day-1-architecture.md)
