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
    
    // Simulate some work
    time.Sleep(time.Duration(50) * time.Millisecond)

    // Record metrics
    requestsTotal.WithLabelValues(r.Method, "/hello").Inc()
    requestDuration.WithLabelValues(r.Method, "/hello").Observe(time.Since(start).Seconds())

    w.WriteHeader(http.StatusOK)
    w.Write([]byte("Hello, World!"))
}
