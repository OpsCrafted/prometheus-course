# Golden Signals Lab: Slow Checkout Investigation

## Scenario

Your e-commerce checkout service has become dramatically slower over the past 30 minutes. Customers are complaining and your on-call alert fired. Here is what you know:

- **p95 latency** has jumped from 100ms to 1500ms (15x slower)
- **Traffic** appears normal
- **Error rate** appears normal
- No recent deployments

Your job is to use the **4 Golden Signals** to investigate, confirm your observations, and pinpoint the root cause.

---

## The 4 Golden Signals

The 4 Golden Signals are the most important metrics to monitor for any user-facing service. They were popularized by Google's Site Reliability Engineering (SRE) book.

1. **Latency** — The time it takes to service a request. Distinguish between the latency of successful requests and the latency of failed requests. A slow error is worse than a fast error.

2. **Traffic** — A measure of how much demand is being placed on your system. For a web service this is typically HTTP requests per second. High traffic can cause slowdowns, but normal traffic during a slowdown points elsewhere.

3. **Errors** — The rate of requests that fail, either explicitly (HTTP 500), implicitly (returning wrong data), or by policy (any request slower than 1s counts as an error). A spike here narrows your search significantly.

4. **Saturation** — How "full" your service is. A measure of your system's fraction of its capacity: CPU, memory, disk I/O, network, database connection pool. Saturation often predicts impending problems before they become user-visible.

---

## Guided Investigation

Work through each signal in order. Write a PromQL query, run it, and record your finding before moving on.

### Q1: Is latency up?

Confirm the latency problem is real and quantify it.

- **Metric to use:** `http_request_duration_seconds_bucket`
- **Hint:** Use `histogram_quantile` to compute p95 latency across all checkout requests.

```
histogram_quantile(0.95, ...)
```

**What to look for:** Is p95 above your 200ms SLO? By how much?

---

### Q2: Is traffic normal?

Rule out a traffic surge as the cause.

- **Metric to use:** `http_requests_total` with label `endpoint="/api/checkout"`
- **Hint:** Use `rate(...)` over a 5-minute window to get requests per second.

```
rate(http_requests_total{...}[5m])
```

**What to look for:** Is req/s significantly higher than baseline (~10 req/s)?

---

### Q3: Are errors up?

Rule out a wave of new errors masking a deeper problem.

- **Metric to use:** `http_requests_total` filtered by `status=~"5.."`
- **Hint:** Divide the rate of 5xx responses by the rate of all responses, then multiply by 100.

```
(sum(rate({status=~"5.."}[5m])) / sum(rate(...[5m]))) * 100
```

**What to look for:** Is error rate above 1%? A normal error rate with high latency suggests a saturation problem.

---

### Q4: What is saturated?

Since latency is up but traffic and errors are normal, something is saturated. Check each resource.

- **CPU:** `rate(node_cpu_seconds_total{mode!="idle"}[5m])`
- **Memory:** `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes`
- **Disk I/O:** `rate(node_disk_read_bytes_total[5m])`
- **DB connections:** `pg_stat_activity_count` or `mysql_global_status_threads_connected`
- **Hint:** Look for anything that has spiked while other metrics stayed flat.

**What to look for:** One of these will stand out. A disk I/O spike on a database host is a classic culprit.

---

## Your Turn

### Load the incident data

The incident metrics snapshot is stored in:

```
labs/capstone/golden-signals-lab/incidents/slow-checkout.json
```

Review the key metrics in that file before writing your queries. They represent the state of the system at peak incident time.

### Write your queries

Open Prometheus or a PromQL sandbox and write one query per signal. For each query, record:

1. The PromQL expression you used
2. The value returned
3. Whether that signal is the cause (yes / no / maybe)

### Compare with the solution

Once you have answered all 4 questions, check your work against:

```
labs/capstone/golden-signals-lab/solution/queries.md
```

---

## What You Will Learn

- How to apply the 4 Golden Signals framework to a real incident in a structured order
- Why starting with traffic and errors helps you rule out obvious causes quickly
- How `histogram_quantile` reveals latency distributions that averages hide
- How disk I/O saturation at the database layer manifests as application-level latency
- The difference between a symptom (slow checkout) and a root cause (database disk bottleneck)
- How to read a PromQL query and map it back to a specific signal question
