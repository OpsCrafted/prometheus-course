# Day 4: Fundamentals Review & Capstone

**Time:** 90 minutes | **Prerequisites:** Days 1-3 completed

## Learning Outcomes

- [ ] Integrate architecture + metrics model + scraping configs
- [ ] Diagnose why a target is DOWN
- [ ] Fix a broken scrape config

## Review: 3 Concepts Together

**Prometheus Architecture (Day 1):**
- Pull-based: Prometheus fetches `/metrics` from targets
- TSDB stores time-series with labels
- Scraper runs on interval (default 15s)
- Relabeling can modify labels before storage

**Metrics Model (Day 2):**
- Gauge: value up/down
- Counter: only increases
- Histogram: bucket distribution
- Summary: pre-computed quantiles
- Each metric has job + instance labels automatically

**Scraping Basics (Day 3):**
- Scrape config defines targets in prometheus.yml
- Reload without restart: `curl -X POST http://localhost:9090/-/reload`
- Targets show UP or DOWN in UI
- Each metric gets `job` and `instance` labels

## How They Work Together

1. **Config defines targets** (prometheus.yml)
2. **Prometheus scrapes on interval** (15s by default)
3. **Metrics flow in** with automatic labels
4. **You query the metrics** (up, down, values)

Example flow:
```
prometheus.yml → Define job "node" targeting localhost:9100
                ↓
           Scraper fetches /metrics from target
                ↓
           Parse metrics: node_cpu_seconds_total, node_memory_MemFree_bytes, etc.
                ↓
           Add labels: job="node", instance="localhost:9100"
                ↓
           Store in TSDB
                ↓
           Query: up{job="node"} → returns 1 (or 0 if DOWN)
```

## Capstone Lab: Debug Broken Config

You're given a broken Prometheus config. Your job: diagnose and fix it.

**The Problem:** Some targets are missing from Prometheus that should be there.

See [lab-4-debug.md](../../labs/module-1-fundamentals/lab-4-debug.md)

## Exit Criteria

- [ ] Identified why targets are missing
- [ ] Fixed the config
- [ ] Verified targets now appear
- [ ] Wrote PromQL query proving fix works
