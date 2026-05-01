# Day 1: Prometheus Architecture

**Time:** 90 minutes | **Prerequisites:** Getting Started completed, Docker running

## Learning Outcomes

- [ ] Understand Prometheus pull model vs push model
- [ ] Know key Prometheus components (scraper, TSDB, alertmanager)
- [ ] Identify how Prometheus differs from other monitoring systems

## Conceptual Explainer

### The Pull Model

Prometheus uses **pull-based** scraping, not push. Prometheus goes to systems and **fetches** metrics:

```
Client (metrics endpoint)
        ^
        | (HTTP GET /metrics)
        |
   Prometheus Scraper
        |
        v (stores in TSDB)
   Time-Series Database
```

**Push-based systems** (like Graphite) reverse this:

```
Client (sends metrics)
        |
        v (HTTP POST)
   Receiver (stores in DB)
```

**Why pull?** 
- Prometheus doesn't need client credentials upfront
- Can discover targets dynamically (no hard-coded list)
- Clients don't need to know where Prometheus is
- Central Prometheus instance controls scraping rate
- Simpler client implementation

### Key Components

1. **Prometheus Server** — main process that scrapes, stores, evaluates rules
2. **Scraper** — fetches metrics from HTTP endpoints (default: every 15 seconds)
3. **TSDB (Time-Series Database)** — compressed storage of metrics with timestamps
4. **Alertmanager** — separate service for alert routing (not in this course)
5. **Exporters** — small programs exposing metrics (e.g., Node Exporter for system metrics)

### Metrics Endpoint Format

Prometheus expects metrics in simple text format:

```
# HELP node_cpu_seconds_total Total user and system CPU time spent in seconds
# TYPE node_cpu_seconds_total counter
node_cpu_seconds_total{cpu="0",mode="idle"} 1234.56
node_cpu_seconds_total{cpu="0",mode="system"} 123.45
node_memory_MemFree_bytes 8589934592
```

Format: `metric_name{label1="value1",label2="value2"} value`

### Pull Model Advantages for Monitoring

- **Scrape control:** Prometheus decides when/how often to pull, avoiding overwhelming monitored systems
- **Target discovery:** Can use DNS, Kubernetes API, cloud provider APIs to discover targets automatically
- **No credentials in apps:** Apps expose simple HTTP endpoints; no auth needed
- **Firewall friendly:** Prometheus pushes outbound connections (typical for monitoring systems)

## Hands-On: Explore Prometheus UI

**Setup (5 min):**
```bash
make setup
```

**Exploration (30 min):**

1. Open http://localhost:9090 in browser
2. Click **Status** > **Targets**
   - See "prometheus" target (Prometheus scraping itself)
   - See "node-exporter" target (scraping Node Exporter)
   - Note **Last Scrape** times
3. Click **Graph** tab
4. Type `up{job="node-exporter"}` and click **Execute**
   - See graph with 1 line (node-exporter target)
   - Value is `1` (up) or `0` (down)
5. Type `node_memory_MemFree_bytes` and click **Execute**
   - See graph of free memory
   - Click **Table** tab to see raw values

**Discussion Questions:**
- How many scrape targets do you see?
- How often is Prometheus scraping? (look at time gaps)
- What do the labels tell you?

## Reference

**Prometheus vs Other Monitoring:**
| System | Model | Use Case |
|--------|-------|----------|
| Prometheus | Pull | Cloud-native, dynamic, high-cardinality metrics |
| Graphite | Push | Legacy, fixed hosts, lower-cardinality |
| InfluxDB | Push/Pull | Time-series DB, flexible |

**Glossary Sidebar:**
- **Time-series:** sequence of (timestamp, value) pairs
- **Scrape:** fetch metrics from a target
- **Target:** any system exposing metrics (host, pod, service)
- **Cardinality:** number of unique label combinations
- **TSDB:** database optimized for time-series (ordered by timestamp)

## Lab

See [lab-1-scrape-config.md](../../labs/module-1-fundamentals/lab-1-scrape-config.md)

## Exit Criteria

- [ ] Docker running: `docker-compose ps` shows 2 containers (prometheus, node-exporter)
- [ ] Prometheus responds: `curl http://localhost:9090/api/v1/targets`
- [ ] See at least 2 targets in UI (Targets tab)
- [ ] Can run query `up` and see results
- [ ] Can run query `node_memory_MemFree_bytes` and see results
