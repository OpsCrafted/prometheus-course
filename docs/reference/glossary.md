# Prometheus Glossary

## Alert Rule
A PromQL query with threshold that triggers when condition is met.

Example: `up == 0 for 5m` alerts when target is down for 5 minutes.

## Bucket (Histogram)
A range in a histogram. Example: "0.005" means "≤ 5ms".

Buckets collect observations: "How many requests completed in ≤ 5ms?"

## Cardinality
Number of unique time-series. High cardinality = many series = performance issues.

Example: Adding user_id label creates millions of series (high cardinality).

## Counter
Metric type: Cumulative total that only increases.

Example: `http_requests_total` increases every request.

## Evaluation Interval
How often Prometheus evaluates alert rules. Default: 15 seconds.

## Gauge
Metric type: Current value that can go up or down.

Example: `node_memory_MemFree_bytes` varies as system uses memory.

## Histogram
Metric type: Distribution of observations in buckets.

Example: `http_request_duration_seconds` with buckets at 0.005, 0.01, 0.025, ... seconds.

## Instance
Individual target being scraped. Label: `instance="host:port"`

## Job
Group of targets with same purpose. Label: `job="myjob"`

Example: All Redis instances might have `job="redis"`.

## Label
Dimension added to metrics for filtering and grouping.

Example: `http_requests_total{method="GET", status="200"}`

Labels are: method and status.

## Label Matching
When combining metrics, labels must match for join to work.

Example: metric1{x="a"} can combine with metric2{x="a"} but not metric2{x="b"}.

## Metric
Named measurement with labels.

Example: `http_requests_total{method="GET", status="200"} = 1234`

## Quantile
Percentile value. Example: p95 means 95% of values are below this.

Also called percentile.

## Rate
Per-second rate of change. Calculated from counter.

Example: `rate(requests_total[5m])` = requests per second over last 5 minutes.

## Recording Rule
Pre-computed query stored as new metric for performance.

Example: Store `instance:memory_usage_percent:rate5m` instead of computing every time.

## Scrape
Fetch `/metrics` from target and store in TSDB.

Happens on scrape_interval (default 15s).

## Scrape Config
Configuration in prometheus.yml defining targets to scrape.

Includes job name, targets, labels, interval.

## Scrape Interval
How often Prometheus scrapes targets. Default: 15 seconds.

Can override per-job.

## Series
Time-series of data points with same labels.

Example: `up{job="prom"} = 1,1,1,0,1,1,...` (values over time)

## Summary
Metric type: Like histogram but with pre-computed quantiles.

Rarely used. Histogram is usually better.

## Target
Individual endpoint exposing `/metrics`.

Example: `localhost:9090` is a target.

## TSDB (Time-Series Database)
Prometheus's internal database storing all metrics over time.

Stores metric name + labels + timestamp + value.

## Vector
Set of time-series (instant vector) or range of data (range vector).

Instant: Current value per series.
Range: Values over time window.
