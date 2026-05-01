# Getting Started with Prometheus

**Time:** 2-3 hours  
**Goal:** Set hands-on context before diving into theory. Get Prometheus running, write first PromQL queries.

## What You'll Do

1. Start Prometheus via Docker
2. Explore Prometheus UI
3. Write 5 basic PromQL queries

## Prerequisites

- Docker + Docker Compose installed
- ~1 hour free time
- Basic Linux/command line familiarity

## Steps

1. **Setup Docker:** [docker-setup.md](docker-setup.md)
2. **Verify Everything Works:** [verify-setup.md](verify-setup.md)
3. **Write First Queries:** Follow the "First PromQL Queries" section below

## First PromQL Queries

Once Prometheus is running at http://localhost:9090, try these 5 queries in the Graph tab:

1. `up` — is each target up? (0 = down, 1 = up)
2. `node_cpu_seconds_total` — total CPU seconds by mode
3. `node_memory_MemFree_bytes` — free memory in bytes
4. `count(up)` — count of targets
5. `rate(node_cpu_seconds_total[5m])` — CPU usage rate (don't worry if error; we'll explain in Day 11)

**Exit Criteria:**
- [ ] Docker running smoothly
- [ ] Prometheus UI loads at http://localhost:9090
- [ ] Can run all 5 queries above
- [ ] Prometheus "Targets" tab shows at least 2 targets (prometheus, node-exporter)
