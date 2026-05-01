# Lab 4: Debug a Broken Setup

**Time:** 30-40 minutes  
**Goal:** Diagnose and fix a broken Prometheus config

## Scenario

Your colleague created a Prometheus config but made 3 mistakes. Metrics from targets are missing.

## The Broken Config

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  # Missing job here — what should go here?
```

## Your Task

1. **Identify:** What's missing from the config?
2. **Fix:** Add the missing scrape job
3. **Verify:** Check that targets appear in Prometheus
4. **Query:** Write a PromQL query that proves the fix works

## Hints

- Check the original lab-1-prometheus.yml to see what jobs were originally configured
- Without complete config, some targets won't appear in Prometheus UI
- Check Prometheus Targets tab to see which jobs are configured

## Solution

Check the original config and add any missing jobs:

```yaml
  - job_name: 'sample-endpoint'
    static_configs:
      - targets: ['sample-endpoint:80']
```

Then reload: `curl -X POST http://localhost:9090/-/reload`

Verify: Open Targets tab, count all jobs.

## Verification Query

In Graph tab, type:

```
count(count by (job) (up))
```

This counts unique jobs. Compare before/after your fix.

## Exit Criteria

- [ ] Identified missing job(s)
- [ ] Added all jobs to config
- [ ] Reloaded Prometheus
- [ ] Verified targets in Targets tab
- [ ] Query shows correct number of jobs
