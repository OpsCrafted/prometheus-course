# Prometheus Course - Complete Module Index

## Module 1: Fundamentals (Days 1-4)

- [Day 1: Architecture](module-1-fundamentals/day-1-architecture.md)
- [Day 2: Metrics Model](module-1-fundamentals/day-2-metrics-model.md)
- [Day 3: Scraping Basics](module-1-fundamentals/day-3-scraping-basics.md)
- [Day 4: Review & Lab](module-1-fundamentals/day-4-review.md)

**Outcomes:** Understand pull model, deploy Prometheus, scrape targets

---

## Module 2: Instrumentation (Days 5-8)

- [Day 5: Go Instrumentation](module-2-instrumentation/day-5-go-instrumentation.md)
  - Examples: [Counter](../labs/module-2-instrumentation/solutions/go-counter-example.go), [Gauge](../labs/module-2-instrumentation/solutions/go-gauge-example.go), [Histogram](../labs/module-2-instrumentation/solutions/go-histogram-example.go)
- [Day 6: Python Instrumentation](module-2-instrumentation/day-6-python-instrumentation.md)
  - Examples: [Counter](../labs/module-2-instrumentation/solutions/python-counter-example.py), [Gauge](../labs/module-2-instrumentation/solutions/python-gauge-example.py), [Histogram](../labs/module-2-instrumentation/solutions/python-histogram-example.py)
- [Day 7: Custom Metrics](module-2-instrumentation/day-7-custom-metrics.md)
- [Day 8: Best Practices](module-2-instrumentation/day-8-best-practices.md)

**Outcomes:** Instrument apps, design metrics, export to Prometheus

---

## Module 3: PromQL (Days 9-15)

- [Day 9: Instant & Range Vectors](module-3-promql/day-9-instant-range-vectors.md)
- [Day 10: Aggregation](module-3-promql/day-10-aggregation.md)
- [Day 11: Rate & Increase](module-3-promql/day-11-rate-increase.md)
- [Day 12: Joins & Matching](module-3-promql/day-12-joins.md)
- [Day 13: Functions](module-3-promql/day-13-functions.md)
- [Day 14: Histograms](module-3-promql/day-14-histograms.md)
- [Day 15: Capstone](module-3-promql/day-15-capstone.md)

**Outcomes:** Master PromQL queries, build dashboards, debug production systems

---

## Bonus Content

### Architecture & Reference

- [Architecture Diagrams](reference/architecture-diagrams.md) — Pull model, alerting pipeline, service discovery, data flow
- [Glossary](reference/glossary.md)
- [PromQL Cheatsheet](reference/promql-cheatsheet.md)

### Capstone Scenarios

- [Golden Signals Lab](capstone/golden-signals-lab/) — Troubleshoot slow checkout service
- [Real Incident Scenarios](capstone/capstone-challenges.md) — Latency spike, cardinality explosion, partial outage

### Module 6: Pitfalls & Anti-Patterns

- [Lesson 1: Cardinality Explosion](06-pitfalls/lesson-1-cardinality-explosion.md)
- [Lesson 2: Alert Fatigue](06-pitfalls/lesson-2-alert-fatigue.md)
- [Lesson 3: Recording Rules](06-pitfalls/lesson-3-recording-rules.md)

**Outcomes:** Avoid production disasters, optimize dashboards, design effective alerting

---

## Getting Started

New to Prometheus? Start here: [Getting Started](getting-started/README.md)

Course takes 2-3 weeks. All content is self-paced.
