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
        []string{"method", "path", "status"},
    )

    requestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "http_request_duration_seconds",
            Help: "HTTP request duration",
            Buckets: []float64{0.005, 0.01, 0.025, 0.05, 0.1, 0.5, 1.0},
        },
        []string{"method", "path"},
    )

    activeConnections = prometheus.NewGauge(
        prometheus.GaugeOpts{
            Name: "app_active_connections",
            Help: "Number of active HTTP connections",
        },
    )

    queueLength = prometheus.NewGauge(
        prometheus.GaugeOpts{
            Name: "app_queue_length",
            Help: "Current length of task queue",
        },
    )
)

func init() {
    prometheus.MustRegister(requestsTotal)
    prometheus.MustRegister(requestDuration)
    prometheus.MustRegister(activeConnections)
    prometheus.MustRegister(queueLength)
}

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
        activeConnections.Inc()
        defer activeConnections.Dec()
        
        start := time.Now()
        recorder := &statusRecorder{ResponseWriter: w, statusCode: 200}
        next.ServeHTTP(recorder, r)
        
        duration := time.Since(start).Seconds()
        status := fmt.Sprintf("%d", recorder.statusCode)
        
        requestsTotal.WithLabelValues(r.Method, r.URL.Path, status).Inc()
        requestDuration.WithLabelValues(r.Method, r.URL.Path).Observe(duration)
    })
}

func simulateQueueLength() int {
    return int(time.Now().Unix() % 11)
}

func main() {
    mux := http.NewServeMux()
    mux.HandleFunc("/hello", handleHello)
    mux.Handle("/metrics", promhttp.Handler())
    
    handler := metricsMiddleware(mux)
    
    go func() {
        ticker := time.NewTicker(5 * time.Second)
        defer ticker.Stop()
        for range ticker.C {
            queueLength.Set(float64(simulateQueueLength()))
        }
    }()
    
    fmt.Println("Starting server on :8000")
    http.ListenAndServe(":8000", handler)
}

func handleHello(w http.ResponseWriter, r *http.Request) {
    time.Sleep(time.Duration(50) * time.Millisecond)
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("Hello, World!"))
}
