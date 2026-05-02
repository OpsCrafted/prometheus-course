# Broken Lab: Find & Fix the Prometheus Config

**Difficulty:** Hard (real-world debugging)
**Time:** 45-60 minutes
**Goal:** Diagnose why Prometheus isn't scraping targets. Fix configuration errors.

## The Scenario

Your colleague left the team. They set up Prometheus but didn't test it thoroughly. Now:
- Some targets show as DOWN
- Some metrics are missing entirely
- The config "looks fine" but something is wrong

Your job: Find the bugs and fix them.

## Your Turn

1. Start with broken configs in this directory
2. Load them into your local Prometheus (instructions below)
3. Check Status → Targets. Notice which targets are DOWN
4. Check Status → Configuration. Look for syntax or logical errors
5. Use logs to diagnose issues
6. Fix the configs
7. Verify all targets are UP and metrics appear
8. Compare your fixes to solution/README.md

## Step 1: Load Broken Config

```bash
# Copy broken configs into labs/ (temporarily)
cp labs/capstone/broken-lab/broken-prometheus.yml labs/prometheus.yml

# Restart Prometheus to load new config
docker compose restart prometheus

# Wait 30 seconds for scrape cycles
sleep 30

# Check targets
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

Expected: Some targets DOWN, some missing

## Step 2: Diagnose Issues

Check logs:
```bash
docker compose logs prometheus | tail -50
```

Check config syntax:
```bash
docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

Look at Status → Configuration in UI:
```
http://localhost:9090/config
```

## Step 3: Find All Bugs

There are 5 intentional bugs in the broken config. Your job:
- [ ] Find bug 1
- [ ] Find bug 2
- [ ] Find bug 3
- [ ] Find bug 4
- [ ] Find bug 5

## Step 4: Fix & Verify

After fixing, restart:
```bash
docker compose restart prometheus
sleep 30

# Verify all targets UP
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

Expected: All targets showing "health": "up"

## Step 5: Compare Solution

See solution/README.md for the 5 bugs and fixes.

## Learning Outcome

Real Prometheus debugging:
- Read error logs
- Use `promtool` to validate syntax
- Check scrape config logic
- Understand label and relabel behavior
- Verify fixes work end-to-end

This is exactly what on-call engineers do.
