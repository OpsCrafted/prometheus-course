# Incident: Request Latency Spike

## Context
Your sample app is experiencing a sudden spike in request latency. Users are reporting that API requests that normally complete in ~100ms are now taking 2+ seconds.

## Symptoms
- p95 latency increased from 100ms to 2000ms (20x increase)
- Spike started at 14:32:00 UTC
- Request throughput remains stable (~120 req/sec)
- Only affects HTTP request handling, not database connectivity

## Your Challenge
Using Prometheus and PromQL, diagnose the root cause of this latency spike. The broken configuration contains a PromQL mistake that makes latency trends invisible.

## Success Criteria
- Identify what went wrong with the PromQL query
- Find the exact timestamp when the spike began
- Understand why the current query is broken
- Write the corrected query that shows the latency trend

## Time Estimate
30 minutes

## Hints
1. Check the `http_request_duration_seconds` histogram metrics
2. Look at the PromQL query in `broken-prometheus.yml`
3. Use `rate()` to convert counters into trends over time
4. Compare `[1m]` vs `[5m]` time windows
5. The `histogram_quantile()` function calculates percentiles from histograms
6. Missing `rate()` on counters makes minute-by-minute changes invisible

## Files
- `broken-prometheus.yml` - Configuration with the broken PromQL query
- `incident-data.json` - Timeline of the incident
- `solution.md` - Root cause analysis and fix
