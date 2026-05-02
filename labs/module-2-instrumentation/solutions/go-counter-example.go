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

func handleOrders(w http.ResponseWriter, r *http.Request) {
	apiRequestsTotal.WithLabelValues(r.Method, "/api/orders", "200").Inc()
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"orders": []}`))
}

func main() {
	http.HandleFunc("/api/users", handleUsers)
	http.HandleFunc("/api/orders", handleOrders)
	http.Handle("/metrics", promhttp.Handler())

	fmt.Println("Counter example running on :8080 - visit http://localhost:8080/metrics")
	http.ListenAndServe(":8080", nil)
}
