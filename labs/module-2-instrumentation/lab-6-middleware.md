# Lab 6: HTTP Metrics Middleware

**Time:** 30-40 minutes  
**Goal:** Add middleware to track request metrics

## Lab: Enhance app.go with Middleware

Modify `labs/module-2-instrumentation/app.go` to add HTTP metrics middleware.

**Step 1:** Update metric definitions

Replace counters with vectors that include status:

```go
var (
    requestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total HTTP requests",
        },
        []string{"method", "path", "status"},  // Add status
    )
    // ... rest of metrics
)
```

**Step 2:** Create middleware function

```go
type statusRecorder struct {
    http.ResponseWriter
    statusCode int
}

func (r *statusRecorder) WriteHeader(code int) {
    r.statusCode = code
    r.ResponseWriter.WriteHeader(code)
}

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
```

**Step 3:** Update main() to use middleware

```go
func main() {
    mux := http.NewServeMux()
    mux.HandleFunc("/hello", handleHello)
    mux.Handle("/metrics", promhttp.Handler())
    
    handler := metricsMiddleware(mux)
    
    fmt.Println("Starting server on :8000")
    http.ListenAndServe(":8000", handler)
}
```

**Step 4:** Test

```bash
go run app.go
```

**Step 5:** Generate traffic

```bash
for i in {1..5}; do curl http://localhost:8000/hello; done
```

**Step 6:** Check metrics

```bash
curl http://localhost:8000/metrics | grep http_requests_total
```

Should show:
```
http_requests_total{method="GET",path="/hello",status="200"} 5
```

## Solution

See `labs/module-2-instrumentation/solutions/app-middleware-solution.go`

## Exit Criteria

- [ ] Updated metrics to include status
- [ ] Created statusRecorder
- [ ] Middleware wraps handler
- [ ] Status codes recorded in metrics
- [ ] app runs and metrics update
