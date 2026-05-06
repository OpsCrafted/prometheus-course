# Content Correctness Design

**Date:** 2026-05-06  
**Scope:** 4 targeted fixes — correct metric gaps in sample-app, remove a wrong relabeling example, fix two comment/label errors.

---

## Problem

Four content correctness issues found during curriculum review:

| # | File | Issue | Impact |
|---|------|-------|--------|
| 1 | `labs/sample-app/main.go` | Missing `http_request_size_bytes` and `http_response_size_bytes` histograms referenced in lab guides | Students can't query these metrics; exercises silently return empty results |
| 2 | `labs/capstone/scenario-2-cardinality-explosion/solution.md` lines 31–35 | First relabeling block uses `source_labels: [__name__]` + `action: drop` — this drops the entire metric, not just the label | Students copy wrong example; causes metric loss not label pruning |
| 3 | `labs/capstone/broken-lab/broken-prometheus.yml` line 9 | Comment reads "9100 instead of 9100" (tautology) | Debug hint is meaningless; students can't tell if the port is intentionally wrong |
| 4 | `labs/capstone/scenario-2-cardinality-explosion/solution.md` line 54 | Comment says "Query the TSDB cardinality endpoint" but URL is `/api/v1/label/__name__/values` (label values, not cardinality) | Students learn wrong API name |

---

## Fix 1: Add missing byte-size histograms to sample-app

**File:** `labs/sample-app/main.go`

**What to add:**

Two new histograms:
- `http_request_size_bytes` — measured from `r.ContentLength` (clamp to 0 if -1)
- `http_response_size_bytes` — measured by counting bytes written via `Write()`

Both use buckets `{100, 1000, 10000, 100000, 1000000}` bytes. Label: `endpoint` (matches duration histogram).

**`statusRecorder` change:**

Extend with a `bytesWritten int` field and a `Write` method:

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

**New metric declarations (add to `var` block):**

```go
httpRequestSizeBytes = prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Name:    "http_request_size_bytes",
        Help:    "HTTP request size in bytes",
        Buckets: []float64{100, 1000, 10000, 100000, 1000000},
    },
    []string{"endpoint"},
)

httpResponseSizeBytes = prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Name:    "http_response_size_bytes",
        Help:    "HTTP response size in bytes",
        Buckets: []float64{100, 1000, 10000, 100000, 1000000},
    },
    []string{"endpoint"},
)
```

**Register in `init()`:**

```go
prometheus.MustRegister(httpRequestSizeBytes)
prometheus.MustRegister(httpResponseSizeBytes)
```

**Observe in `instrumentedHandler` after the handler call:**

```go
reqSize := r.ContentLength
if reqSize < 0 {
    reqSize = 0
}
httpRequestSizeBytes.WithLabelValues(endpoint).Observe(float64(reqSize))
httpResponseSizeBytes.WithLabelValues(endpoint).Observe(float64(recorder.bytesWritten))
```

**Rebuild required after change:**

```bash
cd labs && docker compose build sample-app && docker compose up -d sample-app
```

---

## Fix 2: Remove wrong relabeling example from scenario-2 solution

**File:** `labs/capstone/scenario-2-cardinality-explosion/solution.md`

**Problem:** Lines 31–35 show:

```yaml
relabel_configs:
  # Drop request_id and trace_id labels
  - source_labels: [__name__]
    regex: '.*request_id.*|.*trace_id.*'
    action: drop
```

`source_labels: [__name__]` with `action: drop` matches metric *names* containing those strings and drops the **entire metric**. This is wrong — it doesn't drop labels. The correct approach (`labeldrop`) is already shown on lines 36–38.

**Fix:** Remove the wrong block. The correct YAML block becomes:

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

Also update the "How it works" prose below to remove any reference to the dropped block.

---

## Fix 3: Fix tautology comment in broken-prometheus.yml

**File:** `labs/capstone/broken-lab/broken-prometheus.yml` line 9

**Change:**

```yaml
# BUG 1: Wrong port number (9100 instead of 9100)
```

→

```yaml
# BUG 1: Wrong port number (9999 instead of 9100)
```

---

## Fix 4: Fix misleading API label in scenario-2 solution

**File:** `labs/capstone/scenario-2-cardinality-explosion/solution.md` ~line 54

**Change:**

```
# Query the TSDB cardinality endpoint
curl http://localhost:9090/api/v1/label/__name__/values
```

→

```
# List all metric names (label values for __name__)
curl http://localhost:9090/api/v1/label/__name__/values
```

The actual TSDB cardinality endpoint is `/api/v1/status/tsdb`. The URL shown lists label values, not cardinality stats.

---

## What Does NOT Change

- Lab guide content (lab-12, day guides, etc.)
- Any other sample-app handlers or metric names
- Alert rules, docker-compose, Makefile
- Any other broken-lab files
