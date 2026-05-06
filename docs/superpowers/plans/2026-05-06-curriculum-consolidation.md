# Curriculum Consolidation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify three competing navigation files into one canonical source of truth and add lab directory indexes.

**Architecture:** README.md stays thin (marketing). COURSE_INDEX.md becomes the single canonical navigation file — full rewrite. docs/MODULES.md is deleted. Three lab module directories get README.md index files.

**Tech Stack:** Markdown only. No code changes.

---

## File Map

| File | Action | Reason |
|------|--------|--------|
| `README.md` | Modify line 145 | Fix wrong capstone count ("5 scenarios" → actual) |
| `COURSE_INDEX.md` | Full rewrite | Canonical nav: Day 6 two-track, real capstone list, Module 6 as bonus |
| `docs/MODULES.md` | Delete | Replaced by COURSE_INDEX |
| `labs/module-1-fundamentals/README.md` | Create | Lab index for Module 1 |
| `labs/module-2-instrumentation/README.md` | Create | Lab index for Module 2 |
| `labs/module-3-promql/README.md` | Create | Lab index for Module 3 |

---

### Task 1: Fix README.md capstone count

**Files:**
- Modify: `README.md:145`

- [ ] **Step 1: Fix the capstone claim**

In `README.md`, replace line 145:
```
  - Solve all 5 capstone scenarios (Health Check, Request Analysis, SLA Monitoring, Capacity Planning, Multi-metric Correlation)
```
With:
```
  - Complete the 3 core capstone scenarios (Latency Spike, Cardinality Explosion, Partial Outage)
```

- [ ] **Step 2: Verify**

```bash
grep -n "capstone" README.md
```
Expected: line 145 now references "3 core capstone scenarios", no "5 capstone scenarios" anywhere.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "fix: correct capstone count in README (was 5, is 3 core)"
```

---

### Task 2: Delete docs/MODULES.md

**Files:**
- Delete: `docs/MODULES.md`

- [ ] **Step 1: Remove the file**

```bash
git rm docs/MODULES.md
```
Expected: `rm 'docs/MODULES.md'`

- [ ] **Step 2: Verify no dangling references**

```bash
grep -rn "MODULES.md" /Users/boris/opscrafted/prometheus-course --include="*.md" | grep -v ".git"
```
Expected: no output (no file references it).

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: delete docs/MODULES.md (superseded by COURSE_INDEX.md)"
```

---

### Task 3: Rewrite COURSE_INDEX.md

**Files:**
- Modify: `COURSE_INDEX.md` (full rewrite)

- [ ] **Step 1: Replace the entire file**

Write the following content to `COURSE_INDEX.md` (replace everything):

```markdown
# Prometheus Course — Complete Index

> **Navigation:** This is the single source of truth for course structure. Start with [Getting Started](docs/getting-started/README.md) if you're new.

---

## Getting Started

| File | Purpose |
|------|---------|
| [README](docs/getting-started/README.md) | Overview and first steps |
| [Docker Setup](docs/getting-started/docker-setup.md) | Install Docker, start the stack |
| [Verify Setup](docs/getting-started/verify-setup.md) | Confirm everything works |

```bash
make setup    # Start all services
make verify   # Confirm Prometheus, Grafana, sample-app are up
```

---

## Module 1: Fundamentals (Days 1–4)

*Understand how Prometheus works under the hood.*

### Day 1: Architecture
- **Guide:** `docs/module-1-fundamentals/day-1-architecture.md`
- **Lab:** `labs/module-1-fundamentals/lab-1-scrape-config.md`
- **Topics:** Pull-based model, TSDB, scraper, service discovery
- **Time:** 90 minutes

### Day 2: Metrics Model
- **Guide:** `docs/module-1-fundamentals/day-2-metrics-model.md`
- **Lab:** `labs/module-1-fundamentals/lab-2-metric-types.md`
- **Solution:** `labs/module-1-fundamentals/solutions/lab-2-solution.md`
- **Topics:** Gauge, Counter, Histogram, Summary; label naming
- **Time:** 90 minutes

### Day 3: Scraping Basics
- **Guide:** `docs/module-1-fundamentals/day-3-scraping-basics.md`
- **Lab:** `labs/module-1-fundamentals/lab-3-scrape-targets.md`
- **Solution:** `labs/module-1-fundamentals/solutions/lab-3-solution.yml`
- **Topics:** scrape_configs, targets, relabeling, metrics_path
- **Time:** 90 minutes

### Day 4: Fundamentals Review
- **Guide:** `docs/module-1-fundamentals/day-4-review.md`
- **Lab:** `labs/module-1-fundamentals/lab-4-debug.md`
- **Solution:** `labs/module-1-fundamentals/solutions/lab-4-solution.md`
- **Topics:** Integrate architecture + metrics + scraping; debug config
- **Time:** 90 minutes

**Total Module 1:** 6 hours

---

## Module 2: Instrumentation (Days 5–8)

*Add metrics to your own applications.*

### Day 5: Go Instrumentation
- **Guide:** `docs/module-2-instrumentation/day-5-go-instrumentation.md`
- **Lab:** `labs/module-2-instrumentation/lab-5-go-app.md`
- **Solution:** `labs/module-2-instrumentation/solutions/app-solution.go`
- **Topics:** prom/client_golang, counters, gauges, histograms, /metrics endpoint
- **Time:** 90 minutes

### Day 6: HTTP Metrics — Pick a track

Both tracks cover HTTP metrics and middleware patterns. Choose the language you're building with.

**Track A — Go:**
- **Guide:** `docs/module-2-instrumentation/day-6-http-metrics.md`
- **Lab:** `labs/module-2-instrumentation/lab-6-middleware.md`
- **Solution:** `labs/module-2-instrumentation/solutions/app-middleware-solution.go`

**Track B — Python:**
- **Guide:** `docs/module-2-instrumentation/day-6-python-instrumentation.md`
- **Examples:** `labs/module-2-instrumentation/solutions/python-counter-example.py`, `python-gauge-example.py`, `python-histogram-example.py`

**Time:** 90 minutes (either track)

### Day 7: Custom Metrics
- **Guide:** `docs/module-2-instrumentation/day-7-custom-metrics.md`
- **Lab:** `labs/module-2-instrumentation/lab-7-gauges.md`
- **Solution:** `labs/module-2-instrumentation/solutions/app-gauges-solution.go`
- **Topics:** Gauge creation, periodic updates, business metrics, active connections
- **Time:** 90 minutes

### Day 8: Best Practices
- **Guide:** `docs/module-2-instrumentation/day-8-best-practices.md`
- **Lab:** `labs/module-2-instrumentation/lab-8-review.md`
- **Solution:** `labs/module-2-instrumentation/solutions/app-best-practices-solution.go`
- **Topics:** Naming conventions, cardinality limits, anti-patterns, production readiness
- **Time:** 90 minutes

**Total Module 2:** 6 hours

---

## Module 3: PromQL (Days 9–15)

*Master the query language. Build dashboards. Debug production.*

### Day 9: Instant & Range Vectors
- **Guide:** `docs/module-3-promql/day-9-instant-range-vectors.md`
- **Lab:** `labs/module-3-promql/lab-9-instant-queries.md`
- **Solution:** `labs/module-3-promql/solutions/lab-9-solution.md`
- **Topics:** Instant vs range queries, time range syntax, metric selectors, label filters
- **Time:** 90 minutes

### Day 10: Aggregation Operators
- **Guide:** `docs/module-3-promql/day-10-aggregation.md`
- **Lab:** `labs/module-3-promql/lab-10-aggregation.md`
- **Solution:** `labs/module-3-promql/solutions/lab-10-solution.md`
- **Topics:** sum, avg, max, min, count; by and without clauses
- **Time:** 90 minutes

### Day 11: Rate & Increase
- **Guide:** `docs/module-3-promql/day-11-rate-increase.md`
- **Lab:** `labs/module-3-promql/lab-11-rate-increase.md`
- **Solution:** `labs/module-3-promql/solutions/lab-11-solution.md`
- **Topics:** rate() per-second, increase() totals, counter resets, window sizing
- **Time:** 90 minutes

### Day 12: Binary Operators & Ratios
- **Guide:** `docs/module-3-promql/day-12-joins.md`
- **Lab:** `labs/module-3-promql/lab-12-joins.md`
- **Solution:** `labs/module-3-promql/solutions/lab-12-solution.md`
- **Topics:** Binary operators (+, -, *, /), sum()-before-divide pattern, ratios, percentages
- **Time:** 90 minutes

### Day 13: Functions & Transformations
- **Guide:** `docs/module-3-promql/day-13-functions.md`
- **Lab:** `labs/module-3-promql/lab-13-functions.md`
- **Solution:** `labs/module-3-promql/solutions/lab-13-solution.md`
- **Topics:** round, ceil, floor, log, abs, offset, changes, derivatives
- **Time:** 90 minutes

### Day 14: Histograms & Quantiles
- **Guide:** `docs/module-3-promql/day-14-histograms.md`
- **Lab:** `labs/module-3-promql/lab-14-histograms.md`
- **Solution:** `labs/module-3-promql/solutions/lab-14-solution.md`
- **Topics:** Histogram buckets, histogram_quantile(), percentiles, p50/p95/p99
- **Time:** 90 minutes

### Day 15: PromQL Capstone
- **Guide:** `docs/module-3-promql/day-15-capstone.md`
- **Lab:** `labs/module-3-promql/lab-15-capstone.md`
- **Solution:** `labs/module-3-promql/solutions/lab-15-solution.md`
- **Topics:** Multi-step queries, health checks, SLA monitoring, capacity planning
- **Time:** 90 minutes

**Total Module 3:** 10.5 hours

---

## Capstone

*Apply everything to real-world incident scenarios.*

### Core Scenarios (complete all three)

| Scenario | Path | Topic |
|----------|------|-------|
| 1. Latency Spike | `labs/capstone/scenario-1-latency-spike/` | Diagnose p95 latency spike with histogram_quantile() |
| 2. Cardinality Explosion | `labs/capstone/scenario-2-cardinality-explosion/` | Identify and fix unbounded label cardinality |
| 3. Partial Outage | `labs/capstone/scenario-3-partial-outage/` | Diagnose scrape failures, use relabeling to fix |

**Estimated time:** 3–4 hours

### Extended Scenarios (pick any)

| Lab | Path | Topic |
|-----|------|-------|
| Broken Lab | `labs/capstone/broken-lab/` | Debug 5 broken scrape configurations |
| Golden Signals | `docs/capstone/golden-signals-lab/` | SRE troubleshooting with the 4 golden signals |
| Alert Fatigue | `labs/capstone/scenarios/alert-fatigue-incident/` | Design effective alerting, reduce noise |
| Recording Rules | `labs/capstone/scenarios/recording-rules-lab/` | Pre-compute expensive queries |
| Grafana Transformations | `docs/capstone/grafana-transformations/` | Advanced dashboard panels |

---

## Bonus: Pitfalls & Anti-Patterns *(optional)*

*Common production mistakes and how to avoid them.*

- [Lesson 1: Cardinality Explosion](docs/06-pitfalls/lesson-1-cardinality-explosion.md)
- [Lesson 2: Alert Fatigue](docs/06-pitfalls/lesson-2-alert-fatigue.md)
- [Lesson 3: Recording Rules](docs/06-pitfalls/lesson-3-recording-rules.md)

---

## Reference Documentation

| File | Contents |
|------|---------|
| `docs/reference/metric-types-guide.md` | Gauge, Counter, Histogram, Summary — use cases, queries, naming |
| `docs/reference/promql-cheatsheet.md` | Quick reference for all PromQL operators and functions |
| `docs/reference/glossary.md` | 50+ terms defined |
| `docs/reference/setup-reference.md` | prometheus.yml options, Docker Compose setup, reload |

---

## Course Statistics

| Component | Count |
|-----------|-------|
| Day guides | 15 |
| Labs | 15 |
| Solutions | 15 |
| Core capstone scenarios | 3 |
| Extended capstone labs | 5 |
| Reference docs | 4 |

| Module | Time |
|--------|------|
| Getting Started | 2–3 hours |
| Module 1: Fundamentals | 6 hours |
| Module 2: Instrumentation | 6 hours |
| Module 3: PromQL | 10.5 hours |
| Core Capstone | 3–4 hours |
| **Total (core path)** | **~28 hours** |
```

- [ ] **Step 2: Verify all referenced paths exist**

```bash
for f in \
  "docs/getting-started/README.md" \
  "docs/getting-started/docker-setup.md" \
  "docs/getting-started/verify-setup.md" \
  "docs/module-1-fundamentals/day-1-architecture.md" \
  "docs/module-2-instrumentation/day-6-http-metrics.md" \
  "docs/module-2-instrumentation/day-6-python-instrumentation.md" \
  "labs/module-2-instrumentation/solutions/python-counter-example.py" \
  "labs/capstone/scenario-1-latency-spike/README.md" \
  "labs/capstone/scenario-2-cardinality-explosion/README.md" \
  "labs/capstone/scenario-3-partial-outage/README.md" \
  "labs/capstone/broken-lab" \
  "docs/capstone/golden-signals-lab/README.md" \
  "labs/capstone/scenarios/alert-fatigue-incident/README.md" \
  "labs/capstone/scenarios/recording-rules-lab/README.md" \
  "docs/capstone/grafana-transformations/README.md" \
  "docs/06-pitfalls/lesson-1-cardinality-explosion.md" \
  "docs/reference/metric-types-guide.md"; do
  [ -e "/Users/boris/opscrafted/prometheus-course/$f" ] && echo "✓ $f" || echo "✗ MISSING: $f"
done
```
Expected: all lines start with ✓

- [ ] **Step 3: Confirm MODULES.md no longer exists**

```bash
ls /Users/boris/opscrafted/prometheus-course/docs/MODULES.md 2>&1
```
Expected: `No such file or directory`

- [ ] **Step 4: Commit**

```bash
git add COURSE_INDEX.md
git commit -m "feat: rewrite COURSE_INDEX.md as single canonical navigation"
```

---

### Task 4: Add labs/module-1-fundamentals/README.md

**Files:**
- Create: `labs/module-1-fundamentals/README.md`

- [ ] **Step 1: Create the file**

Write the following to `labs/module-1-fundamentals/README.md`:

```markdown
# Module 1: Fundamentals — Labs

Labs for Days 1–4. Complete each after reading the corresponding day guide in `docs/module-1-fundamentals/`.

| Lab | File | What you build |
|-----|------|----------------|
| Lab 1 | [lab-1-scrape-config.md](lab-1-scrape-config.md) | Configure Prometheus scrape targets, add a target, reload config |
| Lab 2 | [lab-2-metric-types.md](lab-2-metric-types.md) | Query all 4 metric types; understand counter vs gauge behavior |
| Lab 3 | [lab-3-scrape-targets.md](lab-3-scrape-targets.md) | Add multiple targets, use relabeling to filter and rename labels |
| Lab 4 | [lab-4-debug.md](lab-4-debug.md) | Diagnose and fix broken scrape configurations |

Solutions: [solutions/](solutions/)

Stack running? Check with `make verify`.
```

- [ ] **Step 2: Verify links resolve**

```bash
for f in \
  "labs/module-1-fundamentals/lab-1-scrape-config.md" \
  "labs/module-1-fundamentals/lab-2-metric-types.md" \
  "labs/module-1-fundamentals/lab-3-scrape-targets.md" \
  "labs/module-1-fundamentals/lab-4-debug.md" \
  "labs/module-1-fundamentals/solutions"; do
  [ -e "/Users/boris/opscrafted/prometheus-course/$f" ] && echo "✓ $f" || echo "✗ MISSING: $f"
done
```
Expected: all ✓

- [ ] **Step 3: Commit**

```bash
git add labs/module-1-fundamentals/README.md
git commit -m "docs: add lab index for module-1-fundamentals"
```

---

### Task 5: Add labs/module-2-instrumentation/README.md

**Files:**
- Create: `labs/module-2-instrumentation/README.md`

- [ ] **Step 1: Create the file**

Write the following to `labs/module-2-instrumentation/README.md`:

```markdown
# Module 2: Instrumentation — Labs

Labs for Days 5–8. Requires the sample-app running (`make setup`).

| Lab | File | What you build |
|-----|------|----------------|
| Lab 5 | [lab-5-go-app.md](lab-5-go-app.md) | Instrument a Go app with counters, gauges, histograms |
| Lab 6 | [lab-6-middleware.md](lab-6-middleware.md) | HTTP middleware tracking request duration and status codes |
| Lab 7 | [lab-7-gauges.md](lab-7-gauges.md) | Custom business metrics: active connections, queue depth |
| Lab 8 | [lab-8-review.md](lab-8-review.md) | Audit instrumentation for naming, cardinality, best practices |

Solutions: [solutions/](solutions/)

Day 6 has two tracks — Go (`lab-6-middleware.md`) or Python (`solutions/python-*.py`). Pick one.
```

- [ ] **Step 2: Verify links resolve**

```bash
for f in \
  "labs/module-2-instrumentation/lab-5-go-app.md" \
  "labs/module-2-instrumentation/lab-6-middleware.md" \
  "labs/module-2-instrumentation/lab-7-gauges.md" \
  "labs/module-2-instrumentation/lab-8-review.md" \
  "labs/module-2-instrumentation/solutions"; do
  [ -e "/Users/boris/opscrafted/prometheus-course/$f" ] && echo "✓ $f" || echo "✗ MISSING: $f"
done
```
Expected: all ✓

- [ ] **Step 3: Commit**

```bash
git add labs/module-2-instrumentation/README.md
git commit -m "docs: add lab index for module-2-instrumentation"
```

---

### Task 6: Add labs/module-3-promql/README.md

**Files:**
- Create: `labs/module-3-promql/README.md`

- [ ] **Step 1: Create the file**

Write the following to `labs/module-3-promql/README.md`:

```markdown
# Module 3: PromQL — Labs

Labs for Days 9–15. Run queries at http://localhost:9090.

| Lab | File | What you build |
|-----|------|----------------|
| Lab 9 | [lab-9-instant-queries.md](lab-9-instant-queries.md) | Instant and range vector queries, label selectors, time ranges |
| Lab 10 | [lab-10-aggregation.md](lab-10-aggregation.md) | sum(), avg(), topk(), count() with by/without clauses |
| Lab 11 | [lab-11-rate-increase.md](lab-11-rate-increase.md) | rate() and increase() on counters, choosing window sizes |
| Lab 12 | [lab-12-joins.md](lab-12-joins.md) | Binary operators, sum()-before-divide pattern, ratios and percentages |
| Lab 13 | [lab-13-functions.md](lab-13-functions.md) | Mathematical functions, offset, derivatives |
| Lab 14 | [lab-14-histograms.md](lab-14-histograms.md) | histogram_quantile(), p50/p95/p99 latency analysis |
| Lab 15 | [lab-15-capstone.md](lab-15-capstone.md) | Multi-step real-world queries: SLA monitoring, capacity planning |

Solutions: [solutions/](solutions/)

Verify Prometheus is running: `curl -s http://localhost:9090/api/v1/query?query=up | jq '.status'`
```

- [ ] **Step 2: Verify links resolve**

```bash
for f in \
  "labs/module-3-promql/lab-9-instant-queries.md" \
  "labs/module-3-promql/lab-10-aggregation.md" \
  "labs/module-3-promql/lab-11-rate-increase.md" \
  "labs/module-3-promql/lab-12-joins.md" \
  "labs/module-3-promql/lab-13-functions.md" \
  "labs/module-3-promql/lab-14-histograms.md" \
  "labs/module-3-promql/lab-15-capstone.md" \
  "labs/module-3-promql/solutions"; do
  [ -e "/Users/boris/opscrafted/prometheus-course/$f" ] && echo "✓ $f" || echo "✗ MISSING: $f"
done
```
Expected: all ✓

- [ ] **Step 3: Commit**

```bash
git add labs/module-3-promql/README.md
git commit -m "docs: add lab index for module-3-promql"
```
