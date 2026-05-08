# Lab 4 Solution: Fix Broken Setup

## Issue Identified

The broken config only has 2 jobs (`prometheus` and `node-exporter`). It is missing 4 jobs that should be configured: `sample-app`, `postgres-exporter`, `redis-exporter`, and `blackbox`.

## Fixed Config

Add the missing 4 jobs so the complete config matches `labs/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
        labels:
          group: 'system'

  - job_name: 'sample-app'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['sample-app:8080']
        labels:
          group: 'application'

  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['postgres-exporter:9187']
        labels:
          group: 'database'

  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['redis-exporter:9121']
        labels:
          group: 'cache'

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - http://sample-app:8080
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - replacement: blackbox-exporter:9115
        target_label: __address__
```

Note: if you also completed Lab 1, your config will also have the `pushgateway` job, giving you 7 targets total.

## Verification Steps

1. **Reload config:**
   ```bash
   curl -X POST http://localhost:9090/-/reload
   ```

2. **Check Targets tab:**
   - Should see 6 jobs all UP (7 if pushgateway was added in Lab 1):
   - prometheus, node-exporter, sample-app, postgres-exporter, redis-exporter, blackbox

3. **Verification Query:**
   ```promql
   count(count by (job) (up))
   ```
   Should return `6` (or `7` if pushgateway was added).

## Key Lesson

Always check the complete job list in `labs/prometheus.yml`. Missing a job means Prometheus won't scrape it, and those metrics won't appear in the database. The Targets tab shows which jobs are currently configured — use it to verify your config changes took effect.
