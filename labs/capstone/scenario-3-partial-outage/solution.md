# Solution: Missing Metrics from Partial Outage

## Root Cause

Configuration typo in prometheus.yml:
- node-exporter target is set to `localhost:9101`
- Actual service is running on `localhost:9100`
- Prometheus can't connect, scrape fails, metrics disappear

```yaml
- job_name: 'node-exporter'
  static_configs:
    - targets: ['localhost:9101']  # WRONG PORT!
```

## Diagnosis Steps

### Step 1: Check Targets Status

Visit the Targets API:
```bash
curl http://localhost:9090/api/v1/targets
```

Look for:
```json
{
  "job": "node-exporter",
  "state": "DOWN",
  "lastError": "connection refused",
  "scrape_url": "http://localhost:9101/metrics"
}
```

**Key insight:** `state: "DOWN"` means scrape is failing.

### Step 2: Check Prometheus UI

Go to http://localhost:9090/targets (not /api/v1/targets):
- Find node-exporter in the list
- Click it to expand details
- See the error message: "connection refused"
- Note the scrape URL: `http://localhost:9101/metrics`

### Step 3: Test Connectivity

```bash
# Try to connect to the target
curl http://localhost:9101/metrics
# Returns: curl: (7) Failed to connect to localhost port 9101

# Try the correct port
curl http://localhost:9100/metrics
# Returns: node exporter metrics (successful)
```

This confirms the port is wrong.

## Fix

Update prometheus.yml to use correct port:

```yaml
- job_name: 'node-exporter'
  static_configs:
    - targets: ['localhost:9100']  # CORRECT PORT
      labels:
        group: 'system'
```

Then:
1. Reload Prometheus config:
   ```bash
   curl -X POST http://localhost:9090/-/reload
   ```
   
2. Or restart Prometheus:
   ```bash
   docker-compose restart prometheus
   ```

## Verification

1. **Check Targets status:**
   ```bash
   curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.job=="node-exporter")'
   ```
   Should show `"state": "UP"` and no error message.

2. **Query metrics:**
   ```promql
   # In Prometheus graph tab
   node_cpu_seconds_total
   ```
   Should return data, not "no data".

3. **Check dashboards:**
   - System Overview should show CPU, memory, disk
   - Panels should have values, not "N/A"

## Key Learning

**Scrape Target Failures Cause Data Gaps:**

| Scenario | Behavior |
|----------|----------|
| Target UP | Metrics flowing, fresh data |
| Target DOWN | Metrics stale, no new data points |
| Target missing | Metric completely absent |

**Common target issues:**
1. Wrong hostname/IP address
2. Wrong port number (like this case)
3. Service not running
4. Firewall blocking connection
5. Prometheus can't resolve DNS
6. Target requires authentication

## Prevention

1. **Use health checks in docker-compose:**
   ```yaml
   node-exporter:
     image: prom/node-exporter
     ports:
       - "9100:9100"
     healthcheck:
       test: ["CMD", "curl", "-f", "http://localhost:9100/metrics"]
       interval: 30s
       timeout: 10s
       retries: 3
   ```

2. **Validate config on deploy:**
   ```bash
   # Dry-run Prometheus with new config
   promtool check config prometheus.yml
   ```

3. **Monitor target health:**
   ```promql
   # Alert if targets are down
   up{job="node-exporter"} == 0
   ```

4. **Review config changes:**
   - Verify targets after config updates
   - Test connectivity manually if unsure
   - Use version control for prometheus.yml
   - Review diffs before applying changes

## Next Steps

1. Apply the config fix
2. Verify all targets are UP
3. Check metric flow is restored
4. Add alert for scrape failures (see Prevention)
5. Review deployment process to catch such typos
