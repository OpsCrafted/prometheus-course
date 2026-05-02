# Solution: Request Latency Spike

## Root Cause

The PromQL query used two mistakes:

1. **Missing `rate()` on histogram** - Used `increase()` instead of `rate()`
   - `increase()` returns raw counter increments
   - `rate()` normalizes to per-second rates, making time windows meaningful
   - Without `rate()`, short windows like `[1m]` show noisy minute-by-minute changes

2. **Too-short time window** - Used `[1m]` instead of `[5m]`
   - 1-minute window = too much noise, misses trends
   - 5-minute window = smooths out single-minute spikes, shows real patterns

## Broken Query
```promql
histogram_quantile(0.95, sum by (le) (increase(http_request_duration_seconds_bucket[1m]))) * 1000
```

This query:
- Uses `increase()` which doesn't normalize for window size
- Uses `[1m]` which is too granular
- Result: Graph is noisy and doesn't clearly show the 14:32:00 spike

## Corrected Query
```promql
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m]))) * 1000
```

This query:
- Uses `rate()` to normalize histogram increments per second
- Uses `[5m]` window to smooth noise while keeping spike visible
- Multiplies by 1000 to convert seconds to milliseconds
- Result: Clean graph showing spike starting at 14:32:00

## How to Verify

1. **In Prometheus UI:**
   - Go to Graph tab
   - Paste the corrected query
   - Set time range to include 14:30:00 - 14:35:00
   - You should see:
     - Baseline at ~95-110ms before 14:32
     - Sharp jump to 1850-2100ms at 14:32:00
     - Sustained high latency through 14:33

2. **Check the metrics directly:**
   ```promql
   http_request_duration_seconds_bucket{le="0.2"}
   ```
   - Before 14:32: Stable increments
   - At 14:32: Sharp increase in bucket counts
   - After 14:32: Continued elevation

## Key Learning

**`rate()` converts cumulative counters into rates:**
- Counters only go up (or reset on restart)
- `rate(counter[5m])` = average per-second increase over 5 minutes
- Without `rate()`, you can't compare different time windows fairly
- Always use `rate()` on counters, never on gauge metrics

**Time window selection matters:**
- Too short (1m): Noisy, hard to see trends
- Too long (30m+): Misses important changes
- Sweet spot: 5m for typical monitoring (balances smoothing vs responsiveness)

## Next Steps

1. Update production Prometheus config to use corrected query
2. Create dashboard panel with correct query
3. Set up alert: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) * 1000 > 500`
4. Review deployment process to catch slow queries before production
