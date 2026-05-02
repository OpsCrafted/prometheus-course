# Incident: Missing Metrics from Partial Outage

## Context
Your dashboards are showing incomplete data. Some metrics are present but others are completely missing. Users can see application metrics but system metrics have disappeared. Investigation reveals that a scrape target is failing to be reached.

## Symptoms
- node-exporter metrics are missing (CPU, memory, disk)
- sample-app and prometheus metrics are present
- Dashboards show "N/A" or "no data" for system panels
- Recent configuration change (typo in target hostname/port)

## Your Challenge
Identify which scrape target is DOWN and fix the Prometheus configuration to restore all metrics.

## Success Criteria
- Use the Prometheus Targets API to find the failed scrape
- Identify the incorrect target configuration
- Fix the configuration (wrong hostname or port)
- Verify all targets are UP and metrics are available

## Time Estimate
30 minutes

## Hints
1. Visit http://localhost:9090/api/v1/targets to see target status
2. A DOWN target will show error message with connection details
3. Common issues: wrong hostname, wrong port, firewall blocking
4. Check if the target service is actually running
5. Prometheus logs will show scrape errors
6. Use telnet/nc to test connectivity to target

## Files
- `broken-prometheus.yml` - Config with incorrect target (wrong port)
- `incident-data.json` - Targets API response showing DOWN status
- `solution.md` - How to diagnose and fix target issues
