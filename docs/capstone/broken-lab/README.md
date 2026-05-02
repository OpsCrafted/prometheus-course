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

## Debugging SOP (Standard Operating Procedure)

When something breaks, follow this systematic process. Learning the *method* is more valuable than memorizing fixes.

### Phase 1: Observe the Problem

**Step 1: Check Prometheus UI → Status → Targets**

Navigate to:
```
http://localhost:9090/targets
```

Look for:
- 🔴 RED = target DOWN (can't connect)
- 🟡 YELLOW = target flapping (intermittent failures)
- 🟢 GREEN = target UP (scraping successfully)

This is the fastest way to spot failures. *What* is broken?

### Phase 2: Find the Root Cause

**Step 2: Check Container Logs**

```bash
docker compose logs prometheus | tail -100
```

Look for these error patterns:
- `dial tcp: connection refused` → wrong port or target not listening
- `YAML syntax error` → config indentation or format broken
- `invalid relabel action` → typo in relabel_configs
- `scrape config validation failed` → structural config error

Logs tell you *why* it broke.

**Step 3: Test Connectivity Directly**

```bash
# Try to reach the target from inside the container
docker compose exec prometheus wget -q -O - http://node-exporter:9100/metrics | head -20
```

This isolates the problem:
- **wget works, Prometheus target DOWN** → Prometheus config/scrape issue
- **wget fails** → target is down or network unreachable

**Step 4: Validate Config Syntax**

```bash
docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

`promtool` catches YAML errors before Prometheus loads them. *How* is it broken?

### Phase 3: Locate Exactly Where

**Step 5: Check Active Config in Prometheus UI**

```
http://localhost:9090/config
```

See exactly what Prometheus loaded. Reveals indentation, parsing, or truncation errors.

---

## Step 2: Diagnose Issues (Using SOP)

Now apply the SOP above to find the 5 bugs:

1. Check Targets UI for RED/DOWN states
2. Check logs for error messages
3. Test connectivity to failing targets
4. Validate config syntax with promtool
5. Review active config in Prometheus UI

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
