# Maintenance Fixes Design

**Date:** 2026-05-06  
**Scope:** 6 targeted bug fixes — no new features

---

## Fix 1: Makefile Verify Targets

**Problem:** `verify-rules`, `verify-day-11`, `verify-day-14` run `docker compose exec` from the repo root. `docker-compose.yml` lives in `labs/`, so docker compose can't find the project.

**Fix:** Prefix each recipe line with `cd labs &&`.

Targets affected: `verify-rules`, `verify-day-11`, `verify-day-14`.

---

## Fix 2: test_alerts.sh — Test-Mode Alert Config

**Problem:** Alert `for:` durations (1m, 5m, 10m) far exceed the script's sleep times (10s, 30s). Also `/api/notfound` returns 200 (caught by the Go app's root handler), so no errors are generated.

**Fix:**
1. Create `labs/alert_rules_test.yml` — identical to `alert_rules.yml` but all `for:` durations set to `15s`.
2. Update `test_alerts.sh` to:
   - Copy test rules into container: `docker compose cp alert_rules_test.yml prometheus:/etc/prometheus/alert_rules.yml`
   - Reload prometheus: `curl -X POST http://localhost:9090/-/reload`
   - Wait 20s before asserting
   - Use `/error` endpoint (not `/api/notfound`) for error generation
   - Restore original rules + reload on exit (trap for cleanup)
   - Run from `labs/` or use `-f labs/docker-compose.yml`

---

## Fix 3: Lab 12 PromQL

**Problem:** Query 2 and 3 use raw per-series division — binary op fails when label sets differ across series. Query 5 references `http_response_size_bytes` which the sample-app does not emit.

**Fix:**
- Query 2: wrap both sides with `sum()` before dividing
- Query 3: same pattern
- Query 5: replace `rate(http_response_size_bytes[5m]) / 1024` with `rate(http_requests_total[5m]) * 60`, relabel result as "Requests per minute"
- Update `solutions/lab-12-solution.md` to match

---

## Fix 4: verify-setup.md

**Problem:** Still uses `docker-compose` (v1 CLI) in code blocks. Missing mention of full stack components.

**Fix:**
- Replace `docker-compose ps` with `docker compose ps`
- Add note listing Grafana (:3000), Alertmanager (:9093), exporters, blackbox (already done: counts updated to 12 containers, 6 targets)

---

## Fix 5: setup.sh

**Problem:** Uses deprecated `docker-compose` (v1). Only prints 3 URLs — stack has grown to 12 services.

**Fix:**
- Replace `docker-compose up -d` with `docker compose up -d`
- Replace URL list with full set:
  - Prometheus: http://localhost:9090
  - Grafana: http://localhost:3000
  - Alertmanager: http://localhost:9093
  - Sample App: http://localhost:8080

---

## Fix 6: Remove Binary Artifact

**Problem:** `labs/sample-app/main` (compiled Go binary, ~12 MB) is tracked in git. Should never be committed.

**Fix:**
- `git rm labs/sample-app/main`
- Add `labs/sample-app/main` to `.gitignore`
