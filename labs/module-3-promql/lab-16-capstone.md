# Lab 16: PromQL Capstone Challenges

**Time:** 40-50 minutes  
**Goal:** Solve real-world queries

## Challenge 1: Health Check

**Scenario:** Verify all targets are UP.

**Write a query that:**
1. Shows targets that are DOWN (up=0)
2. Count how many are UP
3. Create alert condition: "Alert if any target DOWN"

**Solution queries:**
```
up == 0                    # Targets DOWN
count(up == 1)             # Count UP targets
count(up) - count(up == 1) # Count DOWN targets
```

## Challenge 2: Request Rate Analysis

**Scenario:** Your app is slow. Analyze request rates.

**Write queries that show:**
1. Total requests per second (all endpoints)
2. Requests per second by endpoint
3. Success rate (200 responses)
4. Error rate (5XX responses)

**Solution:**
```
rate(http_requests_total[5m])                                    # Total/sec
sum(rate(http_requests_total[5m])) by (endpoint)                # By endpoint
rate(http_requests_total{status="200"}[5m]) /
  rate(http_requests_total[5m])                                  # Success %
rate(http_requests_total{status=~"5.."}[5m]) /
  rate(http_requests_total[5m])                                  # Error %
```

## Challenge 3: SLA Monitoring

**Scenario:** You want SLO: "99% of requests faster than 100ms"

**Write query that shows:**
1. 99th percentile latency
2. Percentage meeting SLO
3. Alert if p99 > 100ms

**Solution:**
```
histogram_quantile(0.99, http_request_duration_seconds_bucket)   # p99
histogram_quantile(0.99, http_request_duration_seconds_bucket) <= 0.1  # SLO met
```

## Challenge 4: Capacity Planning

**Scenario:** How much are resources growing?

**Write queries that show:**
1. Current request rate
2. Request rate 1 week ago
3. Growth rate (%)
4. Projected requests if trend continues

**Solution:**
```
rate(http_requests_total[5m])                                    # Now
rate(http_requests_total[5m] offset 7d)                          # 1 week ago
(rate(http_requests_total[5m]) /
 (rate(http_requests_total[5m] offset 7d) + 0.001)) - 1          # Growth %
```

## Challenge 5: Multi-metric Analysis

**Scenario:** Correlate latency with traffic.

**Write query that shows:**
1. Average latency
2. Request rate
3. Requests per latency unit (requests that should be fast)
4. Alert if latency grows faster than traffic

**Solution:**
```
http_request_duration_seconds_sum /
http_request_duration_seconds_count                              # Avg latency
rate(http_requests_total[5m])                                    # Req/sec
(rate(http_requests_total[5m])) /
((http_request_duration_seconds_sum /
  http_request_duration_seconds_count) + 0.001)                  # Req/sec/latency
```

## Exit Criteria

- [ ] Solved Challenge 1 (health check)
- [ ] Solved Challenge 2 (request analysis)
- [ ] Solved Challenge 3 (SLA monitoring)
- [ ] Solved Challenge 4 (capacity planning)
- [ ] Solved Challenge 5 (multi-metric)
- [ ] Understand each query completely
