# Curriculum Consolidation Design

**Date:** 2026-05-06  
**Scope:** Unify three competing navigation/index files into one canonical source of truth. Add lab directory indexes.

---

## Problem

Three files define the course structure and disagree on key facts:

| Fact | README.md | COURSE_INDEX.md | docs/MODULES.md |
|------|-----------|-----------------|-----------------|
| Day 6 | HTTP Metrics (Go) | HTTP Metrics (Go) | Python Instrumentation |
| Capstone count | "5 scenarios" | "3 challenge sets" | "Real Incident Scenarios" |
| Module 6 | Bonus | Not mentioned | Full module |
| Actual capstone files | — | — | 3 core + 5 bonus |

Students hitting any of these files get a different picture of the course. This makes it feel assembled, not designed.

---

## Solution

**One canonical navigation file. Two supporting files with clear, distinct roles.**

### File Roles (post-change)

| File | Role | Changes |
|------|------|---------|
| `README.md` | Marketing entry point. Course overview, quick start, learning outcomes. No structural index. | Fix capstone count claim only. |
| `COURSE_INDEX.md` | **Single canonical navigation.** Complete list of every file, every day, every lab. The source of truth for course structure. | Full rewrite. |
| `docs/MODULES.md` | **Deleted.** Content merged into COURSE_INDEX. | Delete file. |

---

## COURSE_INDEX.md Structure

Rewritten top-to-bottom. Seven sections:

### 1. Getting Started
- Links to `docs/getting-started/README.md`, `docker-setup.md`, `verify-setup.md`
- One-line description each

### 2. Module 1: Fundamentals (Days 1–4)
- Same content as current COURSE_INDEX (already correct)
- Each day: guide file, lab file, solution file, topics, time

### 3. Module 2: Instrumentation (Days 5–8)
- Day 5: Go Instrumentation (unchanged)
- **Day 6: Two tracks — pick one**
  - Track A (Go): `day-6-http-metrics.md` → `lab-6-middleware.md`
  - Track B (Python): `day-6-python-instrumentation.md` → Python examples
  - Note: "Both tracks cover HTTP metrics and middleware patterns. Choose the language you're building with."
- Day 7: Custom Metrics (unchanged)
- Day 8: Best Practices (unchanged)

### 4. Module 3: PromQL (Days 9–15)
- Same content as current COURSE_INDEX (already correct)

### 5. Capstone
Two tiers:

**Core (complete all three):**
1. Scenario 1: Latency Spike — `labs/capstone/scenario-1-latency-spike/`
2. Scenario 2: Cardinality Explosion — `labs/capstone/scenario-2-cardinality-explosion/`
3. Scenario 3: Partial Outage — `labs/capstone/scenario-3-partial-outage/`

**Extended (pick any):**
- Broken Lab: Configuration debugging — `labs/capstone/broken-lab/`
- Golden Signals Lab: SRE troubleshooting — `docs/capstone/golden-signals-lab/`
- Alert Fatigue: Alerting design — `labs/capstone/scenarios/alert-fatigue-incident/`
- Recording Rules: Performance optimization — `labs/capstone/scenarios/recording-rules-lab/`
- Grafana Transformations: Dashboard polish — `docs/capstone/grafana-transformations/`

### 6. Bonus: Module 6 — Pitfalls & Anti-Patterns *(optional)*
- Lesson 1: Cardinality Explosion — `docs/06-pitfalls/lesson-1-cardinality-explosion.md`
- Lesson 2: Alert Fatigue — `docs/06-pitfalls/lesson-2-alert-fatigue.md`
- Lesson 3: Recording Rules — `docs/06-pitfalls/lesson-3-recording-rules.md`

### 7. Reference Documentation
- Metric Types Guide
- PromQL Cheatsheet
- Glossary
- Setup Reference

---

## README.md Changes

Minimal. Only two changes:

1. Line 145: Change `"5 capstone scenarios"` to `"3 core capstone scenarios (+ extended bonus content)"`
2. Remove the duplicate file structure tree (it's maintained in COURSE_INDEX now) — or keep it but note "see COURSE_INDEX.md for the complete file map"

Do NOT change: quick start, learning outcomes, weekly timeline, tips, links.

---

## Lab Directory Indexes

Add `README.md` to three lab directories. Each is ~20 lines: module name, lab list with one-line description, link to solutions.

**`labs/module-1-fundamentals/README.md`**
- Lab 1: Scrape config (configure targets, reload)
- Lab 2: Metric types (identify and query all 4 types)
- Lab 3: Scrape targets (add targets, use relabeling)
- Lab 4: Debug (diagnose broken scrape configs)

**`labs/module-2-instrumentation/README.md`**
- Lab 5: Go app (instrument with client_golang)
- Lab 6: Middleware (HTTP metrics via middleware)
- Lab 7: Gauges (custom business metrics)
- Lab 8: Review (best practices audit)

**`labs/module-3-promql/README.md`**
- Lab 9: Instant queries (selectors, filters)
- Lab 10: Aggregation (sum, avg, topk)
- Lab 11: Rate & increase (counter functions)
- Lab 12: Binary operators (ratios, percentages)
- Lab 13: Functions (math, offset, derivatives)
- Lab 14: Histograms (quantiles, percentiles)
- Lab 15: Capstone (multi-step real-world queries)

---

## What Does NOT Change

- Content of any day guide or lab file
- Makefile, docker-compose, verify scripts
- docs/capstone/ content
- docs/reference/ content
- Any file paths (no renames)
