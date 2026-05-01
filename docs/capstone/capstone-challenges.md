# Prometheus Capstone Challenges

**Time:** 3-4 hours total | **Prerequisites:** All modules completed

## Overview

Three challenge sets that integrate multiple modules:

1. Setup Challenge — Configure and instrument a complete system
2. Monitoring Challenge — Build dashboards and alerts
3. Troubleshooting Challenge — Diagnose and fix production issues

## Challenge Set 1: Complete System Setup

Scenario: You're building monitoring for a 3-tier microservice architecture.

Components:
- API server (Go app with metrics)
- Database (needs monitoring)
- Cache (Redis-like)

Tasks:
1. Create 3 Go apps, each with Prometheus instrumentation
2. Add 3 jobs to prometheus.yml
3. Define metrics on each app:
   - http_requests_total (counter with status)
   - http_request_duration_seconds (histogram)
   - app_connected_clients (gauge)
4. Verify all metrics appear in Prometheus UI
5. Write 5 queries to analyze the system:
   - Total requests per second
   - p95 latency per service
   - Service health (UP/DOWN)
   - Error rate by service
   - Client connections by service

Estimated time: 60-75 minutes

## Challenge Set 2: Dashboard & Alerts

Scenario: Create a monitoring dashboard and alert rules.

Tasks:
1. Create Grafana dashboard with:
   - Request rate gauge
   - p95 latency time-series
   - Error rate graph
   - Target UP/DOWN status
   - Request volume heatmap
2. Create 4 alert rules:
   - Alert: Any target is DOWN
   - Alert: Error rate > 5%
   - Alert: p95 latency > 100ms
   - Alert: Request rate dropped by 50% (potential outage)
3. Test alerts with synthetic traffic

Estimated time: 75-90 minutes

## Challenge Set 3: Troubleshooting

Scenario: A production system has degraded performance.

Given:
- Prometheus data from degrading system
- Pre-written PromQL queries
- System logs (simulated)

Tasks:
1. Identify what metric indicates the problem
2. Root cause: Is it latency, error rate, traffic, or database?
3. Correlate metrics to find cause
4. Recommend fix
5. Verify fix works (in simulation)

Estimated time: 60-75 minutes

## Evaluation Criteria

Challenge 1:
- [ ] All 3 apps running with metrics
- [ ] All 9 metrics defined (3 per app)
- [ ] All targets UP in Prometheus
- [ ] All 5 queries work correctly
- [ ] Results make sense

Challenge 2:
- [ ] Dashboard has 5 panels
- [ ] All 4 alert rules created
- [ ] Rules correctly aggregate metrics
- [ ] Can trigger at least 1 alert
- [ ] Dashboard displays correctly

Challenge 3:
- [ ] Identified problem metric
- [ ] Root cause analysis complete
- [ ] Metrics correlated correctly
- [ ] Fix verified with query
- [ ] Documentation clear

## Next Steps

After completing challenges:
- Deploy to production-like environment
- Build runbooks for alerts
- Create SLOs based on metrics
- Set up on-call rotation
