# Day 5: Go Instrumentation Basics

**Time:** 90 minutes | **Prerequisites:** Module 1 completed

## Learning Outcomes

- [ ] Know Prometheus Go client library (prom/client_golang)
- [ ] Instrument a simple Go app with metrics
- [ ] Expose metrics on `/metrics` endpoint
- [ ] Register and update metrics

## Conceptual Explainer

The Prometheus Go client (`github.com/prometheus/client_golang`) provides:
- Counter, Gauge, Histogram, Summary types
- HTTP handler for `/metrics` endpoint
- Registration and collection of metrics

### Basic Setup

```go
import "github.com/prometheus/client_golang/prometheus"

// Create a counter
var requestsTotal = prometheus.NewCounter(prometheus.CounterOpts{
    Name: "http_requests_total",
    Help: "Total HTTP requests",
})

// Register it
func init() {
    prometheus.MustRegister(requestsTotal)
}
```

### Using Metrics

```go
// Increment counter
requestsTotal.Inc()

// Set gauge
memUsage.Set(1024.5)

// Observe histogram
requestDuration.Observe(0.125)
```

### Expose Metrics

```go
import "github.com/prometheus/client_golang/prometheus/promhttp"

func main() {
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":8000", nil)
}
```

This exposes metrics in Prometheus text format on `http://localhost:8000/metrics`.

## Hands-On: Instrument a Simple App

**File: labs/module-2-instrumentation/app.go**

```go
package main

import (
    "fmt"
    "net/http"
    "time"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    requestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total HTTP requests",
        },
        []string{"method", "path"},
    )

    requestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "http_request_duration_seconds",
            Help: "HTTP request duration",
            Buckets: []float64{0.005, 0.01, 0.025, 0.05, 0.1, 0.5, 1.0},
        },
        []string{"method", "path"},
    )
)

func init() {
    prometheus.MustRegister(requestsTotal)
    prometheus.MustRegister(requestDuration)
}

func main() {
    http.HandleFunc("/hello", handleHello)
    http.Handle("/metrics", promhttp.Handler())

    fmt.Println("Starting server on :8000")
    http.ListenAndServe(":8000", nil)
}

func handleHello(w http.ResponseWriter, r *http.Request) {
    start := time.Now()
    
    // Simulate work
    time.Sleep(time.Duration(50) * time.Millisecond)

    // Record metrics
    requestsTotal.WithLabelValues(r.Method, "/hello").Inc()
    requestDuration.WithLabelValues(r.Method, "/hello").Observe(time.Since(start).Seconds())

    w.WriteHeader(http.StatusOK)
    w.Write([]byte("Hello, World!"))
}
```

## Key Concepts

**Metric Vectors:** Use `NewCounterVec` / `NewGaugeVec` / etc. for metrics with labels.

```go
requests := prometheus.NewCounterVec(
    prometheus.CounterOpts{Name: "requests", Help: "..."},
    []string{"method", "status"},  // label names
)

// Use with labels
requests.WithLabelValues("GET", "200").Inc()
```

**Buckets (Histogram):** Define ranges for distribution:
```go
Buckets: []float64{0.005, 0.01, 0.025, 0.05, 0.1, 0.5, 1.0},
// Creates buckets: <=0.005s, <=0.01s, ..., <=+Inf
```

## Reference

**Prometheus Go Client Docs:**
- Counter: Track cumulative totals
- Gauge: Track current values
- Histogram: Track distributions (latency, size)
- Summary: Pre-computed quantiles (rare)

**Installation:**
```bash
go get github.com/prometheus/client_golang
```

**Naming conventions:**
- Use `_total` for counters
- Use `_seconds`, `_bytes` for units
- Prefix with subsystem: `http_`, `db_`

## Lab

See [lab-5-go-app.md](../../labs/module-2-instrumentation/lab-5-go-app.md)

## Exit Criteria

- [ ] Understand Go client library
- [ ] Know how to create and register metrics
- [ ] Can expose metrics endpoint
- [ ] Understand metric vectors with labels
