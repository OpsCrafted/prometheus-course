# Module 6: Pitfalls & Anti-Patterns

Prometheus is easy to use, but easy to break in production. This module covers the most
common mistakes engineers make when operating Prometheus at scale — mistakes that silently
degrade performance, cause data loss, or take down your monitoring stack entirely.

Each lesson pairs a conceptual explainer with a real incident scenario and a hands-on lab
so you experience the failure mode before encountering it in production.

---

## Lessons

| # | Title | Duration | What You Learn |
|---|-------|----------|----------------|
| 1 | [Cardinality Explosion](lesson-1-cardinality-explosion.md) | 30 min | Why unbounded labels destroy Prometheus memory and how to detect and fix them |
| 2 | High-Churn Metrics | 45 min | How short-lived labels (pod names, request IDs) create write storms and exhaust TSDB capacity |
| 3 | Scrape Interval Misuse | 45 min | Why scraping too fast wastes resources and scraping too slow hides incidents |

---

## Structure

Each lesson includes:

- **Conceptual explainer** — the mental model behind the pitfall
- **Real incident scenario** — a realistic production failure caused by the anti-pattern
- **Hands-on lab** — reproduce and fix the issue yourself

---

## Total Time: 2 hours

---

## Prerequisites

Complete Modules 1-3 before starting this module:

- Module 1: Fundamentals (metrics, labels, scraping)
- Module 2: Instrumentation (how to expose metrics from your app)
- Module 3: PromQL (querying and understanding your data)

---

## When to Use This Module

- You are scaling Prometheus beyond a single small service and want to avoid common traps
- Your Prometheus instance is consuming unexpectedly high memory or disk and you need to
  diagnose the cause
- You are reviewing a team member's instrumentation code and want a reference for what to
  flag in code review
