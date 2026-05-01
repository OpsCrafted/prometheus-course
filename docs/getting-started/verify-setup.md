# Verify Setup

Run these checks to confirm everything is working:

## 1. Docker Containers Running

```bash
docker-compose ps
```

Expected: 3 containers running (prometheus, node-exporter, sample-endpoint)

All should show status `Up`.

## 2. Prometheus Health Check

```bash
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length'
```

Expected: `2` (prometheus + node-exporter targets)

## 3. Prometheus UI

Open http://localhost:9090 in your browser.

### Check Targets Tab
- Click **Status** > **Targets**
- Expected: "prometheus" and "node-exporter" both showing "UP"
- Check **Last Scrape** times — should be recent (within last 15 seconds)

### Check Graph Tab
- Click **Graph** tab
- Type `up` in the query box
- Click **Execute**
- Expected: Graph showing metrics for each target (should be 2 lines, both at value 1)

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

Expected: Flat line at value `2` (you have 2 targets)

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
