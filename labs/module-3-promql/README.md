# Module 3: PromQL — Labs

Labs for Days 9–19. Run queries at http://localhost:9090.

| Lab | File | What you build |
|-----|------|----------------|
| Lab 9 | [lab-9-instant-queries.md](lab-9-instant-queries.md) | Instant and range vector queries, label selectors, time ranges |
| Lab 10 | [lab-10-aggregation.md](lab-10-aggregation.md) | sum(), avg(), topk(), count() with by/without clauses |
| Lab 11 | [lab-11-rate-increase.md](lab-11-rate-increase.md) | rate() and increase() on counters, choosing window sizes |
| Lab 12 | [lab-12-joins.md](lab-12-joins.md) | Binary operators, sum()-before-divide pattern, ratios and percentages |
| Lab 13 | [lab-13-functions.md](lab-13-functions.md) | Mathematical functions, offset, derivatives |
| Lab 14 | [lab-14-histograms.md](lab-14-histograms.md) | histogram_quantile(), p50/p95/p99 latency analysis |
| Lab 15 | [lab-15-slos-burn-rates.md](lab-15-slos-burn-rates.md) | SLI queries, error budget, burn rate, multi-window alert, Grafana SLO panel |
| Lab 16 | [lab-16-capstone.md](lab-16-capstone.md) | Multi-step real-world queries: SLA monitoring, capacity planning |
| Lab 17 | [lab-17-production-readiness.md](lab-17-production-readiness.md) | 5 essential alerts, Golden Signals dashboard, production readiness checklist |
| Lab 18 | [lab-18-recording-rules.md](lab-18-recording-rules.md) | Recording rules, pre-aggregated metrics, dashboard panel replacement |
| Lab 19 | [lab-19-alertmanager.md](lab-19-alertmanager.md) | Alertmanager routing, inhibition, silences |

Solutions: [solutions/](solutions/)

Verify Prometheus is running: `curl -s http://localhost:9090/api/v1/query?query=up | jq '.status'`
