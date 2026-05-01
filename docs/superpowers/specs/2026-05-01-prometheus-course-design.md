# Prometheus + PromQL + OpenTelemetry Course Design

**Date:** 2026-05-01  
**Audience:** DevOps/SRE engineers  
**Duration:** 2-3 weeks (15 days + Getting Started)  
**Delivery:** Written guides + interactive labs  
**Prerequisites:** Infrastructure baseline (Linux, Kubernetes familiarity); no observability experience required

---

## Overview

Comprehensive course teaching Prometheus fundamentals, instrumentation, and PromQL through theory + hands-on labs. Students will run Prometheus locally (Docker), instrument sample applications, and write production-grade PromQL queries. No videos or slides—pure written guides + interactive labs.

**Must-have outcomes:**
- Understand Prometheus architecture and metrics model
- Instrument applications with Prometheus client libraries
- Write and optimize PromQL queries

**Nice-to-have additions** (out of scope for core course):
- Scraping at scale, alerting rules, OpenTelemetry integration, federation, troubleshooting

---

## Course Structure

### Getting Started (Pre-Day 1, ~2-3 hours)

**Purpose:** Set hands-on context before diving into theory. Students get Prometheus running and write their first queries.

**Content:**
- Docker Compose one-liner: spin up Prometheus + Node Exporter + sample metrics endpoint
- First PromQL queries: 5 basic queries (count metrics, explore time-series in UI)
- Verification: `curl localhost:9090/api/v1/query` returns data

**Exit criteria:** Running Prometheus instance, student can write basic selectors.

---

### Module 1: Fundamentals (Days 1-4)

**Day 1: Prometheus Architecture**
- Conceptual explainer: pull model, scrapers, time-series DB, components (Prometheus server, TSDB, scraper)
- Diagrams: architecture diagram, pull vs push comparison
- Lab: explore Prometheus UI, understand targets, scrape config structure
- Glossary sidebar: time-series, cardinality, scrape interval

**Day 2: Metrics Model**
- Conceptual explainer: gauge, counter, histogram, summary with real-world examples
- Diagrams: metric type decision tree
- Lab: identify metric types in running Prometheus instance, add labels correctly
- Reference: metric types cheatsheet, label best practices

**Day 3: Scraping Basics**
- Conceptual explainer: scrape configs, relabeling, service discovery intro
- Code examples: sample prometheus.yml, relabel_configs examples
- Lab: add new scrape target (Node Exporter), verify metrics appear, fix broken config
- Reference: relabel_configs syntax reference

**Day 4: Fundamentals Review & Checkpoint**
- Recap: architecture + metrics + scraping in action
- Lab: debug broken scrape config, fix + verify end-to-end
- Exit criteria: student can diagnose why metrics don't appear

---

### Module 2: Instrumentation (Days 5-8)

**Day 5: Client Libraries**
- Conceptual explainer: Prometheus client libraries (Go, Python, Node.js), push vs pull, when to use each
- Code examples: minimal instrumentation in 3 languages
- Lab: instrument sample Go app with prom client (counter + gauge)
- Reference: client library comparison table

**Day 6: Custom Metrics**
- Conceptual explainer: designing metrics (naming, labels, cardinality warnings)
- Code examples: creating counters, gauges, histograms in Go
- Lab: add 5 custom metrics to sample app, test under load
- Glossary: cardinality, label explosion, dimensionality

**Day 7: Instrumentation Best Practices**
- Conceptual explainer: naming conventions (prometheus_* prefix), label design (avoid high-cardinality), anti-patterns
- Code examples: good vs bad metric names, good vs bad label designs
- Lab: refactor previous metrics to follow best practices
- Reference: metric naming guidelines, label cardinality limits

**Day 8: Instrumentation Capstone Lab**
- Build exporter for a simple service (e.g., HTTP API scraper, log metrics exporter)
- Exit criteria: exporter exposes valid metrics, Prometheus scrapes successfully

---

### Module 3: PromQL Deep-Dive (Days 9-15)

**Day 9: PromQL Basics**
- Conceptual explainer: instant queries vs range queries, selectors, filters, label matching
- Diagrams: PromQL query execution flow
- Lab: write 10 queries using different selectors (=, !=, =~, !~)
- Reference: PromQL syntax cheatsheet

**Day 10: Aggregation Operators**
- Conceptual explainer: sum, avg, min, max, topk, bottomk, group_concat
- Code examples: aggregation patterns, filtering after aggregation
- Lab: find top 5 memory consumers, avg CPU across instances, filter by labels
- Reference: aggregation operator reference

**Day 11: Rate Functions**
- Conceptual explainer: rate(), increase(), derivative(), why they matter (counters only)
- Diagrams: rate calculation over time
- Lab: calculate request rates, identify traffic spikes, compute derivatives
- Common mistakes: applying rate to gauges, off-by-one errors

**Day 12: Advanced PromQL Patterns**
- Conceptual explainer: joins, subqueries, scalar operations, vector matching
- Code examples: complex queries (e.g., per-instance request rates vs avg)
- Lab: correlate metrics across instances, multi-step queries
- Reference: vector matching syntax, join operators

**Days 13-14: Real-World Query Labs**
- Focus: queries you'd use in production dashboards (SLO queries, debugging, alerting context)
- Lab 1: write SLO compliance queries (success rate, latency p95)
- Lab 2: write debugging queries (find error spikes, correlate with resource usage)
- Lab 3: write alert trigger queries (threshold + duration patterns)

**Day 15: PromQL Capstone + Capstone Challenges**
- Mini-lab: comprehensive PromQL challenge (20+ queries on sample dataset)
- Transition: start capstone challenges (see below)

---

## Capstone Challenges (Days 13-15, ongoing)

**Challenge 1: Instrument an Application**
- Given: sample microservice (Go, Python, or Node.js)
- Task: instrument with Prometheus metrics (requests, latency, errors)
- Criteria: all key metrics exposed, labels designed correctly, Prometheus scrapes successfully

**Challenge 2: Build a Custom Exporter**
- Given: sample API or log source
- Task: build exporter that exposes metrics from that source
- Criteria: valid metric format, Prometheus scrapes successfully, metrics update correctly

**Challenge 3: Debug a Broken Prometheus Setup**
- Given: broken Prometheus config + sample app with metrics
- Task: identify and fix issues (bad scrape config, wrong metric names, missing labels)
- Criteria: student identifies root cause, fixes config, verifies metrics appear, writes PromQL query proving fix

---

## Filesystem Structure

```
prometheus-course/
├── docs/
│   ├── getting-started/
│   │   ├── README.md (overview, prerequisites)
│   │   ├── docker-setup.md (Docker Compose setup, first queries)
│   │   └── verify-setup.md (verification steps)
│   ├── module-1-fundamentals/
│   │   ├── day-1-architecture.md
│   │   ├── day-2-metrics-model.md
│   │   ├── day-3-scraping-basics.md
│   │   └── day-4-review.md
│   ├── module-2-instrumentation/
│   │   ├── day-5-client-libraries.md
│   │   ├── day-6-custom-metrics.md
│   │   ├── day-7-best-practices.md
│   │   └── day-8-capstone.md
│   ├── module-3-promql/
│   │   ├── day-9-basics.md
│   │   ├── day-10-aggregations.md
│   │   ├── day-11-rate-functions.md
│   │   ├── day-12-advanced.md
│   │   ├── day-13-14-real-world.md
│   │   └── day-15-capstone.md
│   ├── reference/
│   │   ├── glossary.md (DevOps/infrastructure terms)
│   │   ├── promql-cheatsheet.md
│   │   └── metric-types-reference.md
│   └── superpowers/
│       └── specs/
│           └── 2026-05-01-prometheus-course-design.md (this file)
├── labs/
│   ├── docker-compose.yml (Prometheus + Node Exporter + Node Exporter)
│   ├── setup.sh (one-liner for full setup)
│   ├── module-1-fundamentals/
│   │   ├── lab-1-scrape-config.md + prometheus.yml
│   │   ├── lab-2-relabel-rules.md + prometheus.yml
│   │   ├── lab-3-multi-target.md + prometheus.yml
│   │   └── solutions/ (answer configs)
│   ├── module-2-instrumentation/
│   │   ├── lab-4-go-instrumentation/
│   │   │   ├── main.go (sample app)
│   │   │   ├── lab-instructions.md
│   │   │   └── solutions/ (example instrumented code)
│   │   ├── lab-5-custom-metrics.md
│   │   ├── lab-6-exporter-basics/ (template exporter)
│   │   └── solutions/
│   ├── module-3-promql/
│   │   ├── lab-7-operators.md (20 exercises + answers)
│   │   ├── lab-8-aggregations.md
│   │   ├── lab-9-rate-functions.md
│   │   ├── lab-10-real-world.md
│   │   └── solutions/ (answer queries)
│   └── capstone/
│       ├── challenge-1-instrument-app/
│       │   ├── app.go (sample service)
│       │   ├── lab-instructions.md
│       │   └── scoring-criteria.md
│       ├── challenge-2-build-exporter/
│       │   ├── README.md
│       │   └── template/ (starter code)
│       └── challenge-3-debug-setup/
│           ├── broken-config/
│           └── debugging-guide.md
├── Makefile
│   ├── make setup (run docker-compose, verify)
│   ├── make day-1 (display day-1 instructions)
│   ├── make reset (reset docker volumes)
│   └── make capstone (run capstone challenges)
├── terraform/ (optional, for cloud sandbox nice-to-haves)
│   ├── main.tf
│   └── README.md (GCP/AWS sandbox setup)
├── README.md (course overview, quick start)
└── .gitignore (include /labs/prometheus-data, Docker volumes)
```

---

## Guide Format (Each Day)

Each guide (day-X.md) follows this structure:

1. **Header:** learning outcomes (3-4 bullets), estimated time (60-90 min)
2. **Conceptual Explainer** (500-800 words)
   - Core concepts explained plain English
   - Diagrams (ASCII or SVG) where helpful
   - **Glossary sidebar:** key terms for DevOps/infra newcomers
3. **Hands-On Section** (with code examples)
   - Step-by-step walkthrough
   - Copy-paste-ready code snippets
   - **Common mistakes:** callouts for frequent pitfalls
4. **Reference Section**
   - Lookup-style syntax tables
   - Configuration templates
   - Best practices checklist
5. **Lab Instructions**
   - Separate file for each day's lab
   - Step-by-step lab walkthrough
   - Solutions folder for self-checking
6. **Exit Criteria**
   - How students know they've completed the day
   - Verification steps (e.g., "run this command, verify output matches")

---

## Lab Architecture

**Shared Environment:**
- All labs use Docker Compose (labs/docker-compose.yml)
  - Prometheus (pulls from Node Exporter + Node Exporter)
  - Node Exporter (exposes system metrics)
  - Sample metrics endpoint (exposes hardcoded metrics for early labs)
  - One-liner: `docker-compose -f labs/docker-compose.yml up`

**Lab Structure by Module:**

**Module 1 Labs:** Edit prometheus.yml scrape configs
- Labs are isolated via config volume mounts
- Changes apply immediately (Prometheus reloads on SIGHUP)
- Students can reset via `make reset`

**Module 2 Labs:** Modify instrumentation code + deploy
- Sample Go app (main.go) with template instrumentation
- Students add metrics, rebuild, restart container
- Labs progress: add counter → add gauge → add histogram → build exporter

**Module 3 Labs:** Write PromQL queries in text files, test live
- Query files: students write queries in plain text
- Testing: `curl localhost:9090/api/v1/query?query=<query>`
- Labs include sample datasets (pre-recorded metrics) for consistency

**Capstone Labs:** Full challenges with real code
- Challenge 1: instrument provided app
- Challenge 2: build exporter from scratch
- Challenge 3: debug broken setup
- Scoring: code runs, metrics expose, queries work

---

## Tools & Dependencies

**Required:**
- Docker + Docker Compose
- Git
- Text editor or browser (for reading guides, Prometheus UI)

**Optional:**
- Code editor (for capstone instrumentation)
- Go + Python (only for optional capstone challenges)
- Grafana (optional, for visualization nice-to-haves)

**Installation:**
- macOS: `brew install docker docker-compose git`
- Linux: `sudo apt install docker.io docker-compose git`
- Windows: Docker Desktop (includes Docker + Docker Compose)

---

## Success Criteria

**Student completes course successfully when:**
1. ✓ Runs `make setup`, Docker environment starts cleanly
2. ✓ Completes Getting Started (first PromQL queries work)
3. ✓ Passes all daily labs (can self-check against solutions)
4. ✓ Completes all 3 capstone challenges with working code + queries

**Checkpoints:**
- Day 1-4: Can modify scrape configs, understand metrics model
- Day 5-8: Can instrument sample app, build exporter
- Day 9-15: Can write 20+ production-grade PromQL queries

---

## Timeline & Cadence

- **Week 1:** Getting Started + Module 1 (fundamentals)
- **Week 2:** Module 2 (instrumentation) + start Module 3 (PromQL)
- **Week 3:** Module 3 (PromQL) + capstone challenges

**Commitment:** 2-3 hours/day for 15 days (self-paced, no deadlines)

---

## Future Enhancements (Out of Scope)

- Video walkthroughs (stretch goal)
- Cloud sandbox (Terraform for GCP/AWS)
- Alerting rules + alert evaluation
- OpenTelemetry integration
- Prometheus federation + long-term storage
- Production troubleshooting guide
- Grafana dashboard creation (optional module)

---

## Appendix: Sample Day Structure

**Example: Day 1 (Prometheus Architecture)**

**File:** `docs/module-1-fundamentals/day-1-architecture.md`

```
# Day 1: Prometheus Architecture
**Time:** 90 minutes | **Prerequisites:** Docker installed, Getting Started completed

## Learning Outcomes
- [ ] Understand Prometheus pull model vs push model
- [ ] Know key Prometheus components (server, TSDB, scraper, alertmanager)
- [ ] Identify how Prometheus differs from other monitoring systems

## Conceptual Explainer (20 min read)
[Prometheus architecture explained: pull model, components, data flow]
[ASCII diagram: client → HTTP endpoint → Prometheus scraper → TSDB → queries]

**Glossary Sidebar:** time-series, scrape target, metrics endpoint, TSDB

## Hands-On: Explore Prometheus UI (30 min)
1. Start Docker: `docker-compose up`
2. Open browser: http://localhost:9090
3. Click "Targets" tab — see Node Exporter + Node Exporter
4. Click "Graph" tab — explore metrics
5. Run sample query: `up{job="prometheus"}`

## Reference
- Prometheus components comparison table
- Pull vs push model decision tree
- Glossary of Prometheus terms

## Lab: `labs/module-1-fundamentals/lab-1-scrape-config.md`
[Lab instructions for exploring Prometheus UI]
[Solution: screenshot + expected metrics]

## Exit Criteria
- [ ] Docker running smoothly
- [ ] Prometheus UI loads at localhost:9090
- [ ] "Targets" page shows at least 2 targets
- [ ] Can run 3 basic queries: `up`, `node_cpu_seconds_total`, `node_memory_MemFree_bytes`
```

---

## Notes for Implementation

1. **Self-paced:** No enforced deadlines; students progress at their own speed
2. **Validation:** Each day has clear exit criteria; solutions provided for self-checking
3. **DevOps baseline assumed:** Guides assume Linux/Kubernetes familiarity; glossaries support newcomers
4. **Hands-on first:** Getting Started gets students running Prometheus before any theory
5. **Progressive complexity:** Days 1-4 are gentle, Days 9-15 expect deeper understanding
6. **No videos/slides:** Pure written guides + code examples (reduces friction, easier to maintain)
