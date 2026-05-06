# 📊 Prometheus + PromQL Course

Master monitoring and observability in 2-3 weeks. Self-paced hands-on course for DevOps/SRE engineers.

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
- ✅ **~15 hours** over 2-3 weeks (5-7 hours/week)
- ✅ **Basic Linux/CLI** — Comfortable with terminal commands

**Not required:** Existing Prometheus knowledge. Kubernetes experience. Go expertise.

---

## ⏱️ Course Timeline

```
Week 1                          Week 2                      Week 3
├─ Getting Started (2-3h)       ├─ Days 5-8               ├─ Days 13-15
├─ Days 1-4 (6-8h)            │  Instrumentation        │  PromQL Capstone
│  Fundamentals               │  (6-8h)                │  (4-6h)
│                             │                         │
│ [████████████░░░]           │ [██████████░░░░░]       │ [████████░░░░░░]
└─ 2-3 days of study          └─ 2-3 days of study     └─ 1-2 days of study
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

### 🔍 **Module 3: PromQL** (Days 9-15)
*Master the query language. Build dashboards. Debug production.*

| Day | Topic | Duration | Learn |
|-----|-------|----------|-------|
| 9️⃣ | [Instant & Range Vectors](docs/module-3-promql/day-9-instant-range-vectors.md) | 90m | Query syntax, time ranges |
| 🔟 | [Aggregation](docs/module-3-promql/day-10-aggregation.md) | 90m | sum(), avg(), topk(), etc. |
| 1️⃣1️⃣ | [Rate & Increase](docs/module-3-promql/day-11-rate-increase.md) | 90m | Convert counters to rates |
| 1️⃣2️⃣ | [Joins & Matching](docs/module-3-promql/day-12-joins.md) | 90m | Multi-metric correlation |
| 1️⃣3️⃣ | [Functions](docs/module-3-promql/day-13-functions.md) | 90m | Mathematical operators |
| 1️⃣4️⃣ | [Histograms](docs/module-3-promql/day-14-histograms.md) | 90m | Percentiles, latency analysis |
| 1️⃣5️⃣ | [Capstone](docs/module-3-promql/day-15-capstone.md) | 4-6h | 3 real-world challenges |

**After Module 3:** You can write any PromQL query, build dashboards, and solve monitoring problems.

---

## 🚀 Quick Start (5 minutes)

```bash
# 1. Clone course
git clone https://github.com/OpsCrafted/prometheus-course.git
cd prometheus-course

# 2. Start Prometheus environment
make setup

# 3. Open course in browser (optional, or read offline)
# Read: docs/getting-started/README.md
```

**Already have Docker running?** You're ready. No other setup needed.

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

- [ ] **Week 3:** Complete Days 9-15 (PromQL + Capstone Scenarios)
  - Write 10+ different PromQL queries
  - Complete the 3 core capstone scenarios (Latency Spike, Cardinality Explosion, Partial Outage)
  - Build a custom dashboard from scratch

---

## 🛠️ Course Structure

```
prometheus-course/
├── docs/
│   ├── getting-started/          # Docker setup, first steps
│   ├── module-1-fundamentals/    # Days 1-4 guides
│   ├── module-2-instrumentation/ # Days 5-8 guides
│   ├── module-3-promql/          # Days 9-15 guides
│   ├── capstone/                 # Final challenges
│   └── reference/                # Cheatsheets, glossary
├── labs/
│   ├── docker-compose.yml        # Prometheus + Node Exporter
│   ├── prometheus-base.yml       # Scrape config
│   ├── module-1-fundamentals/    # Day 1-4 labs + solutions
│   ├── module-2-instrumentation/ # Day 5-8 labs + solutions
│   └── module-3-promql/          # Day 9-15 labs + solutions
└── Makefile                      # Setup, reset, cleanup

```

---

## 💡 Tips for Success

- **Don't skip Getting Started.** It builds your local environment. Takes 2-3 hours but saves 10+ hours of debugging later.
- **Type all commands yourself.** Copy-pasting skips learning. Type slowly, understand each step.
- **Labs are where learning happens.** Read the guide (30m), then struggle through the lab (60m). That struggle is the learning.
- **Revisit confusing days.** PromQL (Days 9-15) is hard. Come back to it after a break. It clicks suddenly.
- **Build something real.** After Day 8, instrument a real application. Use what you've learned.

---

## 🔗 Additional Resources

- [Prometheus Official Docs](https://prometheus.io/docs/introduction/overview/)
- [PromQL Reference](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/instrumentation/)

---

## 📞 Questions or Issues?

- **Course content:** Review the specific day's guide (likely answers your question)
- **Docker issues:** See Getting Started troubleshooting section
- **PromQL confusion:** Days 9-15 build on each other. Revisit earlier days if stuck
- **Contribution:** Found a typo or unclear section? Open an issue.

---

## 📊 What You'll Build

By the end:

- **Week 1:** A working Prometheus + Node Exporter environment, understanding of metrics
- **Week 2:** Instrumented Go application exporting custom metrics
- **Week 3:** Custom dashboard showing business + system metrics, 3 passing capstone challenges

You'll have hands-on experience with the monitoring stack used in production systems worldwide.

---

## 🎓 Full Learning Path

**Modules 1-3:** Core skills (fundamentals, instrumentation, PromQL)

**Bonus Content:**
- [Architecture Diagrams](docs/reference/architecture-diagrams.md) — Visual reference for pull model, alerting, service discovery
- [Python Instrumentation](docs/module-2-instrumentation/day-6-python-instrumentation.md) — Go + Python side-by-side
- [Golden Signals Lab](docs/capstone/golden-signals-lab/README.md) — Real SRE troubleshooting scenario
- [Module 6: Pitfalls & Anti-Patterns](docs/06-pitfalls/README.md) — Avoid production disasters

---

## ☕ Support This Course

Enjoying this course? Consider supporting future development and maintenance:

[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-ffdd00?logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/opscrafted)

Your support helps keep this course free and continuously updated.

---

**Ready?** [Start with Getting Started](docs/getting-started/README.md) → 2-3 hours, hands-on, no prerequisites beyond Docker.

Happy monitoring! 📈
