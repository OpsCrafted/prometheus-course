# Incident: Memory Explosion from Cardinality

## Context
Prometheus memory usage has tripled overnight. The TSDB is ingesting millions of new time series at an alarming rate. Your dashboards are slow, and the Prometheus server is running out of memory.

## Symptoms
- Unique series count grew from 50K to 5M in 8 hours
- Memory usage jumped from 400MB to 3.2GB
- Prometheus is scraping new series every second
- Only happened after a recent deployment that added request tracing

## Your Challenge
Identify which labels are causing the cardinality explosion and fix the Prometheus configuration to drop these unbounded labels.

## Success Criteria
- Identify the high-cardinality labels (request_id, trace_id)
- Understand why these labels destroy time series databases
- Update prometheus.yml to drop these labels
- Verify that unique series count drops back to ~50K

## Time Estimate
30 minutes

## Hints
1. High-cardinality labels are ones with many unique values (like request_id, user_hash, session_id)
2. Unbounded labels create one time series per unique value
3. With 2M unique request_ids, you get 2M time series per metric
4. Prometheus relabel_configs can drop labels before ingestion
5. Check the Prometheus targets and metrics endpoint
6. Look for metrics with unusual label combinations

## Files
- `broken-prometheus.yml` - Config without label dropping rules
- `incident-data.json` - Series count timeline and problematic labels
- `solution.md` - Root cause and fix using relabel_configs
