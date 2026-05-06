# Content Correctness Round 2 Design

**Date:** 2026-05-06  
**Scope:** 5 targeted text/content fixes across 4 files. No code changes.

---

## Problem

| # | File | Issue |
|---|------|-------|
| 1 | `labs/module-3-promql/lab-12-joins.md` | Query 4 uses `http_request_duration_seconds > 0.1` — bare histogram name, returns empty in Prometheus |
| 2 | `labs/capstone/scenario-2-cardinality-explosion/solution.md` | Uses `relabel_configs` (operates on target labels) instead of `metric_relabel_configs` (operates on metric labels) — wrong stanza |
| 3 | `labs/capstone/scenario-3-partial-outage/solution.md` | Correct-fix YAML shows `localhost:9100` — Prometheus inside Docker can't reach node-exporter via localhost; must use service name |
| 4 | `README.md` | File tree comment says `# Prometheus + Node Exporter` — stack now has 12 services |
| 5 | `docs/capstone/capstone-challenges.md` | "Each scenario directory contains" lists `incident-data/` (dir), `solution/` (dir), `verify.sh` — none exist |

---

## Fix 1: lab-12-joins.md Query 4

**File:** `labs/module-3-promql/lab-12-joins.md`

Change Query 4 from:
```
http_request_duration_seconds > 0.1
```
Result: Requests slower than 100ms

To:
```
http_request_duration_seconds_count > 10
```
Result: Endpoints that have served more than 10 requests

**Why:** `http_request_duration_seconds` is a histogram family — no metric with that exact name exists. `_count` is a real scalar metric; the comparison operator is still demonstrated.

---

## Fix 2: scenario-2 solution — relabel_configs → metric_relabel_configs

**File:** `labs/capstone/scenario-2-cardinality-explosion/solution.md`

Three locations:

**Line 21 prose:** Change:
> Add relabel_configs to the sample-app job to drop request_id and trace_id before ingestion:

To:
> Add metric_relabel_configs to the sample-app job to drop request_id and trace_id after scraping:

**Line 31 YAML key:** Change:
```yaml
    relabel_configs:
```
To:
```yaml
    metric_relabel_configs:
```

**Line 88 bullet:** Change:
> Use relabel_configs to enforce this at scrape time

To:
> Use metric_relabel_configs to drop labels after scraping

**Why:** `relabel_configs` runs before scraping and operates on target labels (`job`, `instance`, `__address__`). To strip labels from scraped metrics (`request_id`, `trace_id`), `metric_relabel_configs` is required.

---

## Fix 3: scenario-3 solution — localhost:9100 → node-exporter:9100

**File:** `labs/capstone/scenario-3-partial-outage/solution.md`

Two locations (others are correct as-is):

**Line 7:** Change:
> Actual service is running on `localhost:9100`

To:
> Actual service is running on `node-exporter:9100`

**Line 66 YAML:** Change:
```yaml
    - targets: ['localhost:9100']  # CORRECT PORT
```
To:
```yaml
    - targets: ['node-exporter:9100']  # CORRECT: service name + port
```

**Leave unchanged:** Line 49/53 (`curl localhost:9100` from student's terminal — correct, port is exposed), line 128 (node-exporter's own healthcheck — `localhost` inside its own container is correct).

---

## Fix 4: README.md stack comment

**File:** `README.md`

**Line 164:** Change:
```
│   ├── docker-compose.yml        # Prometheus + Node Exporter
```
To:
```
│   ├── docker-compose.yml        # Full observability stack (12 services)
```

---

## Fix 5: capstone-challenges.md — fix nonexistent file list

**File:** `docs/capstone/capstone-challenges.md`

Replace the "Each scenario directory contains:" list (lines 63–65):
```
- `incident-data/` — pre-recorded metrics simulating the incident
- `README.md` — scenario setup and guided questions
- `solution/` — expected PromQL queries and fixes
- `verify.sh` — script to check your work
```

With what actually exists:
```
- `README.md` — scenario setup and guided questions
- `incident-data.json` — sample metrics data for the scenario
- `solution.md` — root cause analysis and recommended fix
- `broken-prometheus.yml` — the misconfigured file to debug
```

Also remove the process steps that reference nonexistent structure (lines 69–74):
```
**Process:**
1. Read the scenario README
2. Load incident data into your Prometheus
3. Answer guided questions using PromQL
4. Compare your queries against solution/
5. Implement recommended fixes in your config
```

Replace with:
```
**Process:**
1. Read the scenario README
2. Review `incident-data.json` to understand the failure context
3. Answer the guided questions using PromQL
4. Compare your approach against `solution.md`
5. Implement the recommended config fixes
```

---

## What Does NOT Change

- Any lab guide teaching content
- Prometheus configs, Docker Compose, Makefile
- Other scenario files not listed above
- Lines 49, 53, 128 in scenario-3 solution (correct localhost usage)
