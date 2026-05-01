# Lab 4 Solution: Fix Broken Setup

## Issue Identified

The config is missing the `sample-endpoint` job that was configured in the original setup.

## Fixed Config

Add this job to the scrape_configs:

```yaml
  - job_name: 'sample-endpoint'
    static_configs:
      - targets: ['sample-endpoint:80']
```

Full corrected config:

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

  - job_name: 'sample-endpoint'
    static_configs:
      - targets: ['sample-endpoint:80']
```

## Verification Steps

1. **Reload config:**
   ```bash
   curl -X POST http://localhost:9090/-/reload
   ```

2. **Check Targets tab:**
   - Should see 3 jobs
   - prometheus (UP)
   - node-exporter (UP)
   - sample-endpoint (UP or DOWN depending on container state)

3. **Verification Query:**
   ```
   count(count by (job) (up))
   ```
   Should return `3`.

## Key Lesson

Always check the complete job list in prometheus.yml. Missing a job means Prometheus won't scrape it, and those metrics won't appear in the database.
