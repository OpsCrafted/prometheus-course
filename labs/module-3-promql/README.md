# Module 3: PromQL — Labs

Labs for Days 9–16. Run queries at http://localhost:9090.

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

Solutions: [solutions/](solutions/)

Verify Prometheus is running: `curl -s http://localhost:9090/api/v1/query?query=up | jq '.status'`
