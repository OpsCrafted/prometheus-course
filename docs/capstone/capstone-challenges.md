# Capstone Challenges: Production Incident Scenarios

**Estimated time:** 4-6 hours (1-2 hours per scenario)

After completing Modules 1-3, tackle three real-world monitoring incidents. Each scenario teaches you to think like an on-call engineer: detect problems in real data, diagnose root cause, and fix monitoring.

## Prerequisites

- Complete all three modules (Days 1-15)
- Docker environment running (`make setup`)
- Comfortable with PromQL queries and Prometheus config

---

## Scenario 1: Latency Spike

**Location:** `labs/capstone/scenario-1-latency-spike/`

**What happens:** Requests to sample app suddenly take 10-20x longer. Dashboard shows traffic is normal. Root cause is subtle.

**What you'll learn:**
- How to detect latency anomalies with `histogram_quantile()`
- Correlate latency with other metrics (CPU, disk I/O, database queries)
- Distinguish between app-level and infrastructure issues

**Time estimate:** 1-2 hours

---

## Scenario 2: Cardinality Explosion

**Location:** `labs/capstone/scenario-2-cardinality-explosion/`

**What happens:** Prometheus runs out of memory. TSDB stops accepting new series.

**What you'll learn:**
- How unbounded labels cause metric cardinality to explode
- Debug cardinality issues in Prometheus
- Apply label design best practices to fix instrumentation

**Time estimate:** 1-2 hours

---

## Scenario 3: Partial Outage

**Location:** `labs/capstone/scenario-3-partial-outage/`

**What happens:** Some scrape targets fail silently. Dashboards show partial data. Alerts don't fire correctly.

**What you'll learn:**
- Detect missing scrape targets with `up` metric
- Troubleshoot scrape config and relabel rules
- Use alerting to catch scrapes that fail

**Time estimate:** 1-2 hours

---

## How to Work Through a Scenario

Each scenario directory contains:
- `incident-data/` — pre-recorded metrics simulating the incident
- `README.md` — scenario setup and guided questions
- `solution/` — expected PromQL queries and fixes
- `verify.sh` — script to check your work

**Process:**
1. Read the scenario README
2. Load incident data into your Prometheus
3. Answer guided questions using PromQL
4. Compare your queries against solution/
5. Implement recommended fixes in your config

---

## Success Criteria

- [ ] Scenario 1: Write 3+ PromQL queries detecting the latency spike
- [ ] Scenario 2: Identify root cause (high cardinality label)
- [ ] Scenario 3: Fix scrape config and verify all targets UP

---

## Next Steps

After capstone, you're ready for real production monitoring work. Revisit Prometheus docs for advanced topics like federation, long-term storage, and Alertmanager routing.

Happy monitoring!
