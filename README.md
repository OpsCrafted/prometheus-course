# 📊 Prometheus + PromQL Course

Master monitoring and observability in 3-4 weeks. Self-paced hands-on course for DevOps/SRE engineers.

> **New here? Start:** [START_HERE.md](START_HERE.md) — opinionated step-by-step path through the course.
> **Full course index:** [COURSE_INDEX.md](COURSE_INDEX.md)

---

## 🎯 Learning Outcomes

By the end of this course, you'll be able to:

- ✅ Deploy Prometheus from scratch and configure scrape targets
- ✅ Write complex PromQL queries (instant, range, aggregations, joins)
- ✅ Instrument Go applications with custom metrics
- ✅ Design effective monitoring strategies for production systems
- ✅ Build dashboards that answer real operational questions
- ✅ Debug production monitoring issues using real incident scenarios
- ✅ Diagnose and resolve monitoring problems in complex systems

---

## 📋 Prerequisites

Before starting, verify you have:

- ✅ **Docker** (v20.10+) — [Install](https://docs.docker.com/get-docker/)
- ✅ **Docker Compose** (v2.0+) — Usually included with Docker Desktop
- ✅ **Git** — For cloning the course
- ✅ **~36 hours** over 3-4 weeks (8-10 hours/week)
- ✅ **Basic Linux/CLI** — Comfortable with terminal commands

**Not required:** Existing Prometheus knowledge. Kubernetes experience. Go expertise.

---

## ⏱️ Course Timeline

```
Week 1                          Week 2                      Week 3-4
├─ Getting Started (2-3h)       ├─ Days 5-8               ├─ Days 9-19
├─ Days 1-4 (6-8h)            │  Instrumentation        │  PromQL + Production
│  Fundamentals               │  (6-8h)                │  (~16h)
│                             │                         │
│ [████████████░░░]           │ [██████████░░░░░]       │ [████████████░░░]
└─ 2-3 days of study          └─ 2-3 days of study     └─ 4-6 days of study
```

---

## 📚 Course Modules

### 🏗️ **Module 1: Fundamentals** (Days 1-4)
*Understand how Prometheus works under the hood*

| Day | Topic | Duration | Learn |
|-----|-------|----------|-------|
| 📖 | [Getting Started](docs/getting-started/README.md) | 2-3h | Docker setup, first queries |
| 1️⃣ | [Architecture](docs/module-1-fundamentals/day-1-architecture.md) | 90m | Pull model, TSDB, components |
| 2️⃣ | [Metrics Model](docs/module-1-fundamentals/day-2-metrics-model.md) | 90m | Counters, gauges, histograms |
| 3️⃣ | [Scraping Basics](docs/module-1-fundamentals/day-3-scraping-basics.md) | 90m | Targets, config, discovery |
| 4️⃣ | [Review & Lab](docs/module-1-fundamentals/day-4-review.md) | 90m | Hands-on scrape config |

**After Module 1:** You can deploy Prometheus, understand what metrics are, and configure basic scraping.

---

### 💻 **Module 2: Instrumentation** (Days 5-8)
*Add metrics to your own applications*

| Day | Topic | Duration | Learn |
|-----|-------|----------|-------|
| 5️⃣ | [Go Instrumentation](docs/module-2-instrumentation/day-5-go-instrumentation.md) | 90m | Client libraries, setup |
| 6️⃣ | [HTTP Metrics](docs/module-2-instrumentation/day-6-http-metrics.md) | 90m | Request latency, error rates |
| 7️⃣ | [Custom Metrics](docs/module-2-instrumentation/day-7-custom-metrics.md) | 90m | Business metrics, patterns |
| 8️⃣ | [Best Practices](docs/module-2-instrumentation/day-8-best-practices.md) | 90m | Naming, cardinality, alerting |

**After Module 2:** You can instrument applications and export metrics Prometheus understands.

---

### 🔍 **Module 3: PromQL** (Days 9-19)
*Master the query language. Build dashboards. Debug production.*

| Day | Topic | Duration | Learn |
|-----|-------|----------|-------|
| 9️⃣ | [Instant & Range Vectors](docs/module-3-promql/day-9-instant-range-vectors.md) | 90m | Query syntax, time ranges |
| 🔟 | [Aggregation](docs/module-3-promql/day-10-aggregation.md) | 90m | sum(), avg(), topk(), etc. |
| 1️⃣1️⃣ | [Rate & Increase](docs/module-3-promql/day-11-rate-increase.md) | 90m | Convert counters to rates |
| 1️⃣2️⃣ | [Joins & Matching](docs/module-3-promql/day-12-joins.md) | 90m | Multi-metric correlation |
| 1️⃣3️⃣ | [Functions](docs/module-3-promql/day-13-functions.md) | 90m | Mathematical operators |
| 1️⃣4️⃣ | [Histograms](docs/module-3-promql/day-14-histograms.md) | 90m | Percentiles, latency analysis |
| 1️⃣5️⃣ | [SLOs & Burn Rates](docs/module-3-promql/day-15-slos-burn-rates.md) | 90m | SLI, error budget, burn rate alerting |
| 1️⃣6️⃣ | [Capstone](docs/module-3-promql/day-16-capstone.md) | 2h | 5 PromQL challenges |
| 1️⃣7️⃣ | [Production Readiness](docs/module-3-promql/day-17-production-readiness.md) | 90m | 5 essential alerts, Golden Signals, checklist |
| 1️⃣8️⃣ | [Recording Rules](docs/module-3-promql/day-18-recording-rules.md) | 45m | Pre-aggregate expensive queries, faster dashboards |
| 1️⃣9️⃣ | [Alertmanager](docs/module-3-promql/day-19-alertmanager.md) | 60m | Routing, grouping, inhibition, silences |

**After Module 3:** You can write any PromQL query, build dashboards, alert correctly, and route notifications to the right people.

---

## 🛤️ Learning Tracks

Not everyone has 36 hours up front. Pick your track:

| Track | Time | What you get |
|-------|------|-------------|
| **Fast** (weekend) | 8–10h | Getting Started + Module 1 + Days 9–11. You can query real metrics and understand what you're reading. |
| **Standard** (3 weeks) | ~36h | Full core path, all 19 days + capstone. Production-ready skills. |
| **Deep** (4 weeks+) | ~50h+ | Standard path + all extended capstone scenarios + bonus content. Conference-talk level fluency. |

Already know Go? Skip or skim Days 5–8. Already have Prometheus in production? Start at Day 9.

---

## 🚀 Quick Start (5 minutes)

```bash
git clone https://github.com/OpsCrafted/prometheus-course.git
cd prometheus-course
make setup
make verify
```

Then open [START_HERE.md](START_HERE.md) for the step-by-step path.

---

## 📖 Daily Workflow

Each day follows the same pattern:

1. **Read** the day's guide: `docs/module-X/day-Y.md`
2. **Understand** the concepts and examples
3. **Lab:** Complete exercises in `labs/module-X/lab-Y.md`
4. **Verify:** Check your work against `labs/module-X/solutions/`
5. **Reflect:** What did you learn? What's still unclear?

**Estimated time per day:** 90 minutes (can be faster or slower based on experience)

---

## ✅ Success Checkpoints

Track your progress:

- [ ] **Week 1:** Complete Getting Started + Days 1-4 (Fundamentals)
  - Docker environment works
  - First PromQL queries execute
  - Understand Prometheus architecture

- [ ] **Week 2:** Complete Days 5-8 (Instrumentation)
  - Instrument a Go application
  - Custom metrics exported to Prometheus
  - Dashboard shows your metrics

- [ ] **Weeks 3-4:** Complete Days 9-19 (PromQL + Production Operations)
  - Write 10+ different PromQL queries
  - Complete the 3 core capstone scenarios (Latency Spike, Cardinality Explosion, Partial Outage)
  - Wire 5 production alerts, configure Alertmanager routing, complete production readiness checklist

---

## 🛠️ Course Structure

```
prometheus-course/
├── docs/
│   ├── getting-started/          # Docker setup, first steps
│   ├── module-1-fundamentals/    # Days 1-4 guides
│   ├── module-2-instrumentation/ # Days 5-8 guides
│   ├── module-3-promql/          # Days 9-19 guides
│   ├── capstone/                 # Final challenges
│   └── reference/                # Cheatsheets, glossary
├── labs/
│   ├── docker-compose.yml        # Full observability stack (12 services)
│   ├── prometheus.yml            # Scrape config (6 jobs)
│   ├── alert_rules.yml           # Alerting rules
│   ├── module-1-fundamentals/    # Day 1-4 labs + solutions
│   ├── module-2-instrumentation/ # Day 5-8 labs + solutions
│   └── module-3-promql/          # Day 9-19 labs + solutions
└── Makefile                      # Setup, reset, cleanup

```

---

## 💡 Tips for Success

- **Don't skip Getting Started.** It builds your local environment. Takes 2-3 hours but saves 10+ hours of debugging later.
- **Type all commands yourself.** Copy-pasting skips learning. Type slowly, understand each step.
- **Labs are where learning happens.** Read the guide (30m), then struggle through the lab (60m). That struggle is the learning.
- **Revisit confusing days.** PromQL (Days 9-19) is hard. Come back to it after a break. It clicks suddenly.
- **Build something real.** After Day 8, instrument a real application. Use what you've learned.

---

## 🔗 Additional Resources

- [Prometheus Official Docs](https://prometheus.io/docs/introduction/overview/)
- [PromQL Reference](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/instrumentation/)

---

## 🔧 Troubleshooting Quick Reference

**Setup failing?** → [Getting Started troubleshooting](docs/getting-started/README.md#troubleshooting) — covers port conflicts, container exits, permission errors.

**Targets showing DOWN?** → Wait 30 seconds and refresh. If still DOWN: `make logs-prometheus` and look for config errors.

**Query returns no data?** → Check that target is UP (`Status → Targets`). Try `up` first. If Prometheus just started, wait 60 seconds.

**PromQL confusing?** → Days 9-19 build on each other. If Day 12 doesn't make sense, reread Day 9. It clicks suddenly.

**Lab answer doesn't match solution?** → Numbers vary by system (CPU seconds, memory bytes). Focus on query structure, not exact values.

---

## 📞 Questions or Issues?

- **Course content:** Review the specific day's guide (likely answers your question)
- **Docker issues:** See [Getting Started troubleshooting](docs/getting-started/README.md#troubleshooting)
- **PromQL confusion:** Days 9-19 build on each other. Revisit earlier days if stuck
- **Contribution:** Found a typo or unclear section? Open an issue.

---

## 🎯 Job-Readiness Rubric

After completing this course, you should be able to pass a monitoring interview or take on-call ownership of a Prometheus stack. Here's what "ready" means at each level:

| Level | You can... |
|-------|-----------|
| **Week 1 complete** | Deploy Prometheus from scratch, explain the pull model, add a scrape target, debug a DOWN target |
| **Week 2 complete** | Write Go code that exports a counter/gauge/histogram, confirm metrics in Prometheus UI, explain cardinality risk |
| **Day 15 complete** | Write a burn rate alert, explain why raw error rate is insufficient for SLOs, calculate error budget |
| **Day 17 complete** | Wire 5 production alerts (error rate, latency p99, saturation, target down, job absent), complete readiness checklist |
| **Day 19 complete** | Configure Alertmanager routing tree — critical alerts page on-call, warnings go to Slack, inhibition prevents noise storms |
| **Capstone complete** | Diagnose a latency spike, a cardinality explosion, and a partial outage using only PromQL |

---

## 📊 What You'll Build

By the end:

- **Week 1:** A working full observability stack (12 services), understanding of metrics
- **Week 2:** Instrumented Go application exporting custom metrics
- **Weeks 3-4:** Custom dashboard, 3 passing capstone challenges, 5 wired production alerts, recording rules, Alertmanager routing configured

You'll have hands-on experience with the monitoring stack used in production systems worldwide.

---

## 🎓 Full Learning Path

**Modules 1-3:** Core skills (fundamentals, instrumentation, PromQL)

**Bonus Content:**
- [Architecture Diagrams](docs/reference/architecture-diagrams.md) — Visual reference for pull model, alerting, service discovery
- [Python Instrumentation](docs/module-2-instrumentation/day-6-python-instrumentation.md) — Go + Python side-by-side
- [Golden Signals Lab](docs/capstone/golden-signals-lab/README.md) — Real SRE troubleshooting scenario
- [Pitfalls & Anti-Patterns *(optional)*](docs/06-pitfalls/README.md) — Avoid production disasters

---

## ☕ Support This Course

Enjoying this course? Consider supporting future development and maintenance:

[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-ffdd00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/opscrafted)

Your support helps keep this course free and continuously updated.

---

**Ready?** [Start with Getting Started](docs/getting-started/README.md) → 2-3 hours, hands-on, no prerequisites beyond Docker.

Happy monitoring! 📈

---

*Course v1.0 — 19 days, 12-service lab stack, ~36 hours. Last updated May 2026.*
