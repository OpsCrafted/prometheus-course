# Start Here

Opinionated path through the course. Follow this order. Skip nothing until you've finished the capstone.

**Total time:** ~36 hours across 3-4 weeks.

---

## Before you begin

Verify you have Docker and Docker Compose:

```bash
docker --version        # need v20.10+
docker compose version  # need v2.0+
```

If either fails, see [Getting Started](docs/getting-started/README.md) for install instructions.

---

## Step 1: Start the stack (do this once)

```bash
make setup
make verify
```

Expected from `make verify`: 12 containers up, 6 Prometheus targets all `UP`.

If `make verify` fails, stop here and fix it. Do not proceed to Day 1 with a broken stack. See [Getting Started](docs/getting-started/README.md) troubleshooting.

**Time: 15-30 minutes.**

---

## Step 2: Module 1 — Fundamentals (Days 1-4)

*Goal: understand how Prometheus works before you write a single query.*

| Do this | Then verify |
|---------|------------|
| Read [day-1-architecture.md](docs/module-1-fundamentals/day-1-architecture.md), complete [lab-1](labs/module-1-fundamentals/lab-1-scrape-config.md) | Exit Criteria checklist in lab passes |
| Read [day-2-metrics-model.md](docs/module-1-fundamentals/day-2-metrics-model.md), complete [lab-2](labs/module-1-fundamentals/lab-2-metric-types.md) | Exit Criteria checklist passes |
| Read [day-3-scraping-basics.md](docs/module-1-fundamentals/day-3-scraping-basics.md), complete [lab-3](labs/module-1-fundamentals/lab-3-scrape-targets.md) | Exit Criteria checklist passes |
| Read [day-4-review.md](docs/module-1-fundamentals/day-4-review.md), complete [lab-4](labs/module-1-fundamentals/lab-4-debug.md) | Exit Criteria checklist passes |

**Module 1 done when:** You can explain the pull model and configure a new scrape target from scratch.

**Time: 6-8 hours.**

---

## Step 3: Module 2 — Instrumentation (Days 5-8)

*Goal: add metrics to your own code.*

| Do this | Then verify |
|---------|------------|
| Read [day-5-go-instrumentation.md](docs/module-2-instrumentation/day-5-go-instrumentation.md), complete [lab-5](labs/module-2-instrumentation/lab-5-go-app.md) | `make verify-day-5` passes |
| Read [day-6-http-metrics.md](docs/module-2-instrumentation/day-6-http-metrics.md), complete [lab-6](labs/module-2-instrumentation/lab-6-middleware.md) | Exit Criteria checklist passes |
| Read [day-7-custom-metrics.md](docs/module-2-instrumentation/day-7-custom-metrics.md), complete [lab-7](labs/module-2-instrumentation/lab-7-gauges.md) | Exit Criteria checklist passes |
| Read [day-8-best-practices.md](docs/module-2-instrumentation/day-8-best-practices.md), complete [lab-8](labs/module-2-instrumentation/lab-8-review.md) | Exit Criteria checklist passes |

> **Python user?** Substitute [day-6-python-instrumentation.md](docs/module-2-instrumentation/day-6-python-instrumentation.md) for Day 6. Not both.

**Module 2 done when:** Custom metrics appear in Prometheus at `http://localhost:9090`.

**Time: 6-8 hours.**

---

## Step 4: Module 3 — PromQL (Days 9-19)

*Goal: write any query, build dashboards, alert correctly.*

| Do this | Then verify |
|---------|------------|
| Read [day-9](docs/module-3-promql/day-9-instant-range-vectors.md), complete [lab-9](labs/module-3-promql/lab-9-instant-queries.md) | `make verify-day-9` passes |
| Read [day-10](docs/module-3-promql/day-10-aggregation.md), complete [lab-10](labs/module-3-promql/lab-10-aggregation.md) | `make verify-day-10` passes |
| Read [day-11](docs/module-3-promql/day-11-rate-increase.md), complete [lab-11](labs/module-3-promql/lab-11-rate-increase.md) | Exit Criteria checklist passes |
| Read [day-12](docs/module-3-promql/day-12-joins.md), complete [lab-12](labs/module-3-promql/lab-12-joins.md) | `make verify-day-12` passes |
| Read [day-13](docs/module-3-promql/day-13-functions.md), complete [lab-13](labs/module-3-promql/lab-13-functions.md) | `make verify-day-13` passes |
| Read [day-14](docs/module-3-promql/day-14-histograms.md), complete [lab-14](labs/module-3-promql/lab-14-histograms.md) | Exit Criteria checklist passes |
| Read [day-15](docs/module-3-promql/day-15-slos-burn-rates.md), complete [lab-15](labs/module-3-promql/lab-15-slos-burn-rates.md) | `make verify-day-15` passes |
| Read [day-16](docs/module-3-promql/day-16-capstone.md), complete [lab-16](labs/module-3-promql/lab-16-capstone.md) | `make verify-day-16` passes |
| Read [day-17](docs/module-3-promql/day-17-production-readiness.md), complete [lab-17](labs/module-3-promql/lab-17-production-readiness.md) | `make verify-day-17` passes |
| Read [day-18](docs/module-3-promql/day-18-recording-rules.md), complete [lab-18](labs/module-3-promql/lab-18-recording-rules.md) | `make verify-day-18` passes |
| Read [day-19](docs/module-3-promql/day-19-alertmanager.md), complete [lab-19](labs/module-3-promql/lab-19-alertmanager.md) | `make verify-day-19` passes |

**Module 3 done when:** All `make verify-day-*` targets pass, production readiness checklist completed, and Alertmanager routing configured.

**Time: 16 hours.**

---

## Step 5: Capstone scenarios (optional, high value)

Three real-world debugging scenarios. Do these after Day 16 if you want production-grade troubleshooting practice:

- [Latency Spike](labs/capstone/scenario-1-latency-spike/) — diagnose and query a p99 latency regression
- [Cardinality Explosion](labs/capstone/scenario-2-cardinality-explosion/) — find and eliminate a high-cardinality label
- [Partial Outage](labs/capstone/scenario-3-partial-outage/) — debug a service degrading silently

---

## What to ignore (for now)

- `docs/reference/` — cheatsheets, useful after Day 9, not before
- `docs/capstone/` — supplementary scenarios, do after Day 16
- `docs/module-2-instrumentation/day-6-python-instrumentation.md` — only if you skipped Go Day 6
- `docs/06-pitfalls/` — read after you finish the course
- `docs/superpowers/` — internal course development docs, not student content

---

## What good looks like at each checkpoint

| After | You can... |
|-------|-----------|
| Setup | Run `make verify`, open http://localhost:9090, see 6 targets UP |
| Module 1 | Explain pull model, add a scrape target to `prometheus.yml`, debug a DOWN target |
| Module 2 | Write Go code that exports a counter, confirm it in Prometheus UI |
| Day 15 | Write a burn rate alert, explain why raw error rate is wrong |
| Day 17 | Wire 5 production alerts, complete the readiness checklist |
| Day 18 | Add recording rules, dashboard panels read pre-computed metrics |
| Day 19 | Configure Alertmanager routing — alerts go to the right people |
| Capstone | Diagnose all 3 incidents using only PromQL |

---

**Start:** [make setup, then Day 1](docs/getting-started/README.md)
