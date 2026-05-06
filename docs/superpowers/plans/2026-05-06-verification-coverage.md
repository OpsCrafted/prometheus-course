# Verification Coverage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 6 student self-check `make verify-day-*` targets to the Makefile covering Module 2 Day 5 and Module 3 Days 9, 10, 12, 13, 15.

**Architecture:** All changes go to one file (`Makefile`). Each new target follows the established pattern: `cd labs && docker compose exec prometheus wget` → `jq` validation → `✓`/`✗` output. Two tasks split by module for clean commit history.

**Tech Stack:** GNU Make, Docker Compose v2, Prometheus HTTP API, jq, wget.

---

## File Map

| File | Change |
|------|--------|
| `Makefile` | Add 6 new `.PHONY` entries, 6 `help` lines, 6 target blocks |

---

### Task 1: Add verify-day-5 (Module 2 — Go Instrumentation)

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Update the `.PHONY` line**

In `Makefile` line 1, add `verify-day-5` to the existing `.PHONY` declaration:

```makefile
.PHONY: setup verify down clean reset logs-prometheus logs-grafana logs-app verify-rules verify-day-5 verify-day-11 verify-day-14 help
```

- [ ] **Step 2: Add help entry**

In the `help` target, after the existing `make logs-app` line, add:

```makefile
	@echo "  make verify-day-5      — Verify Day 5 (Go instrumentation metrics)"
```

- [ ] **Step 3: Add the target**

After the `logs-app` target and before `verify-rules`, add:

```makefile
.PHONY: verify-day-5
verify-day-5:
	@echo "Verifying Day 5 (Go instrumentation)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_requests_total' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ http_requests_total counter exists" || (echo "✗ http_requests_total not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_request_duration_seconds_bucket' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ http_request_duration_seconds histogram exists" || (echo "✗ http_request_duration_seconds not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_request_size_bytes' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ http_request_size_bytes histogram exists" || (echo "✗ http_request_size_bytes not found"; exit 1)
```

- [ ] **Step 4: Run `make verify-day-5` to verify it passes**

```bash
make verify-day-5
```

Expected output:
```
Verifying Day 5 (Go instrumentation)...
✓ http_requests_total counter exists
✓ http_request_duration_seconds histogram exists
✓ http_request_size_bytes histogram exists
```

If any check fails, confirm `docker compose ps` shows sample-app running and hit `curl http://localhost:8080/` once to generate a request before re-running.

- [ ] **Step 5: Commit**

```bash
git add Makefile
git commit -m "feat: add verify-day-5 target (Go instrumentation metrics)"
```

---

### Task 2: Add verify-day-9, 10, 12, 13, 15 (Module 3 — PromQL)

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Update the `.PHONY` line**

Add all 5 new targets to the `.PHONY` declaration (result after Task 1's change):

```makefile
.PHONY: setup verify down clean reset logs-prometheus logs-grafana logs-app verify-rules verify-day-5 verify-day-9 verify-day-10 verify-day-12 verify-day-13 verify-day-15 verify-day-11 verify-day-14 help
```

- [ ] **Step 2: Add help entries**

In the `help` target, after the `verify-day-5` line added in Task 1, add:

```makefile
	@echo "  make verify-day-9      — Verify Day 9 (instant queries and label selectors)"
	@echo "  make verify-day-10     — Verify Day 10 (aggregation operators)"
	@echo "  make verify-day-12     — Verify Day 12 (binary operators)"
	@echo "  make verify-day-13     — Verify Day 13 (PromQL functions)"
	@echo "  make verify-day-15     — Verify Day 15 (PromQL capstone)"
```

- [ ] **Step 3: Add all 5 targets**

After the `verify-day-5` target and before `verify-rules`, add:

```makefile
.PHONY: verify-day-9
verify-day-9:
	@echo "Verifying Day 9 (instant queries and label selectors)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22prometheus%22%7D' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ exact label match works" || (echo "✗ exact label match failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_requests_total%7Bendpoint%3D%22%2F%22%7D' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ endpoint label filter works" || (echo "✗ endpoint label filter failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_requests_total%7Bmethod%3D~%22G.*%22%7D' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ regex label filter works" || (echo "✗ regex label filter failed"; exit 1)

.PHONY: verify-day-10
verify-day-10:
	@echo "Verifying Day 10 (aggregation operators)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=count(up)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ count(up) works" || (echo "✗ count(up) failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(http_requests_total)%20by%20(method)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ sum() by (method) works" || (echo "✗ sum() by (method) failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=avg(node_cpu_seconds_total)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ avg() works" || (echo "✗ avg() failed"; exit 1)

.PHONY: verify-day-12
verify-day-12:
	@echo "Verifying Day 12 (binary operators)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(http_request_duration_seconds_sum)%20%2F%20sum(http_request_duration_seconds_count)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ arithmetic binary op (sum/sum) works" || (echo "✗ arithmetic binary op failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%7Bstatus%3D%22200%22%7D%5B5m%5D))%20%2F%20sum(rate(http_requests_total%5B5m%5D))' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ success ratio query works" || (echo "✗ success ratio query failed — stack may need 5+ minutes of uptime"; exit 1)

.PHONY: verify-day-13
verify-day-13:
	@echo "Verifying Day 13 (PromQL functions)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=round(node_memory_MemFree_bytes%20%2F%201e9)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ round() math function works" || (echo "✗ round() failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=changes(up%5B15m%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ changes() range function works" || (echo "✗ changes() failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=rate(http_requests_total%5B5m%5D%20offset%201m)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ offset modifier works" || (echo "✗ offset modifier failed — stack may need 1+ minute of uptime"; exit 1)

.PHONY: verify-day-15
verify-day-15:
	@echo "Verifying Day 15 (PromQL capstone)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=count(up%20%3D%3D%201)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ boolean comparison (up == 1) works" || (echo "✗ boolean comparison failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%5B5m%5D))%20by%20(endpoint)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ rate by endpoint works" || (echo "✗ rate by endpoint failed — stack may need 5+ minutes of uptime"; exit 1)
```

- [ ] **Step 4: Run all 5 targets to verify they pass**

```bash
make verify-day-9 && make verify-day-10 && make verify-day-12 && make verify-day-13 && make verify-day-15
```

Expected output for each:
```
Verifying Day 9 (instant queries and label selectors)...
✓ exact label match works
✓ endpoint label filter works
✓ regex label filter works
Verifying Day 10 (aggregation operators)...
✓ count(up) works
✓ sum() by (method) works
✓ avg() works
Verifying Day 12 (binary operators)...
✓ arithmetic binary op (sum/sum) works
✓ success ratio query works
Verifying Day 13 (PromQL functions)...
✓ round() math function works
✓ changes() range function works
✓ offset modifier works
Verifying Day 15 (PromQL capstone)...
✓ boolean comparison (up == 1) works
✓ rate by endpoint works
```

If any rate/offset check fails, confirm the stack has been running for at least 5 minutes (`docker compose ps` shows all containers Up). These functions require historical data windows.

- [ ] **Step 5: Commit**

```bash
git add Makefile
git commit -m "feat: add verify-day-9/10/12/13/15 targets (Module 3 PromQL)"
```
