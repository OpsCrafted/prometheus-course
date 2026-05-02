# Lab 14: Histograms & Quantiles

**Time:** 30-35 minutes  
**Goal:** Query histograms and calculate percentiles

## Lab: Calculate Percentiles

Perform these queries (need app running with histograms):

**Query 1:** View histogram buckets
```
http_request_duration_seconds_bucket
```
Result: All buckets with le labels

**Query 2:** Calculate p50 (median)
```
histogram_quantile(0.50, http_request_duration_seconds_bucket)
```
Result: Median latency (0.05 = 50ms)

**Query 3:** Calculate p95
```
histogram_quantile(0.95, http_request_duration_seconds_bucket)
```
Result: 95th percentile latency

**Query 4:** Calculate p99
```
histogram_quantile(0.99, http_request_duration_seconds_bucket)
```
Result: 99th percentile latency

**Query 5:** p95 over 5 minutes (correct aggregation)
```
histogram_quantile(0.95,
  sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```
Result: p95 aggregated across all instances/methods

**Query 6:** p95 per endpoint
```
histogram_quantile(0.95,
  sum by (le, endpoint) (rate(http_request_duration_seconds_bucket[5m])))
```
Result: p95 broken down per endpoint (le always included)

**Query 7:** p99 with proper aggregation
```
histogram_quantile(0.99,
  sum by (le) (rate(http_request_duration_seconds_bucket[5m])))
```
Result: 99th percentile over 5 minutes (aggregated)

## Expected Results

- Quantiles return latency values in seconds (e.g., 0.045 = 45ms)
- p50 < p95 < p99 (percentiles increase monotonically)
- Must include "le" label in aggregation via `sum by (le, ...)`
- Rate histograms smooth over time window
- Without `sum by(le)`, you'll get one result per label combination (wrong)

## Solution

See `labs/module-3-promql/solutions/lab-14-solution.md`

## Exit Criteria

- [ ] Understand histogram buckets and le label
- [ ] Can calculate p50, p95, p99 with correct sum by(le) pattern
- [ ] Understand why sum by(le) aggregation is critical
- [ ] Know when to use rate with histograms
- [ ] Can keep additional dimensions (endpoint, method) in aggregation while preserving le
