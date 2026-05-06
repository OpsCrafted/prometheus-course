# Verification Coverage Design

**Date:** 2026-05-06  
**Scope:** Add 6 student self-check `make verify-day-*` targets to the Makefile covering Module 2 Day 5 and Module 3 Days 9, 10, 12, 13, 15.

---

## Problem

The Makefile has only two day-specific verify targets (`verify-day-11`, `verify-day-14`). Students completing other labs have no quick self-check command to confirm their queries work against the live stack. Days 9, 10, 12, 13, and 15 (all PromQL) and Day 5 (Go instrumentation) have no coverage.

---

## Solution

6 new Makefile targets, one per uncovered lab day. Pattern matches existing `verify-day-11` and `verify-day-14`:
- `cd labs &&` prefix (required — `docker-compose.yml` lives in `labs/`)
- `docker compose exec prometheus wget -q -O -` against the Prometheus API
- `jq -e '.status == "success" and (.data.result | length > 0)'` for success+non-empty
- `echo "✓ msg"` on pass, `(echo "✗ msg"; exit 1)` on fail
- Each target added to `.PHONY` and documented in `help`

Module 1 days are already covered by the existing `make verify` (verify-setup.sh). Days 7 and 8 are best-practices/conceptual — not mechanically verifiable.

---

## Per-Target Specification

### verify-day-5 (Go Instrumentation)

Verifies the sample-app's instrumented metrics are being scraped.

```
✓ http_requests_total counter exists
✓ http_request_duration_seconds histogram exists
✓ http_request_size_bytes histogram exists
```

Queries:
1. `http_requests_total`
2. `http_request_duration_seconds_bucket`
3. `http_request_size_bytes`

### verify-day-9 (Instant Queries)

Verifies label selectors and regex filters work.

```
✓ exact label match: up{job="prometheus"}
✓ label filter on app metric: http_requests_total{endpoint="/"}
✓ regex filter: http_requests_total{method=~"G.*"}
```

Queries:
1. `up{job="prometheus"}`
2. `http_requests_total{endpoint="/"}`
3. `http_requests_total{method=~"G.*"}`

### verify-day-10 (Aggregation)

Verifies aggregation operators.

```
✓ count(up) works
✓ sum() by (method) works
✓ avg() across series works
```

Queries:
1. `count(up)`
2. `sum(http_requests_total) by (method)`
3. `avg(node_cpu_seconds_total)`

### verify-day-12 (Binary Operators)

Verifies arithmetic binary operations on matching series.

```
✓ duration average (sum/sum) works
✓ success ratio (rate/rate) works
```

Queries:
1. `sum(http_request_duration_seconds_sum) / sum(http_request_duration_seconds_count)`
2. `sum(rate(http_requests_total{status="200"}[5m])) / sum(rate(http_requests_total[5m]))`

### verify-day-13 (Functions)

Verifies math functions, range functions, and offset modifier.

```
✓ round() math function works
✓ changes() range function works
✓ offset modifier works
```

Queries:
1. `round(node_memory_MemFree_bytes / 1e9)`
2. `changes(up[15m])`
3. `rate(http_requests_total[5m] offset 1m)`

### verify-day-15 (Capstone)

Verifies multi-step real-world queries used in the capstone lab.

```
✓ boolean comparison (up == 1) works
✓ rate by endpoint works
```

Queries:
1. `count(up == 1)`
2. `sum(rate(http_requests_total[5m])) by (endpoint)`

---

## What Does NOT Change

- Existing targets (`verify`, `verify-rules`, `verify-day-11`, `verify-day-14`)
- Any lab content files
- Docker Compose or any other config
