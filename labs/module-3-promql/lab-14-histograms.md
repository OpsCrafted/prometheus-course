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

**Query 5:** p95 by method
```
histogram_quantile(0.95,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le, method))
```
Result: p95 per HTTP method

**Query 6:** Multiple quantiles
```
histogram_quantile(0.99,
  rate(http_request_duration_seconds_bucket[5m]))
```
Result: 99th percentile over 5 minutes

## Expected Results

- Quantiles return latency values in seconds
- p50 < p95 < p99
- Must include "le" label in aggregation
- Rate histograms smooth over time window

## Solution

See `labs/module-3-promql/solutions/lab-14-solution.md`

## Exit Criteria

- [ ] Understand histogram buckets
- [ ] Can calculate p50, p95, p99
- [ ] Understand quantile aggregation
- [ ] Know when to use rate with histograms
