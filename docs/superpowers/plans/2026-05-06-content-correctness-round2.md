# Content Correctness Round 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 5 content correctness issues across 4 files — all text-only changes, no code.

**Architecture:** Four independent tasks, one commit each. Each task touches one file. Verification is grep-based: confirm wrong text is gone and correct text is present.

**Tech Stack:** Markdown, YAML snippets embedded in markdown.

---

## File Map

| File | Change |
|------|--------|
| `labs/module-3-promql/lab-12-joins.md` | Fix Query 4 — bare histogram name → `_count` suffix |
| `labs/capstone/scenario-2-cardinality-explosion/solution.md` | `relabel_configs` → `metric_relabel_configs` in 3 locations |
| `labs/capstone/scenario-3-partial-outage/solution.md` | `localhost:9100` → `node-exporter:9100` in 2 locations |
| `README.md` + `docs/capstone/capstone-challenges.md` | Stack comment + nonexistent file list |

---

### Task 1: Fix lab-12 Query 4 (bare histogram name)

**Files:**
- Modify: `labs/module-3-promql/lab-12-joins.md`

- [ ] **Step 1: Make the change**

Find this block in `labs/module-3-promql/lab-12-joins.md`:

```markdown
**Query 4:** Comparison (slow requests)
```
http_request_duration_seconds > 0.1
```
Result: Requests slower than 100ms
```

Replace with:

```markdown
**Query 4:** Comparison (active endpoints)
```
http_request_duration_seconds_count > 10
```
Result: Endpoints that have served more than 10 requests
```

- [ ] **Step 2: Verify**

```bash
grep "http_request_duration_seconds > 0.1" labs/module-3-promql/lab-12-joins.md
```
Expected: (empty — old query gone)

```bash
grep "http_request_duration_seconds_count > 10" labs/module-3-promql/lab-12-joins.md
```
Expected: one match

- [ ] **Step 3: Commit**

```bash
git add labs/module-3-promql/lab-12-joins.md
git commit -m "fix: replace nonexistent histogram name in lab-12 Query 4"
```

---

### Task 2: Fix scenario-2 relabel_configs → metric_relabel_configs

**Files:**
- Modify: `labs/capstone/scenario-2-cardinality-explosion/solution.md`

Three locations in the same file.

- [ ] **Step 1: Fix line 21 prose**

Find:
```
Add relabel_configs to the sample-app job to drop request_id and trace_id before ingestion:
```

Replace with:
```
Add metric_relabel_configs to the sample-app job to drop request_id and trace_id after scraping:
```

- [ ] **Step 2: Fix line 31 YAML key**

Find:
```yaml
    relabel_configs:
      - action: labeldrop
        regex: '(request_id|trace_id)'
```

Replace with:
```yaml
    metric_relabel_configs:
      - action: labeldrop
        regex: '(request_id|trace_id)'
```

- [ ] **Step 3: Fix line 88 bullet**

Find:
```
3. Use relabel_configs to enforce this at scrape time
```

Replace with:
```
3. Use metric_relabel_configs to drop labels after scraping
```

- [ ] **Step 4: Verify**

```bash
grep "relabel_configs" labs/capstone/scenario-2-cardinality-explosion/solution.md
```

Expected output — only `metric_relabel_configs` remains, no bare `relabel_configs`:
```
Add metric_relabel_configs to the sample-app job to drop request_id and trace_id after scraping:
    metric_relabel_configs:
3. Use metric_relabel_configs to drop labels after scraping
```

- [ ] **Step 5: Commit**

```bash
git add labs/capstone/scenario-2-cardinality-explosion/solution.md
git commit -m "fix: correct relabel_configs to metric_relabel_configs in scenario-2 solution"
```

---

### Task 3: Fix scenario-3 localhost:9100 → node-exporter:9100

**Files:**
- Modify: `labs/capstone/scenario-3-partial-outage/solution.md`

Two locations. Lines 49, 53, and 128 use `localhost:9100` correctly (student's terminal and node-exporter's own healthcheck) — do NOT change those.

- [ ] **Step 1: Fix line 7 root cause description**

Find:
```
- Actual service is running on `localhost:9100`
```

Replace with:
```
- Actual service is running on `node-exporter:9100`
```

- [ ] **Step 2: Fix line 66 correct-fix YAML**

Find:
```yaml
    - targets: ['localhost:9100']  # CORRECT PORT
```

Replace with:
```yaml
    - targets: ['node-exporter:9100']  # CORRECT: service name + port
```

- [ ] **Step 3: Verify**

```bash
grep -n "localhost:9100" labs/capstone/scenario-3-partial-outage/solution.md
```

Expected: only lines 49, 53, 128 remain (student curl commands and healthcheck). Lines 7 and 66 must not appear.

```bash
grep "node-exporter:9100" labs/capstone/scenario-3-partial-outage/solution.md
```

Expected: two matches (lines 7 and 66).

- [ ] **Step 4: Commit**

```bash
git add labs/capstone/scenario-3-partial-outage/solution.md
git commit -m "fix: use node-exporter:9100 service name in scenario-3 correct-fix config"
```

---

### Task 4: Fix README.md stack comment and capstone-challenges.md file list

**Files:**
- Modify: `README.md`
- Modify: `docs/capstone/capstone-challenges.md`

- [ ] **Step 1: Fix README.md stack comment**

In `README.md`, find:
```
│   ├── docker-compose.yml        # Prometheus + Node Exporter
```

Replace with:
```
│   ├── docker-compose.yml        # Full observability stack (12 services)
```

- [ ] **Step 2: Verify README change**

```bash
grep "docker-compose.yml" README.md
```

Expected:
```
│   ├── docker-compose.yml        # Full observability stack (12 services)
```

- [ ] **Step 3: Fix capstone-challenges.md file list**

In `docs/capstone/capstone-challenges.md`, find this block:

```markdown
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
```

Replace with:

```markdown
Each scenario directory contains:
- `README.md` — scenario setup and guided questions
- `incident-data.json` — sample metrics data for the scenario
- `solution.md` — root cause analysis and recommended fix
- `broken-prometheus.yml` — the misconfigured file to debug

**Process:**
1. Read the scenario README
2. Review `incident-data.json` to understand the failure context
3. Answer the guided questions using PromQL
4. Compare your approach against `solution.md`
5. Implement the recommended config fixes
```

- [ ] **Step 4: Verify capstone-challenges.md change**

```bash
grep "incident-data/" docs/capstone/capstone-challenges.md
```
Expected: (empty — old directory reference gone)

```bash
grep "verify.sh" docs/capstone/capstone-challenges.md
```
Expected: (empty — nonexistent file reference gone)

```bash
grep "incident-data.json\|solution.md\|broken-prometheus.yml" docs/capstone/capstone-challenges.md
```
Expected: three matches (new accurate list)

- [ ] **Step 5: Commit**

```bash
git add README.md docs/capstone/capstone-challenges.md
git commit -m "fix: update stack comment in README and fix nonexistent file list in capstone-challenges"
```
