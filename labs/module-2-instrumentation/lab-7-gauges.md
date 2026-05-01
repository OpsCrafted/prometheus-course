# Lab 7: Custom Gauges

**Time:** 30-40 minutes  
**Goal:** Add gauges to track application state

## Lab: Track Custom Metrics

Add gauges to app.go to track:
1. Active connections
2. Task queue length

**Step 1:** Define gauges

```go
var (
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
```

**Step 2:** Register gauges

```go
func init() {
    prometheus.MustRegister(requestsTotal)
    prometheus.MustRegister(requestDuration)
    prometheus.MustRegister(activeConnections)
    prometheus.MustRegister(queueLength)
}
```

**Step 3:** Update gauges in middleware

```go
func metricsMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        activeConnections.Inc()  // Increment on request
        defer activeConnections.Dec()  // Decrement when done
        
        // ... rest of middleware ...
    })
}
```

**Step 4:** Update queue gauge periodically

```go
func main() {
    // ... setup ...
    
    // Background goroutine to update queue length
    go func() {
        ticker := time.NewTicker(5 * time.Second)
        defer ticker.Stop()
        for range ticker.C {
            queueLength.Set(float64(simulateQueueLength()))
        }
    }()
    
    // ... listen ...
}

func simulateQueueLength() int {
    // Return a value between 0-10
    return int(time.Now().Unix() % 11)
}
```

**Step 5:** Test

```bash
go run app.go
```

**Step 6:** Check gauges

```bash
curl http://localhost:8000/metrics | grep app_
```

Should show:
```
app_active_connections 0  (or 1 if request in flight)
app_queue_length 5
```

## Solution

See `labs/module-2-instrumentation/solutions/app-gauges-solution.go`

## Exit Criteria

- [ ] Created activeConnections gauge
- [ ] Created queueLength gauge
- [ ] Gauges update correctly
- [ ] Metrics visible in /metrics output
