# Lab 1: Exploring Prometheus Scrape Configs

**Time:** 30-40 minutes  
**Goal:** Understand how Prometheus knows which targets to scrape

## Background

Prometheus reads scrape configs from `prometheus.yml`. Docker Compose mounts `labs/prometheus.yml` into the Prometheus container at `/etc/prometheus/prometheus.yml`. Since docker-compose.yml runs from the labs/ directory, the mount path `./prometheus.yml` refers to the file at `labs/prometheus.yml` from the course root. You can modify this file and reload Prometheus to see changes take effect immediately.

## Lab: Add a Third Scrape Target

**Current targets:**
- prometheus (self-monitoring)
- node-exporter (system metrics)

**Goal:** Add "sample-endpoint" to scrape config and verify it appears in Prometheus.

### Steps

**Step 1: Examine current config**

```bash
cat labs/prometheus.yml
```

You should see:
```yaml
scrape_configs:
  - job_name: 'prometheus'
    ...
  - job_name: 'node-exporter'
    ...
  - job_name: 'sample-app'
    ...
```

**Step 2: Add sample-endpoint to the config**

Edit `labs/prometheus.yml` and add this after the existing jobs:

```yaml
  - job_name: 'sample-endpoint'
    static_configs:
      - targets: ['sample-endpoint:80']
```

**Step 3: Reload Prometheus**

Prometheus is configured with `--web.enable-lifecycle` flag. Reload config without restarting:

```bash
curl -X POST http://localhost:9090/-/reload
```

Expected: HTTP 200 OK (silent response)

**Step 4: Verify in UI**

Open http://localhost:9090, click **Status** > **Targets** tab.

You should now see 3 targets:
- prometheus (UP)
- node-exporter (UP)
- sample-endpoint (may be UP or DOWN — sample endpoint may not expose Prometheus metrics)

**Step 5: Check metrics count**

In Graph tab, type:

```
count(up)
```

Click Execute. Graph should show value `3` (you now have 3 targets).

## Solution

See `labs/module-1-fundamentals/solutions/lab-1-solution.yml`

## Troubleshooting

**Reload fails:**
- Prometheus not running. Try: `make setup`
- Verify curl worked: check stdout for "HTTP 200"

**sample-endpoint shows DOWN:**
- Expected — sample-endpoint doesn't expose Prometheus metrics by default
- Still counts as a target

**Can't edit .yml file:**
- Make sure you're editing `labs/prometheus.yml` in the labs directory

**Metrics didn't change:**
- May need to wait 15 seconds (scrape interval)
- Reload may not have worked; check Prometheus logs: `docker-compose logs prometheus | grep reload`

## Exit Criteria

- [ ] Modified labs/prometheus.yml
- [ ] Curl reload returns HTTP 200
- [ ] See 3 targets in Targets tab
- [ ] `count(up)` returns 3
