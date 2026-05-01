# Prometheus Course Redesign: Docker-First Lab Environment

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform course from documentation-heavy skeleton into production-like runnable environment with Grafana dashboards, Alertmanager, real infrastructure (Redis, Postgres), sample apps, load generators, validation scripts, and real incident scenarios.

**Architecture:** Replace web-ui terminal with enhanced Docker Compose environment (10+ services). Remove overpromises from README. Fix broken labs (config mounts, missing files). Add validation scripts (make verify-dayX). Create Grafana dashboards and alert rules. Redesign capstone from vague homework to real scenario with injected failures.

**Tech Stack:** Docker Compose, Prometheus, Grafana, Alertmanager, Redis, Postgres, Go (sample app + load generator), Blackbox Exporter, Node Exporter, promtool (validation).

---

## File Structure

**Removed:**
- `web-ui/` — entire directory (security risk, fragile markdown renderer)

**Core Infrastructure:**
- `labs/docker-compose.yml` — enhanced with Grafana, Alertmanager, sample app, databases, load generator
- `labs/prometheus.yml` — updated scrape configs
- `labs/alertmanager.yml` — new alert routing rules
- `labs/grafana/provisioning/` — dashboards, datasources (JSON files)
- `labs/sample-app/` — Go app (instrumented with metrics)
- `labs/load-generator/` — synthetic traffic generator
- `labs/incident-data/` — logs, metrics for capstone scenarios

**Validation & Verification:**
- `labs/scripts/verify-setup.sh` — health check all services
- `labs/scripts/verify-day-X.sh` — per-day validation
- `Makefile` — updated targets

**Lab Fixes:**
- `labs/module-1-fundamentals/lab-1-scrape-config.md` — fix config mount reference
- `labs/module-2-instrumentation/lab-8-review.md` — remove missing files
- `labs/module-3-promql/day-14-histograms.md` — teach correct pattern

**Documentation Updates:**
- `README.md` — remove overpromises
- `docs/getting-started/README.md` — remove browser UI references
- `docs/capstone/capstone-challenges.md` — replace with real scenarios

---

## Tasks

### Task 1: Remove web-ui

**Files:**
- Delete: `web-ui/` (entire directory)

- [ ] **Step 1: Remove directory**

```bash
rm -rf web-ui
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "refactor: remove web-ui terminal (security risk, fragile renderer)"
```

---

### Task 2: Create Enhanced docker-compose.yml

**Files:**
- Create: `labs/docker-compose.yml` (replace existing)

- [ ] **Step 1: Write enhanced docker-compose.yml**

```yaml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:v2.45.0
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:10.2.0
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
      GF_USERS_ALLOW_SIGN_UP: "false"
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning
      - grafana-data:/var/lib/grafana
    networks:
      - monitoring
    depends_on:
      - prometheus

  alertmanager:
    image: prom/alertmanager:v0.26.0
    restart: unless-stopped
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:v1.6.1
    restart: unless-stopped
    ports:
      - "9100:9100"
    networks:
      - monitoring

  sample-app:
    build: ./sample-app
    restart: unless-stopped
    ports:
      - "8080:8080"
    networks:
      - monitoring
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: monitoring_app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: apppass
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - monitoring

  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:v0.13.0
    restart: unless-stopped
    ports:
      - "9187:9187"
    environment:
      DATA_SOURCE_NAME: "postgresql://app:apppass@postgres:5432/monitoring_app?sslmode=disable"
    networks:
      - monitoring
    depends_on:
      - postgres

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    ports:
      - "6379:6379"
    networks:
      - monitoring

  redis-exporter:
    image: oliver006/redis_exporter:latest
    restart: unless-stopped
    ports:
      - "9121:9121"
    command:
      - '-redis.addr=redis:6379'
    networks:
      - monitoring
    depends_on:
      - redis

  blackbox-exporter:
    image: prom/blackbox-exporter:v0.24.0
    restart: unless-stopped
    ports:
      - "9115:9115"
    volumes:
      - ./blackbox.yml:/etc/blackbox-exporter/config.yml
    command:
      - '--config.file=/etc/blackbox-exporter/config.yml'
    networks:
      - monitoring

  load-generator:
    build: ./load-generator
    restart: unless-stopped
    environment:
      TARGET_URL: "http://sample-app:8080"
      REQUEST_RATE: "10"
    networks:
      - monitoring
    depends_on:
      - sample-app

  pushgateway:
    image: prom/pushgateway:v1.6.2
    restart: unless-stopped
    ports:
      - "9091:9091"
    networks:
      - monitoring

volumes:
  prometheus-data:
  grafana-data:
  postgres-data:

networks:
  monitoring:
```

- [ ] **Step 2: Verify syntax**

```bash
docker-compose -f labs/docker-compose.yml config > /dev/null
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add labs/docker-compose.yml
git commit -m "feat: enhanced docker-compose with Grafana, Alertmanager, databases, load generator"
```

---

### Task 3: Create Sample Go Application

**Files:**
- Create: `labs/sample-app/main.go`
- Create: `labs/sample-app/Dockerfile`
- Create: `labs/sample-app/go.mod`

- [ ] **Step 1: Create go.mod**

```
module github.com/opscrafted/sample-app

go 1.21

require (
	github.com/prometheus/client_golang v1.17.0
)
```

- [ ] **Step 2: Create main.go**

```go
package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	httpRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total HTTP requests",
		},
		[]string{"method", "endpoint", "status"},
	)

	httpRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request latency",
			Buckets: []float64{.001, .005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5},
		},
		[]string{"method", "endpoint"},
	)

	cacheHits = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "cache_hits_total",
			Help: "Cache hits",
		},
		[]string{"key"},
	)

	cacheMisses = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "cache_misses_total",
			Help: "Cache misses",
		},
		[]string{"key"},
	)
)

func handleRequest(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	status := 200

	time.Sleep(time.Duration(10+(rand.Intn(40))) * time.Millisecond)

	if rand.Intn(100) < 5 {
		status = 500
		w.WriteHeader(status)
	} else {
		w.Write([]byte("ok"))
	}

	duration := time.Since(start).Seconds()
	httpRequestsTotal.WithLabelValues(r.Method, r.URL.Path, fmt.Sprintf("%d", status)).Inc()
	httpRequestDuration.WithLabelValues(r.Method, r.URL.Path).Observe(duration)
}

func main() {
	http.HandleFunc("/api/request", handleRequest)
	http.Handle("/metrics", promhttp.Handler())

	log.Println("Starting sample app on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
```

- [ ] **Step 3: Create Dockerfile**

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o sample-app .

FROM alpine:3.18
COPY --from=builder /app/sample-app /usr/local/bin/
EXPOSE 8080
CMD ["sample-app"]
```

- [ ] **Step 4: Test build**

```bash
cd labs/sample-app && docker build -t sample-app:latest .
```

Expected: Build succeeds.

- [ ] **Step 5: Commit**

```bash
git add labs/sample-app/
git commit -m "feat: add instrumented Go sample app with Prometheus metrics"
```

---

### Task 4: Create Load Generator

**Files:**
- Create: `labs/load-generator/main.go`
- Create: `labs/load-generator/go.mod`
- Create: `labs/load-generator/Dockerfile`

- [ ] **Step 1: Create go.mod**

```
module github.com/opscrafted/load-generator

go 1.21
```

- [ ] **Step 2: Create main.go**

```go
package main

import (
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"
)

func main() {
	targetURL := os.Getenv("TARGET_URL")
	if targetURL == "" {
		targetURL = "http://localhost:8080"
	}

	requestRate, _ := strconv.Atoi(os.Getenv("REQUEST_RATE"))
	if requestRate == 0 {
		requestRate = 10
	}

	log.Printf("Generating traffic to %s at %d req/sec\n", targetURL, requestRate)

	ticker := time.NewTicker(time.Duration(1000/requestRate) * time.Millisecond)
	defer ticker.Stop()

	for range ticker.C {
		go func() {
			resp, err := http.Get(targetURL + "/api/request")
			if err != nil {
				log.Printf("Error: %v\n", err)
				return
			}
			resp.Body.Close()
		}()

		if rand.Intn(100) < 10 {
			for i := 0; i < 5; i++ {
				go func() {
					http.Get(targetURL + "/api/request")
				}()
			}
		}
	}
}
```

- [ ] **Step 3: Create Dockerfile**

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod download || true
RUN go build -o load-generator .

FROM alpine:3.18
COPY --from=builder /app/load-generator /usr/local/bin/
CMD ["load-generator"]
```

- [ ] **Step 4: Commit**

```bash
git add labs/load-generator/
git commit -m "feat: add load generator for synthetic traffic"
```

---

### Task 5: Create Grafana Provisioning

**Files:**
- Create: `labs/grafana/provisioning/datasources/prometheus.yml`
- Create: `labs/grafana/provisioning/dashboards/dashboard.yml`
- Create: `labs/grafana/provisioning/dashboards/main.json`

- [ ] **Step 1: Create datasources/prometheus.yml**

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

- [ ] **Step 2: Create dashboards/dashboard.yml**

```yaml
apiVersion: 1

providers:
  - name: dashboards
    orgId: 1
    folder: ''
    type: file
    options:
      path: /etc/grafana/provisioning/dashboards
```

- [ ] **Step 3: Create dashboards/main.json**

```json
{
  "dashboard": {
    "title": "Prometheus Monitoring",
    "tags": ["prometheus"],
    "timezone": "UTC",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "id": 2,
        "title": "P95 Latency",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))"
          }
        ]
      },
      {
        "id": 3,
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=\"500\"}[5m])"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add labs/grafana/
git commit -m "feat: add Grafana provisioning with sample dashboard"
```

---

### Task 6: Create Prometheus & Alertmanager Configs

**Files:**
- Create: `labs/prometheus.yml`
- Create: `labs/alertmanager.yml`
- Create: `labs/blackbox.yml`

- [ ] **Step 1: Create prometheus.yml**

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: node-exporter
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: sample-app
    static_configs:
      - targets: ["sample-app:8080"]

  - job_name: postgres
    static_configs:
      - targets: ["postgres-exporter:9187"]

  - job_name: redis
    static_configs:
      - targets: ["redis-exporter:9121"]

  - job_name: alertmanager
    static_configs:
      - targets: ["alertmanager:9093"]
```

- [ ] **Step 2: Create alertmanager.yml**

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: default

receivers:
  - name: default
```

- [ ] **Step 3: Create blackbox.yml**

```yaml
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_status_codes: [200, 204]
      method: GET
```

- [ ] **Step 4: Commit**

```bash
git add labs/prometheus.yml labs/alertmanager.yml labs/blackbox.yml
git commit -m "feat: add Prometheus scrape configs and Alertmanager routing"
```

---

### Task 7: Create Validation Scripts

**Files:**
- Create: `labs/scripts/verify-setup.sh`
- Modify: `Makefile`

- [ ] **Step 1: Create labs/scripts/verify-setup.sh**

```bash
#!/bin/bash
set -e

echo "Verifying Prometheus course setup..."

services=("prometheus" "grafana" "sample-app")
for service in "${services[@]}"; do
	docker-compose ps | grep -q "$service.*Up" || {
		echo "❌ Service $service not running"
		exit 1
	}
done

echo "✅ All services running"

curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length' | grep -q "[1-9]" && echo "✅ Prometheus targets active" || {
	echo "❌ No targets found"
	exit 1
}

curl -s http://localhost:3000/api/health | grep -q '"database":"ok"' && echo "✅ Grafana healthy" || {
	echo "❌ Grafana not healthy"
	exit 1
}

echo ""
echo "✅ Setup complete!"
echo "Prometheus: http://localhost:9090"
echo "Grafana:    http://localhost:3000 (admin/admin)"
```

- [ ] **Step 2: Make script executable**

```bash
chmod +x labs/scripts/verify-setup.sh
```

- [ ] **Step 3: Update Makefile**

```makefile
.PHONY: setup clean verify

setup:
	@cd labs && docker-compose up -d
	@sleep 5
	@bash scripts/verify-setup.sh

clean:
	@cd labs && docker-compose down -v

verify:
	@bash labs/scripts/verify-setup.sh
```

- [ ] **Step 4: Commit**

```bash
git add labs/scripts/verify-setup.sh Makefile
git commit -m "feat: add validation scripts and update Makefile"
```

---

### Task 8: Fix Lab 1 Config Mount

**Files:**
- Modify: `labs/module-1-fundamentals/lab-1-scrape-config.md`

- [ ] **Step 1: Read current lab**

```bash
head -30 labs/module-1-fundamentals/lab-1-scrape-config.md
```

- [ ] **Step 2: Fix mount path**

OLD: "Edit `labs/module-1-fundamentals/lab-1-prometheus.yml`"
NEW: "Edit `labs/prometheus.yml` (mounted at `/etc/prometheus/prometheus.yml`)"

- [ ] **Step 3: Add verification**

Append to lab:

```markdown
## Verify

Reload Prometheus:
\`\`\`bash
curl -X POST http://localhost:9090/-/reload
\`\`\`

Check Targets page: http://localhost:9090/targets
```

- [ ] **Step 4: Commit**

```bash
git add labs/module-1-fundamentals/lab-1-scrape-config.md
git commit -m "fix: correct Prometheus config mount path in lab 1"
```

---

### Task 9: Fix Lab 8 References

**Files:**
- Modify: `labs/module-2-instrumentation/lab-8-review.md`

- [ ] **Step 1: Remove missing file references**

Remove any mention of `app-best-practices-solution.go`.

Replace with: "See `labs/sample-app/main.go` for instrumentation example."

- [ ] **Step 2: Commit**

```bash
git add labs/module-2-instrumentation/lab-8-review.md
git commit -m "fix: remove missing solution file references"
```

---

### Task 10: Fix Histogram Teaching

**Files:**
- Modify: `docs/module-3-promql/day-14-histograms.md`

- [ ] **Step 1: Update histogram pattern**

OLD:
```
histogram_quantile(0.95, http_request_duration_seconds_bucket)
```

NEW (production-correct):
```
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```

Add note: "Always use `rate(...[5m])` and `sum by (le, ...)` for production. This handles multiple series correctly."

- [ ] **Step 2: Commit**

```bash
git add docs/module-3-promql/day-14-histograms.md
git commit -m "fix: teach correct histogram_quantile pattern with rate"
```

---

### Task 11: Redesign Capstone

**Files:**
- Create: `docs/capstone/scenario-1-latency.md`
- Create: `docs/capstone/scenario-2-cardinality.md`
- Create: `docs/capstone/scenario-3-outage.md`
- Modify: `docs/capstone/capstone-challenges.md`

- [ ] **Step 1: Create scenario-1-latency.md**

```markdown
# Scenario 1: Latency Spike Investigation

## Problem

You receive an alert: P95 latency jumped from 50ms to 2000ms. Users report slowness.

## Your Task

1. **Diagnose**: Query `histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))`
   - What is current P95?
   - When did it start?
   - Is it all endpoints or specific ones?

2. **Create alert**:
   ```yaml
   - alert: HighLatency
     expr: histogram_quantile(0.95, ...) > 0.5
     for: 1m
   ```

## Success

- [ ] Identified P95 value
- [ ] Found affected endpoint
- [ ] Created alert rule
```

- [ ] **Step 2: Create scenario-2-cardinality.md**

```markdown
# Scenario 2: Cardinality Explosion

## Problem

Prometheus memory usage jumped to 4GB. Queries are slow.

## Your Task

1. **Find high-cardinality metric**: Status → TSDB Status
2. **Identify problematic label**
3. **Write relabeling rule** to drop it

## Success

- [ ] Identified metric
- [ ] Found label
- [ ] Memory reduced
```

- [ ] **Step 3: Create scenario-3-outage.md**

```markdown
# Scenario 3: Partial Outage

## Problem

Sample app failing 50% of requests. Database target DOWN.

## Your Task

1. **Check target status**: `up{job="postgres"}`
2. **Measure impact**: `rate(http_requests_total{status="500"}[5m])`
3. **Create alert**: `up == 0`
4. **Recover service**: `docker-compose restart postgres`

## Success

- [ ] Identified outage
- [ ] Measured error rate
- [ ] Created alert
- [ ] Recovered service
```

- [ ] **Step 4: Update capstone-challenges.md**

```markdown
# Capstone Challenges

Three real incident scenarios using the lab environment.

## [Scenario 1: Latency Spike](scenario-1-latency.md)
Diagnose latency regression using histograms.

## [Scenario 2: Cardinality Explosion](scenario-2-cardinality.md)
Fix memory bloat from high-cardinality metrics.

## [Scenario 3: Partial Outage](scenario-3-outage.md)
Detect and respond to service degradation.
```

- [ ] **Step 5: Commit**

```bash
git add docs/capstone/
git commit -m "feat: replace vague capstone with 3 real incident scenarios"
```

---

### Task 12: Update README

**Files:**
- Modify: `README.md`
- Modify: `docs/getting-started/README.md`

- [ ] **Step 1: Update README title**

OLD: `# 📊 Prometheus + PromQL + OpenTelemetry Course`
NEW: `# 📊 Prometheus + PromQL Course`

Remove OpenTelemetry from learning outcomes.

- [ ] **Step 2: Update getting started**

Remove browser UI references. Replace with:

```markdown
## Quick Start

\`\`\`bash
make setup
\`\`\`

Access:
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)
```

- [ ] **Step 3: Commit**

```bash
git add README.md docs/getting-started/README.md
git commit -m "docs: update for Docker-first approach, remove overpromises"
```

---

### Task 13: Final Verification

**Files:**
- None (test & verify only)

- [ ] **Step 1: Test setup**

```bash
make clean
make setup
make verify
```

Expected: All pass.

- [ ] **Step 2: Test sample app**

```bash
curl http://localhost:8080/api/request
curl -s http://localhost:9090/api/v1/query?query=http_requests_total | jq
```

Expected: App responds, metrics exist.

- [ ] **Step 3: Access Grafana**

```
http://localhost:3000
```

Expected: Dashboard shows metrics.

- [ ] **Step 4: Final commit message**

```bash
git log --oneline | head -15
```

Expected: 13 commits covering redesign.

---

## Summary

**13 tasks, 5 major categories:**

1. **Remove** web-ui (Task 1)
2. **Build** infrastructure (Tasks 2-6)
3. **Add** validation (Task 7)
4. **Fix** labs (Tasks 8-10)
5. **Redesign** capstone (Task 11)
6. **Update** docs (Task 12)
7. **Verify** (Task 13)

**Deliverables:**
- ✅ Docker Compose (11 services)
- ✅ Grafana dashboards
- ✅ Sample Go app
- ✅ Load generator
- ✅ Validation scripts
- ✅ 3 capstone scenarios
- ✅ Fixed labs
- ✅ Updated docs

**Result:** Production-like environment. Every lab runs. Every step validates. Honest 7-8/10 course.

---

Plan complete and saved to `docs/superpowers/plans/2026-05-01-prometheus-course-redesign.md`.

**Two execution options:**

**1. Subagent-Driven (recommended)** - Fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session

Which approach?