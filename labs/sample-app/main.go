package main

import (
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// Counter: total HTTP requests with method and endpoint labels
	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "endpoint"},
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

	// Mutex for concurrent connection tracking
	connMutex sync.Mutex
)

func init() {
	// Register all metrics
	prometheus.MustRegister(httpRequestsTotal)
	prometheus.MustRegister(activeConnections)
	prometheus.MustRegister(httpRequestDurationSeconds)
}

// instrumentedHandler wraps an HTTP handler with Prometheus instrumentation
func instrumentedHandler(endpoint string, handler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Increment active connections
		connMutex.Lock()
		activeConnections.Inc()
		connMutex.Unlock()
		defer func() {
			connMutex.Lock()
			activeConnections.Dec()
			connMutex.Unlock()
		}()

		// Record request metrics
		start := time.Now()
		defer func() {
			duration := time.Since(start).Seconds()
			httpRequestsTotal.WithLabelValues(r.Method, endpoint).Inc()
			httpRequestDurationSeconds.WithLabelValues(endpoint).Observe(duration)
		}()

		// Call the actual handler
		handler(w, r)
	}
}

// handleRoot returns "Hello, Prometheus!"
func handleRoot(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprint(w, "Hello, Prometheus!")
}

// handleSlow returns 200 after 1-2 seconds
func handleSlow(w http.ResponseWriter, r *http.Request) {
	time.Sleep(time.Duration(1000+time.Now().UnixNano()%1000) * time.Millisecond)
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprint(w, "Slow response completed!")
}

// handleError returns 500 error
func handleError(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusInternalServerError)
	fmt.Fprint(w, "Internal Server Error")
}

func main() {
	// Register instrumented handlers
	http.HandleFunc("/", instrumentedHandler("/", handleRoot))
	http.HandleFunc("/slow", instrumentedHandler("/slow", handleSlow))
	http.HandleFunc("/error", instrumentedHandler("/error", handleError))

	// Register metrics endpoint
	http.Handle("/metrics", promhttp.Handler())

	port := ":8080"
	log.Printf("Starting server on port 8080...")
	log.Printf("Visit http://localhost:8080 for Hello message")
	log.Printf("Visit http://localhost:8080/metrics for Prometheus metrics")

	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
