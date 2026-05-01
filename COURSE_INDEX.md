# Prometheus Course Implementation - Complete Index

## Module 1: Fundamentals (Days 1-4)

### Day 1: Architecture
- **File:** `docs/module-1-fundamentals/day-1-architecture.md`
- **Lab:** `labs/module-1-fundamentals/lab-1-scrape-config.md`
- **Topics:** Pull-based model, TSDB, scraper, service discovery
- **Time:** 90 minutes

### Day 2: Metrics Model
- **File:** `docs/module-1-fundamentals/day-2-metrics-model.md`
- **Lab:** `labs/module-1-fundamentals/lab-2-metric-types.md`
- **Solution:** `labs/module-1-fundamentals/solutions/lab-2-solution.md`
- **Topics:** Gauge, Counter, Histogram, Summary types; Label naming
- **Time:** 90 minutes

### Day 3: Scraping Basics
- **File:** `docs/module-1-fundamentals/day-3-scraping-basics.md`
- **Lab:** `labs/module-1-fundamentals/lab-3-scrape-targets.md`
- **Solution:** `labs/module-1-fundamentals/solutions/lab-3-solution.yml`
- **Topics:** scrape_configs, targets, relabeling, metrics_path
- **Time:** 90 minutes

### Day 4: Fundamentals Review
- **File:** `docs/module-1-fundamentals/day-4-review.md`
- **Lab:** `labs/module-1-fundamentals/lab-4-debug.md`
- **Solution:** `labs/module-1-fundamentals/solutions/lab-4-solution.md`
- **Topics:** Integrate architecture + metrics + scraping; Debug config
- **Time:** 90 minutes

**Total Module 1:** 360 minutes (6 hours)

---

## Module 2: Instrumentation (Days 5-8)

### Day 5: Go Instrumentation Basics
- **File:** `docs/module-2-instrumentation/day-5-go-instrumentation.md`
- **Lab:** `labs/module-2-instrumentation/lab-5-go-app.md`
- **Solution:** `labs/module-2-instrumentation/solutions/app-solution.go`
- **Topics:** prom/client_golang, counters, gauges, histograms, /metrics endpoint
- **Time:** 90 minutes

### Day 6: HTTP Metrics & Middleware
- **File:** `docs/module-2-instrumentation/day-6-http-metrics.md`
- **Lab:** `labs/module-2-instrumentation/lab-6-middleware.md`
- **Solution:** `labs/module-2-instrumentation/solutions/app-middleware-solution.go`
- **Topics:** Middleware pattern, response status, request duration, label cardinality
- **Time:** 90 minutes

### Day 7: Custom Metrics & Gauges
- **File:** `docs/module-2-instrumentation/day-7-custom-metrics.md`
- **Lab:** `labs/module-2-instrumentation/lab-7-gauges.md`
- **Solution:** `labs/module-2-instrumentation/solutions/app-gauges-solution.go`
- **Topics:** Gauge creation, periodic updates, business metrics, active connections
- **Time:** 90 minutes

### Day 8: Instrumentation Best Practices
- **File:** `docs/module-2-instrumentation/day-8-best-practices.md`
- **Lab:** `labs/module-2-instrumentation/lab-8-review.md`
- **Solution:** `labs/module-2-instrumentation/solutions/app-best-practices-solution.go`
- **Topics:** Naming conventions, cardinality limits, anti-patterns, production readiness
- **Time:** 90 minutes

**Total Module 2:** 360 minutes (6 hours)

---

## Module 3: PromQL (Days 9-15)

### Day 9: Instant & Range Vectors
- **File:** `docs/module-3-promql/day-9-instant-range-vectors.md`
- **Lab:** `labs/module-3-promql/lab-9-instant-queries.md`
- **Solution:** `labs/module-3-promql/solutions/lab-9-solution.md`
- **Topics:** Instant vs range queries, time range syntax, metric selectors, label filters
- **Time:** 90 minutes

### Day 10: Aggregation Operators
- **File:** `docs/module-3-promql/day-10-aggregation.md`
- **Lab:** `labs/module-3-promql/lab-10-aggregation.md`
- **Solution:** `labs/module-3-promql/solutions/lab-10-solution.md`
- **Topics:** sum, avg, max, min, count; by and without clauses
- **Time:** 90 minutes

### Day 11: Rate & Increase
- **File:** `docs/module-3-promql/day-11-rate-increase.md`
- **Lab:** `labs/module-3-promql/lab-11-rate-increase.md`
- **Solution:** `labs/module-3-promql/solutions/lab-11-solution.md`
- **Topics:** rate() per-second, increase() totals, counter resets, window sizing
- **Time:** 90 minutes

### Day 12: Joins & Binary Operators
- **File:** `docs/module-3-promql/day-12-joins.md`
- **Lab:** `labs/module-3-promql/lab-12-joins.md`
- **Solution:** `labs/module-3-promql/solutions/lab-12-solution.md`
- **Topics:** Binary operators (+, -, *, /), label matching, ratios, percentages
- **Time:** 90 minutes

### Day 13: Functions & Transformations
- **File:** `docs/module-3-promql/day-13-functions.md`
- **Lab:** `labs/module-3-promql/lab-13-functions.md`
- **Solution:** `labs/module-3-promql/solutions/lab-13-solution.md`
- **Topics:** round, ceil, floor, log, abs, offset, changes, derivatives
- **Time:** 90 minutes

### Day 14: Histograms & Quantiles
- **File:** `docs/module-3-promql/day-14-histograms.md`
- **Lab:** `labs/module-3-promql/lab-14-histograms.md`
- **Solution:** `labs/module-3-promql/solutions/lab-14-solution.md`
- **Topics:** Histogram buckets, histogram_quantile(), percentiles, p50/p95/p99
- **Time:** 90 minutes

### Day 15: PromQL Capstone
- **File:** `docs/module-3-promql/day-15-capstone.md`
- **Lab:** `labs/module-3-promql/lab-15-capstone.md`
- **Solution:** `labs/module-3-promql/solutions/lab-15-solution.md`
- **Topics:** Multi-step queries, health checks, SLA monitoring, capacity planning
- **Time:** 90 minutes

**Total Module 3:** 630 minutes (10.5 hours)

---

## Task 20: Capstone Challenges

**Files:**
- `docs/capstone/capstone-challenges.md` — Challenge descriptions
- `docs/capstone/capstone-solutions.md` — Example solutions

**Content:**
- Challenge Set 1: Complete System Setup (3 services, 9 metrics, 5 queries)
- Challenge Set 2: Dashboard & Alerts (5 panels, 4 alert rules)
- Challenge Set 3: Troubleshooting (Root cause analysis, metric correlation)

**Time:** 180-240 minutes (3-4 hours)

---

## Task 21: Reference Documentation

**Metric Types Guide** (`docs/reference/metric-types-guide.md`)
- Gauge, Counter, Histogram, Summary types
- Use cases and characteristics
- Operations and queries
- Naming conventions
- Label cardinality guidance

**PromQL Cheatsheet** (`docs/reference/promql-cheatsheet.md`)
- Instant and range vectors
- Aggregation operators
- Rate and increase
- Binary operators
- Functions
- Complex query patterns
- Best practices

**Glossary** (`docs/reference/glossary.md`)
- 50+ terms with definitions
- Alert Rule, Bucket, Cardinality, Counter, Gauge, Histogram, Instance, Job, Label, Metric, Quantile, Rate, Series, Summary, Target, TSDB, Vector, etc.

**Setup & Configuration Reference** (`docs/reference/setup-reference.md`)
- prometheus.yml structure and options
- Common configuration patterns
- Docker Compose setup
- Reloading configuration
- File locations
- Retention policies

---

## Course Statistics

| Component | Count |
|-----------|-------|
| Day guides | 15 |
| Labs | 15 |
| Solutions | 15 |
| Capstone challenges | 3 |
| Reference docs | 4 |
| **Total markdown files** | **52** |

| Module | Time | Topics |
|--------|------|--------|
| Fundamentals | 360 min | Architecture, Metrics Model, Scraping, Review |
| Instrumentation | 360 min | Go Client, HTTP Middleware, Gauges, Best Practices |
| PromQL | 630 min | Vectors, Aggregation, Rate, Joins, Functions, Histograms, Capstone |
| Capstone | 180-240 min | System Setup, Dashboards/Alerts, Troubleshooting |
| **Total** | **1530-1590 min** | **38-40 hours** |

---

## How to Use This Course

### Sequential Path (Recommended)
1. Start with Module 1 Day 1 — Read day-1-architecture.md
2. Complete lab-1-scrape-config.md (30 min)
3. Move to Day 2 — Read day-2-metrics-model.md
4. Continue sequentially through Day 4 (Fundamentals Review)
5. Move to Module 2 Days 5-8 (Instrumentation)
6. Move to Module 3 Days 9-15 (PromQL)
7. Complete Capstone Challenges
8. Reference documentation as needed

### Self-Paced Path
- Pick any module to start (though Module 1 recommended first)
- Complete labs immediately after reading
- Check solutions only after attempting
- Use reference docs while working on queries

### Prerequisites
- Basic command line (bash)
- Go programming (for instrumentation module)
- Docker (optional, for setup)
- Prometheus running locally

---

## File Structure

```
prometheus-course/
├── docs/
│   ├── getting-started/           # Setup guides
│   ├── module-1-fundamentals/     # Days 1-4
│   ├── module-2-instrumentation/  # Days 5-8
│   ├── module-3-promql/           # Days 9-15
│   ├── capstone/                  # Challenges & solutions
│   └── reference/                 # Guides & cheatsheets
├── labs/
│   ├── module-1-fundamentals/     # Labs 1-4
│   │   └── solutions/
│   ├── module-2-instrumentation/  # Labs 5-8
│   │   └── solutions/
│   ├── module-3-promql/           # Labs 9-15
│   │   └── solutions/
│   └── capstone/                  # Challenge implementations
├── COURSE_INDEX.md                # This file
└── README.md                      # Overview
```

---

## Key Learning Outcomes

By completing this course, you will:

**Fundamentals:**
- Understand Prometheus pull-based architecture
- Know 4 metric types and when to use each
- Configure scrape targets and reload configuration
- Diagnose monitoring setup issues

**Instrumentation:**
- Instrument Go apps with prometheus/client_golang
- Create counters, gauges, histograms
- Build HTTP middleware for metrics
- Follow metric naming conventions and avoid cardinality issues

**PromQL:**
- Query instant and range vectors
- Aggregate metrics (sum, avg, count, etc.)
- Calculate rates and percentiles
- Join metrics and create ratios
- Write complex multi-step queries

**Capstone:**
- Design complete monitoring system for 3-tier app
- Build dashboards and alert rules
- Troubleshoot production monitoring issues
- Correlate metrics to find root causes

---

## Next Steps After Course

- Deploy monitoring to production
- Build dashboards in Grafana
- Create runbooks for alerts
- Establish SLOs based on metrics
- Set up on-call rotation
- Learn advanced topics:
  - Service discovery (Kubernetes, Consul)
  - Alertmanager (routing, grouping)
  - Recording rules (performance optimization)
  - Remote storage (long-term retention)
