# Content Correctness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix four content correctness issues: add missing byte-size histograms to sample-app, remove a wrong relabeling example, and fix two comment/label errors.

**Architecture:** Three independent tasks. Tasks 1 and 2 are pure text fixes — no runtime impact. Task 3 is a Go code change that adds two new histograms to the sample-app and requires a container rebuild to take effect.

**Tech Stack:** Go 1.21, prometheus/client_golang, Docker Compose v2.

---

## File Map

| File | Change |
|------|--------|
| `labs/capstone/broken-lab/broken-prometheus.yml` | Fix line 9 comment: "9100 instead of 9100" → "9999 instead of 9100" |
| `labs/capstone/scenario-2-cardinality-explosion/solution.md` | Remove wrong `source_labels + action: drop` block; fix misleading "TSDB cardinality endpoint" comment |
| `labs/sample-app/main.go` | Add two histogram vars, extend `statusRecorder`, register and observe in `instrumentedHandler` |

---

### Task 1: Fix broken-lab bug comment

**Files:**
- Modify: `labs/capstone/broken-lab/broken-prometheus.yml:9`

- [ ] **Step 1: Fix the comment**

In `labs/capstone/broken-lab/broken-prometheus.yml`, change line 9:

```yaml
  # BUG 1: Wrong port number (9100 instead of 9100)
```

to:

```yaml
  # BUG 1: Wrong port number (9999 instead of 9100)
```

- [ ] **Step 2: Verify**

```bash
grep "BUG 1" labs/capstone/broken-lab/broken-prometheus.yml
```

Expected:
```
  # BUG 1: Wrong port number (9999 instead of 9100)
```

- [ ] **Step 3: Commit**

```bash
git add labs/capstone/broken-lab/broken-prometheus.yml
git commit -m "fix: correct tautology in broken-lab bug comment (9100 -> 9999)"
```

---

### Task 2: Fix scenario-2 solution (two fixes)

**Files:**
- Modify: `labs/capstone/scenario-2-cardinality-explosion/solution.md`

Two changes in the same file:
1. Remove the wrong `source_labels + action: drop` relabeling block (lines 31–38) and keep only the `labeldrop` entry
2. Fix the misleading "TSDB cardinality endpoint" comment (~line 54)

- [ ] **Step 1: Replace the relabeling YAML block**

In `labs/capstone/scenario-2-cardinality-explosion/solution.md`, find this block (lines 22–39):

~~~markdown
```yaml
scrape_configs:
  - job_name: 'sample-app'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['sample-app:8080']
        labels:
          group: 'application'
    relabel_configs:
      # Drop request_id and trace_id labels
      - source_labels: [__name__]
        regex: '.*request_id.*|.*trace_id.*'
        action: drop
      # Alternative: drop specific label names
      - action: labeldrop
        regex: '(request_id|trace_id)'
```
~~~

Replace with:

~~~markdown
```yaml
scrape_configs:
  - job_name: 'sample-app'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['sample-app:8080']
        labels:
          group: 'application'
    relabel_configs:
      - action: labeldrop
        regex: '(request_id|trace_id)'
```
~~~

- [ ] **Step 2: Fix the misleading API comment**

In the same file, find (~line 53–56):

```
2. **Check Prometheus cardinality:**
   ```promql
   # Query the TSDB cardinality endpoint
   curl http://localhost:9090/api/v1/label/__name__/values
```

Change the comment from:

```
   # Query the TSDB cardinality endpoint
```

to:

```
   # List all metric names (label values for __name__)
```

- [ ] **Step 3: Verify both changes**

```bash
grep "source_labels" labs/capstone/scenario-2-cardinality-explosion/solution.md
```

Expected: (empty — wrong block is gone)

```bash
grep "TSDB cardinality endpoint" labs/capstone/scenario-2-cardinality-explosion/solution.md
```

Expected: (empty)

- [ ] **Step 4: Commit**

```bash
git add labs/capstone/scenario-2-cardinality-explosion/solution.md
git commit -m "fix: remove wrong relabeling example and fix misleading API comment in scenario-2 solution"
```

---

### Task 3: Add byte-size histograms to sample-app

**Files:**
- Modify: `labs/sample-app/main.go`

Four code sections change:
1. `var` block: add two new histogram declarations
2. `statusRecorder` struct: add `bytesWritten` field and `Write` method
3. `init()`: register the two new histograms
4. `instrumentedHandler`: observe request and response sizes after the handler returns

- [ ] **Step 1: Replace the `var` block**

In `labs/sample-app/main.go`, replace the entire `var (...)` block (lines 18–45) with:

```go
var (
	// Counter: total HTTP requests with method, endpoint, and status labels
	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "endpoint", "status"},
	)

	// Gauge: active connections
	activeConnections = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "active_connections",
			Help: "Number of active connections",
		},
	)

	// Histogram: HTTP request duration in seconds with endpoint label
	httpRequestDurationSeconds = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request latency in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"endpoint"},
	)

	// Histogram: HTTP request body size in bytes
	httpRequestSizeBytes = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_size_bytes",
			Help:    "HTTP request size in bytes",
			Buckets: []float64{100, 1000, 10000, 100000, 1000000},
		},
		[]string{"endpoint"},
	)

	// Histogram: HTTP response body size in bytes
	httpResponseSizeBytes = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_response_size_bytes",
			Help:    "HTTP response size in bytes",
			Buckets: []float64{100, 1000, 10000, 100000, 1000000},
		},
		[]string{"endpoint"},
	)
)
```

- [ ] **Step 2: Replace `statusRecorder` struct and `WriteHeader` method**

Replace lines 55–63 (the `statusRecorder` struct and `WriteHeader` method) with:

```go
type statusRecorder struct {
	http.ResponseWriter
	status       int
	bytesWritten int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.status = code
	r.ResponseWriter.WriteHeader(code)
}

func (r *statusRecorder) Write(b []byte) (int, error) {
	n, err := r.ResponseWriter.Write(b)
	r.bytesWritten += n
	return n, err
}
```

- [ ] **Step 3: Replace `init()` to register new metrics**

Replace the `init()` function (lines 47–52) with:

```go
func init() {
	prometheus.MustRegister(httpRequestsTotal)
	prometheus.MustRegister(activeConnections)
	prometheus.MustRegister(httpRequestDurationSeconds)
	prometheus.MustRegister(httpRequestSizeBytes)
	prometheus.MustRegister(httpResponseSizeBytes)
}
```

- [ ] **Step 4: Replace `instrumentedHandler` to observe size metrics**

Replace the `instrumentedHandler` function (lines 66–82) with:

```go
func instrumentedHandler(endpoint string, handler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		recorder := &statusRecorder{ResponseWriter: w, status: 200}

		activeConnections.Inc()
		defer activeConnections.Dec()

		start := time.Now()
		handler(recorder, r)
		duration := time.Since(start).Seconds()

		httpRequestsTotal.WithLabelValues(r.Method, endpoint, strconv.Itoa(recorder.status)).Inc()
		httpRequestDurationSeconds.WithLabelValues(endpoint).Observe(duration)

		reqSize := r.ContentLength
		if reqSize < 0 {
			reqSize = 0
		}
		httpRequestSizeBytes.WithLabelValues(endpoint).Observe(float64(reqSize))
		httpResponseSizeBytes.WithLabelValues(endpoint).Observe(float64(recorder.bytesWritten))
	}
}
```

- [ ] **Step 5: Build and restart the container**

```bash
cd labs && docker compose build sample-app && docker compose up -d sample-app
```

Expected: build exits 0, container restarts. No "undefined" or "cannot use" Go errors.

- [ ] **Step 6: Verify new metrics appear**

```bash
curl -s http://localhost:8080/ > /dev/null && curl -s http://localhost:8080/metrics | grep '^http_request_size_bytes\|^http_response_size_bytes' | head -20
```

Expected output (bucket lines for both histograms):

```
http_request_size_bytes_bucket{endpoint="/",le="100"} 1
http_request_size_bytes_bucket{endpoint="/",le="1000"} 1
http_request_size_bytes_bucket{endpoint="/",le="10000"} 1
http_request_size_bytes_bucket{endpoint="/",le="100000"} 1
http_request_size_bytes_bucket{endpoint="/",le="1e+06"} 1
http_request_size_bytes_bucket{endpoint="/",le="+Inf"} 1
http_request_size_bytes_sum{endpoint="/"} 0
http_request_size_bytes_count{endpoint="/"} 1
http_response_size_bytes_bucket{endpoint="/",le="100"} 1
...
```

- [ ] **Step 7: Commit**

```bash
git add labs/sample-app/main.go
git commit -m "feat: add http_request_size_bytes and http_response_size_bytes histograms to sample-app"
```
