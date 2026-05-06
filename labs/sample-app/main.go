package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

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

func init() {
	prometheus.MustRegister(httpRequestsTotal)
	prometheus.MustRegister(activeConnections)
	prometheus.MustRegister(httpRequestDurationSeconds)
	prometheus.MustRegister(httpRequestSizeBytes)
	prometheus.MustRegister(httpResponseSizeBytes)
}

// statusRecorder wraps http.ResponseWriter to capture the HTTP status code and bytes written
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

// instrumentedHandler wraps an HTTP handler with Prometheus instrumentation
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
	// Create a new mux instead of using DefaultServeMux
	mux := http.NewServeMux()

	// Register instrumented handlers
	mux.HandleFunc("/", instrumentedHandler("/", handleRoot))
	mux.HandleFunc("/slow", instrumentedHandler("/slow", handleSlow))
	mux.HandleFunc("/error", instrumentedHandler("/error", handleError))

	// Register metrics endpoint
	mux.Handle("/metrics", promhttp.Handler())

	port := ":8080"
	log.Printf("Starting server on %s...", port)
	log.Printf("Visit http://localhost:8080 for Hello message")
	log.Printf("Visit http://localhost:8080/metrics for Prometheus metrics")

	// Create HTTP server with timeouts
	srv := &http.Server{
		Addr:         port,
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

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
