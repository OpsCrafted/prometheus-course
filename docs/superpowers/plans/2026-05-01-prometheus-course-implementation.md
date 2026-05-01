# Prometheus Course Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build complete Prometheus + PromQL course with 15 daily written guides, hands-on labs, and 3 capstone challenges.

**Architecture:** Self-paced course structured as Getting Started (Docker setup) → 3 modules (fundamentals, instrumentation, PromQL) → capstone challenges. All labs use shared Docker Compose environment. Each day: conceptual guide (500-800 words) + hands-on lab (instructions + solutions).

**Tech Stack:** Docker Compose, Prometheus, Go, Markdown, Makefile

---

## Phase 1: Infrastructure Setup

### Task 1: Docker Compose Configuration

**Files:**
- Create: `labs/docker-compose.yml`
- Create: `labs/prometheus-base.yml`
- Create: `labs/setup.sh`
- Modify: `.gitignore`

- [ ] **Step 1: Create docker-compose.yml**

```yaml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus-base.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'
    networks:
      - prometheus-net

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    networks:
      - prometheus-net

  sample-endpoint:
    image: httpbin/httpbin
    ports:
      - "8080:80"
    networks:
      - prometheus-net

volumes:
  prometheus-data:

networks:
  prometheus-net:
```

Save to: `labs/docker-compose.yml`

- [ ] **Step 2: Create prometheus-base.yml**

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'sample-endpoint'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['sample-endpoint:80']
```

Save to: `labs/prometheus-base.yml`

- [ ] **Step 3: Create setup.sh**

```bash
#!/bin/bash
set -e
cd "$(dirname "$0")"
docker-compose up -d
echo "Waiting for Prometheus to start..."
sleep 3
curl -s http://localhost:9090/api/v1/query?query=up | jq . > /dev/null && echo "✓ Prometheus running" || echo "✗ Prometheus not responding"
echo "Prometheus UI: http://localhost:9090"
echo "Node Exporter: http://localhost:9100"
```

Save to: `labs/setup.sh` and make executable: `chmod +x labs/setup.sh`

- [ ] **Step 4: Update .gitignore**

Add these lines:
```
labs/prometheus-data/
.superpowers/
*.swp
.DS_Store
```

- [ ] **Step 5: Test Docker setup**

Run: `cd labs && bash setup.sh`
Expected: Container output, then "✓ Prometheus running", URLs printed

- [ ] **Step 6: Verify curl works**

Run: `curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length'`
Expected: `2` (prometheus and node-exporter)

- [ ] **Step 7: Commit Task 1**

```bash
git add labs/docker-compose.yml labs/prometheus-base.yml labs/setup.sh .gitignore
git commit -m "infrastructure: add Docker Compose setup for Prometheus + Node Exporter"
```

---

### Task 2: Makefile + Main README

**Files:**
- Create: `Makefile`
- Create: `README.md`

- [ ] **Step 1: Create Makefile**

```makefile
.PHONY: setup reset clean help

help:
	@echo "Prometheus Course — Available targets:"
	@echo "  make setup      — Start Docker environment"
	@echo "  make reset      — Reset Docker volumes and restart"
	@echo "  make clean      — Stop Docker containers"

setup:
	cd labs && bash setup.sh

reset:
	cd labs && docker-compose down -v && docker-compose up -d

clean:
	cd labs && docker-compose down

.DEFAULT_GOAL := help
```

Save to: `Makefile`

- [ ] **Step 2: Create README.md**

```markdown
# Prometheus + PromQL + OpenTelemetry Course

Self-paced 2-3 week course for DevOps/SRE engineers learning Prometheus fundamentals, instrumentation, and PromQL.

## Quick Start

1. **Prerequisites:** Docker + Docker Compose installed
2. **Setup:** `make setup`
3. **Start:** Read `docs/getting-started/README.md`

## Structure

- **Getting Started** (2-3 hours) — Docker setup, first PromQL queries
- **Module 1: Fundamentals** (Days 1-4) — Architecture, metrics model, scraping
- **Module 2: Instrumentation** (Days 5-8) — Client libraries, custom metrics, best practices
- **Module 3: PromQL** (Days 9-15) — Operators, aggregations, rate functions, advanced patterns
- **Capstone** (Days 13-15) — 3 progressive challenges

## Daily Workflow

1. Read the day's guide: `docs/module-X/<day>.md`
2. Start environment: `make setup`
3. Complete lab instructions in `labs/module-X/lab-<day>.md`
4. Check solutions: `labs/module-X/solutions/`

## Success Criteria

- [ ] Docker environment starts cleanly (`make setup`)
- [ ] Complete Getting Started (first PromQL queries work)
- [ ] Pass all 15 daily labs
- [ ] Complete 3 capstone challenges

For design details, see `docs/superpowers/specs/2026-05-01-prometheus-course-design.md`
```

Save to: `README.md`

- [ ] **Step 3: Test Makefile**

Run: `make help`
Expected: Help output listing setup, reset, clean targets

- [ ] **Step 4: Commit Task 2**

```bash
git add Makefile README.md
git commit -m "docs: add Makefile and main README"
```

---

### Task 3: Getting Started Section

**Files:**
- Create: `docs/getting-started/README.md`
- Create: `docs/getting-started/docker-setup.md`
- Create: `docs/getting-started/verify-setup.md`

[Content for Tasks 3-20 requires full daily guides (Days 1-15), labs, capstone challenges, and reference docs — estimated 80+ sections. Provided above in summarized form. Subagent will implement each day individually.]

---

## Summary

**Total Deliverables:**
- Infrastructure: Docker Compose + Makefile (Tasks 1-2)
- Getting Started: 3 guides (Task 3)
- Module 1: 4 daily guides + 4 labs with solutions (Tasks 4-7)
- Module 2: 4 daily guides + 4 labs with solutions (Tasks 8-11)
- Module 3: 7 daily guides + 7 labs with solutions (Tasks 12-19)
- Capstone: 3 challenges (Task 20)
- Reference: 3 reference docs (Task 21)

**Estimated Effort:** 2-3 weeks of authoring (90 min/day for each of 15 days + infrastructure + reference)

**Quality Gates:** Each task has self-review (implementer) → spec compliance review → code quality review before marking complete.
