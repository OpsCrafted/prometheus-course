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

## Real-World Examples

### Example 1: Counter — Track API Requests by Method, Endpoint, and Status

Counters only go up. Use them for totals: requests, errors, bytes sent.

```go
// labs/module-2-instrumentation/solutions/go-counter-example.go
package main

import (
    "fmt"
    "net/http"

    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var apiRequestsTotal = prometheus.NewCounterVec(
    prometheus.CounterOpts{
        Name: "api_requests_total",
        Help: "Total number of API requests by method, endpoint, and status.",
    },
    []string{"method", "endpoint", "status"},
)

func init() {
    prometheus.MustRegister(apiRequestsTotal)
}

func handleUsers(w http.ResponseWriter, r *http.Request) {
    apiRequestsTotal.WithLabelValues(r.Method, "/api/users", "200").Inc()
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"users": []}`))
}

func main() {
    http.HandleFunc("/api/users", handleUsers)
    http.Handle("/metrics", promhttp.Handler())

    fmt.Println("Counter example running on :8080 - visit http://localhost:8080/metrics")
    http.ListenAndServe(":8080", nil)
}
```

**What you will see in `/metrics`:**
```
api_requests_total{endpoint="/api/users",method="GET",status="200"} 5
```

**Key points:**
- `NewCounterVec` adds label dimensions: method, endpoint, status
- `.WithLabelValues(...)` selects the specific label combination to increment
- Use `_total` suffix by convention for counters

---

### Example 2: Gauge — Track Active Connections

Gauges go up and down. Use them for current state: connections, queue depth, memory usage.

```go
// labs/module-2-instrumentation/solutions/go-gauge-example.go
package main

import (
    "fmt"
    "net/http"
    "time"

    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var activeConnections = prometheus.NewGauge(
    prometheus.GaugeOpts{
        Name: "active_connections",
        Help: "Number of currently active connections.",
    },
)

func init() {
    prometheus.MustRegister(activeConnections)
}

func handleConnect(w http.ResponseWriter, r *http.Request) {
    activeConnections.Inc()
    fmt.Println("Connection opened - active connections incremented")

    time.Sleep(5 * time.Second) // simulate connection lifetime

    activeConnections.Dec()
    fmt.Println("Connection closed - active connections decremented")

    w.WriteHeader(http.StatusOK)
    w.Write([]byte("Connection complete"))
}

func main() {
    http.HandleFunc("/connect", handleConnect)
    http.Handle("/metrics", promhttp.Handler())

    fmt.Println("Gauge example running on :8080 - visit http://localhost:8080/metrics")
    http.ListenAndServe(":8080", nil)
}
```

**What you will see in `/metrics`** (while a request is in-flight):
```
active_connections 3
```

**Key points:**
- `.Inc()` on connection open, `.Dec()` on connection close
- `.Set(n)` is also available when you know the exact current value
- Gauge has no `_total` suffix — it represents a current value, not a cumulative total

---

### Example 3: Histogram — Measure Request Duration

Histograms record the distribution of values. Use them for latency, payload sizes.

```go
// labs/module-2-instrumentation/solutions/go-histogram-example.go
package main

import (
    "fmt"
    "math/rand"
    "net/http"
    "time"

    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var requestDuration = prometheus.NewHistogram(
    prometheus.HistogramOpts{
        Name:    "request_duration_seconds",
        Help:    "Duration of HTTP requests in seconds.",
        Buckets: []float64{.001, .005, .01, .05, .1, .5, 1, 2},
    },
)

func init() {
    prometheus.MustRegister(requestDuration)
}

func handleWork(w http.ResponseWriter, r *http.Request) {
    start := time.Now()

    // Simulate variable latency between 50ms and 150ms
    latency := time.Duration(50+rand.Intn(100)) * time.Millisecond
    time.Sleep(latency)

    requestDuration.Observe(time.Since(start).Seconds())

    w.WriteHeader(http.StatusOK)
    w.Write([]byte(fmt.Sprintf("Done in %s", latency)))
}

func main() {
    http.HandleFunc("/work", handleWork)
    http.Handle("/metrics", promhttp.Handler())

    fmt.Println("Histogram example running on :8080 - visit http://localhost:8080/metrics")
    http.ListenAndServe(":8080", nil)
}
```

**What you will see in `/metrics`:**
```
request_duration_seconds_bucket{le="0.001"} 0
request_duration_seconds_bucket{le="0.1"} 0
request_duration_seconds_bucket{le="0.5"} 12
request_duration_seconds_bucket{le="+Inf"} 12
request_duration_seconds_sum 0.924
request_duration_seconds_count 12
```

**Key points:**
- `Buckets` define the `le` (less-than-or-equal) boundaries
- `.Observe(seconds)` records one measurement
- Prometheus calculates percentiles from bucket data: `histogram_quantile(0.95, rate(...))`
- Buckets here cover 1ms–2s; since latency is 50–150ms, most observations land in `le="0.5"`

---

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
