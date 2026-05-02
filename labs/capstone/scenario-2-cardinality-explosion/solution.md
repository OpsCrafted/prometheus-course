# Solution: Memory Explosion from Cardinality

## Root Cause

High-cardinality labels (request_id, trace_id) were added to metrics after deployment:

```
http_request_duration_seconds{method="GET", path="/api/users", request_id="abc123", trace_id="xyz789"}
```

Problems:
1. Each unique request_id creates a separate time series
2. With 2M requests/day, you get 2M+ unique time series per metric
3. More time series = more memory, slower queries, slower ingestion
4. These labels are unbounded (infinite unique values possible)

**Rule of thumb:** If a label can have >100 unique values, it's high-cardinality and should be dropped.

## Solution: Drop High-Cardinality Labels

Add relabel_configs to the sample-app job to drop request_id and trace_id before ingestion:

```yaml
scrape_configs:
  - job_name: 'sample-app'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['sample-app:8080']
        labels:
          group: 'application'
    relabel_configs:
      # Drop request_id and trace_id labels
      - source_labels: [__name__]
        regex: '.*request_id.*|.*trace_id.*'
        action: drop
      # Alternative: drop specific label names
      - action: labeldrop
        regex: '(request_id|trace_id)'
```

How it works:
- `action: labeldrop` removes specified labels before storage
- `regex: '(request_id|trace_id)'` matches both labels
- Any metric with these labels has them stripped away
- The metric is stored without high-cardinality labels

## Verification

1. **Immediate effect after config reload:**
   - New metrics no longer have request_id/trace_id labels
   - Old high-cardinality series remain (cardinality doesn't drop instantly)

2. **Check Prometheus cardinality:**
   ```promql
   # Query the TSDB cardinality endpoint
   curl http://localhost:9090/api/v1/label/__name__/values
   ```
   - Before: Returns 5M unique __name__+label combinations
   - After: Returns ~50K series (returns to normal)

3. **Memory should stabilize:**
   - Memory usage drops from 3.2GB back to ~400MB
   - Prometheus becomes responsive again
   - Scrape duration returns to normal

4. **Check for the labels in metrics:**
   ```
   # Query the metrics page
   curl http://localhost:9090/metrics
   
   # Should NOT see request_id or trace_id in label sets
   ```

## Why This Works

Prometheus metrics should only have bounded labels (low cardinality):
- `method` (GET, POST, PUT, DELETE) - 4 values
- `path` (/api/users, /api/posts, etc.) - ~50 values
- `status` (200, 404, 500, etc.) - ~20 values
- `instance` (host1, host2) - number of servers

High-cardinality labels like request_id:
- Should never be metric labels
- Belong in logs (where cardinality is expected)
- Use structured logging + Loki for this data
- Use traces for distributed request tracking (Jaeger, Tempo)

## Key Learning

**Cardinality explosion is the #1 way to destroy Prometheus:**
1. Keep label cardinality under control (<100 values per label ideally)
2. Drop unbounded labels: request_id, user_id, session_id, ip_address, etc.
3. Use relabel_configs to enforce this at scrape time
4. Monitor label cardinality regularly (use Prometheus' cardinality API)
5. Store request-level data in logs/traces, not metrics

## Prevention

- Code review: Check new metrics for high-cardinality labels
- Alert on cardinality growth: `increase(prometheus_tsdb_symbol_table_size_bytes[1h]) > threshold`
- Document label cardinality requirements
- Use metric relabeling to enforce low cardinality

## Alternative Approaches

1. **Drop at application level** (best):
   ```python
   # Don't export request_id as a label
   # Keep method, path, status instead
   histogram = Counter('http_requests_total', 
                       'HTTP requests', 
                       ['method', 'path', 'status'])  # Not request_id!
   ```

2. **Sample high-cardinality metrics** (partial fix):
   - Keep only 10% of samples
   - Better than dropping, but less accurate

3. **Use metrics_relabeling** (complex):
   - Apply relabeling rules before storage
   - More flexible but harder to manage
