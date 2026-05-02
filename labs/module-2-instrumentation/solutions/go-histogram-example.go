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
