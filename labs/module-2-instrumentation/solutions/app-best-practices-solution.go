package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// Counter: total HTTP requests with method and endpoint labels
	// Good naming convention: {subsystem}_{feature}_{unit}
	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests by method and endpoint",
		},
		[]string{"method", "endpoint", "status"},
	)

	// Gauge: current active HTTP connections
	// Avoids cardinality explosion by not including user/IP labels
	activeConnections = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "http_active_connections",
			Help: "Current number of active HTTP connections",
		},
	)

	// Histogram: HTTP request duration in seconds
	// Includes endpoint label for request latency analysis by endpoint
	// Labels limited to controlled values (endpoint names)
	httpRequestDurationSeconds = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request latency in seconds by endpoint",
			Buckets: []float64{0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0},
		},
		[]string{"endpoint"},
	)

	// Counter: task queue depth for business metrics
	taskQueueEnqueued = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "task_queue_enqueued_total",
			Help: "Total tasks enqueued in task queue",
		},
		[]string{"queue_name"},
	)

	// Gauge: current task queue length
	// Updated periodically (not per-event) to avoid performance impact
	taskQueueLength = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Name: "task_queue_length",
			Help: "Current length of task queue",
		},
		[]string{"queue_name"},
	)

	// Gauge: application version metadata (constant labels)
	// Using a gauge with value 1 for version tracking
	appVersion = prometheus.NewGaugeVec(
		prometheus.GaugeOpts{
			Name: "app_version",
			Help: "Application version information",
		},
		[]string{"version", "build"},
	)
)

func init() {
	// Register all metrics in init() - good practice for validation
	prometheus.MustRegister(httpRequestsTotal)
	prometheus.MustRegister(activeConnections)
	prometheus.MustRegister(httpRequestDurationSeconds)
	prometheus.MustRegister(taskQueueEnqueued)
	prometheus.MustRegister(taskQueueLength)
	prometheus.MustRegister(appVersion)

	// Set version info - constant value of 1
	appVersion.WithLabelValues("1.0.0", "abc123def").Set(1)
}

// statusRecorder captures HTTP status code
type statusRecorder struct {
	http.ResponseWriter
	statusCode int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.statusCode = code
	r.ResponseWriter.WriteHeader(code)
}

// instrumentedHandler wraps an HTTP handler with proper Prometheus instrumentation
// Following best practices for request tracking
func instrumentedHandler(endpoint string, handler http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Track active connections
		activeConnections.Inc()
		defer activeConnections.Dec()

		// Record request metrics with proper status code
		start := time.Now()
		recorder := &statusRecorder{ResponseWriter: w, statusCode: 200}

		// Use defer for guaranteed metric recording even if handler panics
		defer func() {
			duration := time.Since(start).Seconds()
			statusCode := strconv.Itoa(recorder.statusCode)

			// Record with limited, controlled label values
			// Avoid cardinality explosion by not including user ID, IP, or other high-variance data
			httpRequestsTotal.WithLabelValues(r.Method, endpoint, statusCode).Inc()
			httpRequestDurationSeconds.WithLabelValues(endpoint).Observe(duration)
		}()

		handler(recorder, r)
	}
}

// handleRoot returns a greeting
func handleRoot(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprint(w, "Hello, Prometheus! This is the best practices example.\n")
}

// handleHello processes GET requests to /hello
func handleHello(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		fmt.Fprint(w, "Method not allowed")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, `{"message":"Hello, World!","version":"1.0.0"}`)
}

// handleSlow returns a slow response for latency analysis
func handleSlow(w http.ResponseWriter, r *http.Request) {
	// Simulate variable latency between 0.5 and 2 seconds
	delay := time.Duration(500+time.Now().UnixNano()%1500) * time.Millisecond
	time.Sleep(delay)

	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprint(w, "Slow response completed!")
}

// handleError returns a 500 error for error rate monitoring
func handleError(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusInternalServerError)
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprint(w, "Internal Server Error")
}

// handleHealth returns app health status
func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, `{"status":"healthy","uptime":"N/A"}`)
}

// normalizeEndpoint converts request path to a metric label
// Avoids high cardinality by grouping similar paths
func normalizeEndpoint(path string) string {
	// Remove trailing slashes for consistency
	path = strings.TrimSuffix(path, "/")
	if path == "" {
		return "/"
	}

	// For paths like /user/123, normalize to /user/:id
	parts := strings.Split(path, "/")
	for i, part := range parts {
		// Simple heuristic: if it looks like a number, replace with :id
		if _, err := strconv.ParseInt(part, 10, 64); err == nil {
			parts[i] = ":id"
		}
	}

	return strings.Join(parts, "/")
}

// simulateQueueMetrics simulates queue depth for demonstration
func simulateQueueMetrics() {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	queueNum := 0
	for range ticker.C {
		// Simulate queue length changing over time (not per-request, but on timer)
		queueLength := 5 + (queueNum % 20)
		taskQueueLength.WithLabelValues("default").Set(float64(queueLength))
		taskQueueEnqueued.WithLabelValues("default").Add(float64(queueNum % 3))
		queueNum++
	}
}

func main() {
	// Create a new mux instead of using DefaultServeMux
	mux := http.NewServeMux()

	// Register instrumented handlers with normalized endpoint names
	mux.HandleFunc("/", instrumentedHandler("/", handleRoot))
	mux.HandleFunc("/hello", instrumentedHandler("/hello", handleHello))
	mux.HandleFunc("/slow", instrumentedHandler("/slow", handleSlow))
	mux.HandleFunc("/error", instrumentedHandler("/error", handleError))
	mux.HandleFunc("/health", instrumentedHandler("/health", handleHealth))

	// Register metrics endpoint (no instrumentation - to avoid infinite loops)
	mux.Handle("/metrics", promhttp.Handler())

	port := ":8080"
	log.Printf("Starting server on %s...", port)
	log.Printf("Visit http://localhost:8080 for greeting")
	log.Printf("Visit http://localhost:8080/metrics for Prometheus metrics")

	// Create HTTP server with timeouts (good for production)
	srv := &http.Server{
		Addr:         port,
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start queue simulation in background (updates gauge periodically, not per-event)
	go simulateQueueMetrics()

	// Channel to listen for shutdown signals
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGTERM, syscall.SIGINT)

	// Start server in a goroutine
	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Wait for shutdown signal
	<-sigChan
	log.Println("Shutdown signal received, gracefully shutting down...")

	// Create a context with timeout for graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Gracefully shutdown the server
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited")
}
