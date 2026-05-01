# Day 7: Custom Metrics & Gauges

**Time:** 90 minutes | **Prerequisites:** Days 5-6 completed

## Learning Outcomes

- [ ] Create custom gauges for application state
- [ ] Track business metrics (users, orders, etc.)
- [ ] Update gauges periodically

## Conceptual Explainer

Gauges are useful for non-cumulative measurements:
- Current queue length
- Active users
- Cache hit rate
- Free memory
- Order count (if you also track total)

### Creating Gauges

```go
var activeUsers = prometheus.NewGauge(
    prometheus.GaugeOpts{
        Name: "app_active_users",
        Help: "Number of active users",
    },
)

func init() {
    prometheus.MustRegister(activeUsers)
}
```

### Updating Gauges

```go
activeUsers.Set(42)        // Set exact value
activeUsers.Inc()          // Increment by 1
activeUsers.Dec()          // Decrement by 1
activeUsers.Add(5)         // Add value
activeUsers.Sub(3)         // Subtract value
```

### Gauge Vectors (with labels)

```go
queueLength := prometheus.NewGaugeVec(
    prometheus.GaugeOpts{
        Name: "task_queue_length",
        Help: "Length of task queue",
    },
    []string{"queue_name"},
)

queueLength.WithLabelValues("emails").Set(15)
queueLength.WithLabelValues("payments").Set(3)
```

## Hands-On: Track Application State

Add gauges to track:

```go
var (
    activeConnections = prometheus.NewGauge(
        prometheus.GaugeOpts{
            Name: "app_active_connections",
            Help: "Number of active connections",
        },
    )
    
    queueLength = prometheus.NewGauge(
        prometheus.GaugeOpts{
            Name: "app_queue_length",
            Help: "Current task queue length",
        },
    )
)

func init() {
    prometheus.MustRegister(activeConnections)
    prometheus.MustRegister(queueLength)
}

// Update in background goroutine
go func() {
    for {
        activeConnections.Set(float64(countConnections()))
        queueLength.Set(float64(getQueueLength()))
        time.Sleep(5 * time.Second)
    }
}()
```

## Key Concepts

**When to use Gauge vs Counter:**
- Gauge: Current state (how many NOW)
- Counter: Cumulative (how many TOTAL since boot)

**Periodic updates:** Use goroutines with tickers

```go
ticker := time.NewTicker(10 * time.Second)
go func() {
    for range ticker.C {
        gauge.Set(getCurrentValue())
    }
}()
```

## Reference

**Gauge Methods:**
- `Set(value)` — Set exact value
- `Inc()` — Add 1
- `Dec()` — Subtract 1
- `Add(v)` — Add value
- `Sub(v)` — Subtract value

**Common Gauge Metrics:**
- `app_database_connections_open`
- `app_cache_size_bytes`
- `app_queue_length`
- `app_active_users`

## Lab

See [lab-7-gauges.md](../../labs/module-2-instrumentation/lab-7-gauges.md)

## Exit Criteria

- [ ] Know when to use gauges vs counters
- [ ] Can create and update gauges
- [ ] Understand gauge vectors with labels
- [ ] Can update gauges periodically
