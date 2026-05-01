# Day 6: HTTP Metrics & Middleware

**Time:** 90 minutes | **Prerequisites:** Day 5 completed

## Learning Outcomes

- [ ] Build HTTP middleware that records metrics
- [ ] Track request duration, status codes, paths
- [ ] Aggregate metrics by labels

## Conceptual Explainer

Middleware is code that runs before/after each request. Perfect for recording metrics.

### Middleware Pattern

```go
func metricsMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        
        // Call next handler
        next.ServeHTTP(w, r)
        
        // Record metrics
        duration := time.Since(start).Seconds()
        // ... record duration, status, path ...
    })
}
```

### Recording Status Codes

To capture status codes, wrap `ResponseWriter`:

```go
type statusRecorder struct {
    http.ResponseWriter
    statusCode int
}

func (r *statusRecorder) WriteHeader(code int) {
    r.statusCode = code
    r.ResponseWriter.WriteHeader(code)
}
```

### Metrics to Track

- `http_requests_total{method, status, path}` — Counter
- `http_request_duration_seconds{method, path}` — Histogram
- `http_request_size_bytes` — Histogram (request payload size)
- `http_response_size_bytes` — Histogram (response payload size)

## Hands-On: Add Middleware

Build on Day 5 app:

```go
func metricsMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        
        recorder := &statusRecorder{ResponseWriter: w, statusCode: 200}
        next.ServeHTTP(recorder, r)
        
        duration := time.Since(start).Seconds()
        status := fmt.Sprintf("%d", recorder.statusCode)
        
        requestsTotal.WithLabelValues(r.Method, r.URL.Path, status).Inc()
        requestDuration.WithLabelValues(r.Method, r.URL.Path).Observe(duration)
    })
}

func main() {
    mux := http.NewServeMux()
    mux.HandleFunc("/hello", handleHello)
    mux.Handle("/metrics", promhttp.Handler())
    
    handler := metricsMiddleware(mux)
    http.ListenAndServe(":8000", handler)
}
```

## Key Concepts

**Label Cardinality:** High cardinality (too many unique label values) can break Prometheus:

```go
// BAD: Path could have 1000s of unique values (IDs)
requestsTotal.WithLabelValues(r.Method, r.URL.Path).Inc()
// ✗ /api/users/1, /api/users/2, /api/users/3, ...

// GOOD: Normalize path patterns
path := normalizePath(r.URL.Path)  // /api/users/{id}
requestsTotal.WithLabelValues(r.Method, path).Inc()
```

**High cardinality is a common cause of Prometheus performance issues.**

## Reference

**HTTP Metrics Best Practices:**
- Always include `method` (GET, POST, etc.)
- Always include `status` (200, 400, 500, etc.)
- Normalize `path` to avoid high cardinality
- Use histograms for timing

**Label naming:**
- Use lowercase, underscores
- Keep values low-cardinality (< 100 unique per label)

## Lab

See [lab-6-middleware.md](../../labs/module-2-instrumentation/lab-6-middleware.md)

## Exit Criteria

- [ ] Understand middleware pattern
- [ ] Know how to capture response status
- [ ] Can record request duration with labels
- [ ] Understand label cardinality issues
