# Day 16: PromQL Capstone & Review

**Time:** 90 minutes | **Prerequisites:** Days 9-15 completed

## Learning Outcomes

- [ ] Combine multiple PromQL concepts
- [ ] Write production-ready queries
- [ ] Optimize query performance

## Review: PromQL Concepts

**Instant vectors:** Current value
```
up
http_requests_total
```

**Aggregation:** Combine series
```
sum(metric) by (label)
count(metric)
```

**Rate calculation:** Per-second rate
```
rate(counter[5m])
increase(counter[5m])
```

**Joins:** Combine multiple metrics
```
metric1 / metric2
```

**Functions:** Transform metrics
```
round(metric)
rate(metric[5m]) offset 1h
```

**Histograms:** Percentiles
```
histogram_quantile(0.95, metric_bucket)
```

## Capstone Challenges

See [lab-16-capstone.md](../../labs/module-3-promql/lab-16-capstone.md)

## Query Optimization

**Performance tips:**
- Use specific labels to reduce cardinality
- Choose appropriate time ranges
- Avoid high-cardinality joins
- Use recording rules for complex queries

**Example:**
```
# ❌ SLOW: Aggregates all series
sum(metric)

# ✓ FAST: Filters first
sum(metric{job="myapp"})
```

## Exit Criteria

- [ ] Can write multi-step queries
- [ ] Know query optimization techniques
- [ ] Completed capstone challenges
- [ ] Ready for alerts & dashboards

## Next: Alerts & Dashboards (advanced modules)
