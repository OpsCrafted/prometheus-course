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
- **Examples:**
  - `labs/module-2-instrumentation/solutions/python-counter-example.py`
  - `labs/module-2-instrumentation/solutions/python-gauge-example.py`
  - `labs/module-2-instrumentation/solutions/python-histogram-example.py`

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
