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
