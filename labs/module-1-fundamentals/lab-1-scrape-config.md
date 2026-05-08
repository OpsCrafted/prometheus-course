# Lab 1: Exploring Prometheus Scrape Configs

**Time:** 30-40 minutes  
**Goal:** Understand how Prometheus knows which targets to scrape

## Background

Prometheus reads scrape configs from `prometheus.yml`. Docker Compose mounts `labs/prometheus.yml` into the Prometheus container at `/etc/prometheus/prometheus.yml`. Since docker-compose.yml runs from the labs/ directory, the mount path `./prometheus.yml` refers to the file at `labs/prometheus.yml` from the course root. You can modify this file and reload Prometheus to see changes take effect immediately.

## Lab: Add a New Scrape Target

**Current targets (6 already configured):**
- prometheus (self-monitoring)
- node-exporter (system metrics)
- sample-app (the Go application)
- postgres-exporter (database metrics)
- redis-exporter (cache metrics)
- blackbox (HTTP probe)

**Goal:** Add `pushgateway` as a 7th scrape target and verify it appears in Prometheus.

Pushgateway is already running in the stack (port 9091) but not yet scraped — a realistic scenario where a service exists but hasn't been wired into monitoring yet.

### Steps

**Step 1: Examine current config**

```bash
cat labs/prometheus.yml
```

You should see 6 jobs under `scrape_configs`.

**Step 2: Add pushgateway to the config**

Edit `labs/prometheus.yml` and add this after the existing jobs:

```yaml
  - job_name: 'pushgateway'
    static_configs:
      - targets: ['pushgateway:9091']
```

**Step 3: Reload Prometheus**

Prometheus is configured with `--web.enable-lifecycle` flag. Reload config without restarting:

```bash
curl -X POST http://localhost:9090/-/reload
```

Expected: HTTP 200 OK (silent response)

**Step 4: Verify in UI**

Open http://localhost:9090, click **Status** > **Targets** tab.

You should now see 7 targets, all UP — including the new `pushgateway` job.

**Step 5: Check metrics count**

In Graph tab, type:

```
count(up)
```

Click Execute. Graph should show value `7` (all 7 targets now scraped).

## Solution

See `labs/module-1-fundamentals/solutions/lab-1-solution.yml`

## Troubleshooting

**Reload fails:**
- Prometheus not running. Try: `make setup`
- Verify curl worked: check stdout for "HTTP 200"

**Can't edit .yml file:**
- Make sure you're editing `labs/prometheus.yml` in the labs directory

**Metrics didn't change:**
- May need to wait 15 seconds (scrape interval)
- Reload may not have worked; check Prometheus logs: `docker compose logs prometheus | grep reload`

## Exit Criteria

- [ ] Modified labs/prometheus.yml to add pushgateway job
- [ ] Curl reload returns HTTP 200
- [ ] See 7 targets in Targets tab (all UP)
- [ ] `count(up)` returns 7
