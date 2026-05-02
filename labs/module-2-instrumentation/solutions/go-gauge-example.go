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

	// Simulate connection lifetime
	time.Sleep(5 * time.Second)

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
