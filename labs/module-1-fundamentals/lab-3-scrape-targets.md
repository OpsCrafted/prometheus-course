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
- redis (DOWN — fake target, doesn't expose /metrics)
- mysql (DOWN — fake target, doesn't exist)
- my-app (DOWN — fake target, doesn't exist)

**Step 4:** Query in Graph tab

```
count(up)
```

Should show `6` (prometheus, node-exporter, sample-app, postgres-exporter, redis-exporter, blackbox).

## Solution

See `labs/module-1-fundamentals/solutions/lab-3-solution.yml`

## Exit Criteria

- [ ] Added 3 new jobs to config
- [ ] Prometheus reloaded successfully
- [ ] Can see 9 jobs in Targets tab (6 UP, 3 DOWN)
