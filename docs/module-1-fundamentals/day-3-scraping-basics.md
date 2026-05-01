# Day 3: Scraping Basics

**Time:** 90 minutes | **Prerequisites:** Days 1-2 completed

## Learning Outcomes

- [ ] Understand scrape configs (`prometheus.yml`)
- [ ] Know how to add a new scrape target
- [ ] Understand basic relabeling and service discovery

## Conceptual Explainer

Prometheus learns about targets via `scrape_configs` in `prometheus.yml`.

### Simple Scrape Config

```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

This tells Prometheus: "Every 15 seconds, fetch `http://localhost:9090/metrics`"

The Prometheus server exposes its own metrics, so it scrapes itself.

### Adding More Targets

```yaml
scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['localhost:8000', 'localhost:8001']  # Multiple targets
```

This creates 2 targets under job "my-app". Prometheus will scrape both on the scrape interval.

### Scrape Config Fields

- `job_name` — Name of the job (label added to all metrics)
- `static_configs` — Hard-coded list of targets
- `targets` — List of `host:port` to scrape
- `scrape_interval` — How often to scrape (default: 15s from global)
- `metrics_path` — Path to metrics endpoint (default: `/metrics`)
- `scheme` — HTTP or HTTPS (default: `http`)

### Labels Added Automatically

Every scraped metric gets labels:
- `job` — job name from config
- `instance` — target address (host:port)

Example: `up{job="prometheus",instance="localhost:9090"}`

### Reloading Config

You can reload the config without restarting Prometheus:

```bash
curl -X POST http://localhost:9090/-/reload
```

This picks up new targets, changed intervals, etc. No downtime.

## Hands-On: Add a New Target

We'll modify the scrape config to add a new job.

**Step 1:** Check current targets

```bash
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length'
```

Should show how many targets are currently configured.

**Step 2:** Edit config

```bash
vim labs/module-1-fundamentals/lab-1-prometheus.yml
```

Add this new job:

```yaml
  - job_name: 'my-test-job'
    static_configs:
      - targets: ['localhost:9999']  # This target doesn't exist yet
```

**Step 3:** Reload Prometheus

```bash
curl -X POST http://localhost:9090/-/reload
```

**Step 4:** Verify in UI

Open http://localhost:9090, click **Status** > **Targets**

You should see the new job. It will show "DOWN" (because localhost:9999 doesn't exist).

## Scrape Behavior

**On each scrape interval (default 15s):**
1. Prometheus connects to target
2. Fetches `/metrics` endpoint
3. Parses all metrics from response
4. Stores them with `job` and `instance` labels
5. If target is unreachable: `up=0` for that target

**Scrape timeout:** Default 10 seconds. If a target takes longer, scrape fails.

## Reference

**Scrape Config Defaults:**
```yaml
global:
  scrape_interval: 15s      # default for all jobs
  evaluation_interval: 15s  # for alerting rules
  scrape_timeout: 10s       # timeout per target

scrape_configs:
  - job_name: 'myjob'
    scrape_interval: 30s    # override global for this job (optional)
    metrics_path: '/metrics'  # endpoint path
    scheme: 'http'           # http or https
    static_configs:
      - targets: ['host:port']
        labels:              # custom labels (optional)
          datacenter: 'us-west'
```

**Global defaults apply to all jobs unless overridden.**

## Lab

See [lab-3-scrape-targets.md](../../labs/module-1-fundamentals/lab-3-scrape-targets.md)

## Exit Criteria

- [ ] Know scrape config structure and fields
- [ ] Can add new target to config
- [ ] Can reload Prometheus without restart
- [ ] Understand auto-added labels (job, instance)
