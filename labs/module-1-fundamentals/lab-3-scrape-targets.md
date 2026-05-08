# Lab 3: Adding Scrape Targets

**Time:** 25-30 minutes  
**Goal:** Practice modifying scrape configs and reloading Prometheus

## Lab: Create 3 New Jobs

Edit `labs/prometheus.yml` and add 3 new jobs:

1. Job named `redis` targeting `localhost:6379` (Redis doesn't run, will show DOWN)
2. Job named `mysql` targeting `localhost:3306` (MySQL doesn't run, will show DOWN)
3. Job named `my-app` targeting `localhost:8000` (doesn't run, will show DOWN)

After adding all 3:

```yaml
  - job_name: 'redis'
    static_configs:
      - targets: ['localhost:6379']

  - job_name: 'mysql'
    static_configs:
      - targets: ['localhost:3306']

  - job_name: 'my-app'
    static_configs:
      - targets: ['localhost:8000']
```

**Step 1:** Edit file

```bash
vim labs/prometheus.yml
```

**Step 2:** Reload Prometheus

```bash
curl -X POST http://localhost:9090/-/reload
```

**Step 3:** Verify

Open http://localhost:9090, click **Status** > **Targets**

You should see 9 jobs now:
- prometheus (UP)
- node-exporter (UP)
- sample-app (UP)
- postgres-exporter (UP)
- redis-exporter (UP)
- blackbox (UP)
- pushgateway (UP — added in Lab 1)
- redis (DOWN — fake target, doesn't expose /metrics)
- mysql (DOWN — fake target, doesn't exist)
- my-app (DOWN — fake target, doesn't exist)

Wait — that's 10. If you haven't done Lab 1 yet, you'll see 8 (without pushgateway). If you have, you'll see 9 real jobs + 3 fake = 10 total (7 UP, 3 DOWN).

**Step 4:** Query in Graph tab

```
count(up)
```

Should show `6` or `7` depending on whether you completed Lab 1 (which adds pushgateway). The 3 fake DOWN jobs don't appear in `count(up)` — that query only counts targets currently UP.

## Solution

See `labs/module-1-fundamentals/solutions/lab-3-solution.yml`

## Exit Criteria

- [ ] Added 3 new jobs to config
- [ ] Prometheus reloaded successfully
- [ ] Can see 3 new DOWN jobs in Targets tab alongside existing UP jobs
