# Lab 18: Recording Rules

**Time:** 25 minutes
**Goal:** Wire recording rules into the running stack, verify pre-computed metrics appear, and update a dashboard panel to use them.

## Background

Your `labs/alert_rules.yml` is already mounted in Prometheus. Adding a new group to that file is all you need — no docker-compose changes required.

After this lab, `make verify-day-18` should pass.

---

## Exercise 1: Add Recording Rules

Open `labs/alert_rules.yml`. Add this group at the end of the file (inside the top-level `groups:` list):

```yaml
  - name: recordings
    interval: 30s
    rules:
      - record: job:http_requests:rate5m
        expr: sum(rate(http_requests_total[5m])) by (job)

      - record: job:http_request_duration_seconds_bucket:rate5m
        expr: sum(rate(http_request_duration_seconds_bucket[5m])) by (job, le)

      - record: job:http_error_ratio:rate5m
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) by (job)
          /
          sum(rate(http_requests_total[5m])) by (job)
```

Reload Prometheus to pick up the new rules:

```bash
cd labs && docker compose exec prometheus kill -HUP 1
```

Wait 30 seconds for the first evaluation interval to pass.

---

## Exercise 2: Verify

**Check the rules loaded:**

```bash
curl -s http://localhost:9090/api/v1/rules \
  | jq '[.data.groups[].rules[] | select(.type == "recording")] | length'
```

Expected: `3`

**Check the recorded metric exists:**

```bash
curl -s 'http://localhost:9090/api/v1/query?query=job:http_requests:rate5m' \
  | jq '.data.result | length'
```

Expected: `1` or more.

**Run the verify target:**

```bash
make verify-day-18
```

Expected: all checks pass.

---

## Exercise 3: Update a Dashboard Panel

Open Grafana at http://localhost:3000. Find the Golden Signals dashboard you built in Lab 17 (or create a new panel).

Update the **Traffic** panel query from:

```promql
sum(rate(http_requests_total[5m]))
```

To:

```promql
sum(job:http_requests:rate5m)
```

Save the panel. Confirm the graph looks identical — same shape, same values. The recorded metric and the raw query produce the same result; you have eliminated the raw computation from the dashboard.

---

## Exercise 4: P99 Latency Panel

Update the **P99 Latency** panel from:

```promql
histogram_quantile(0.99,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)
```

To:

```promql
histogram_quantile(0.99, sum(job:http_request_duration_seconds_bucket:rate5m) by (le))
```

**Question:** Why does `histogram_quantile()` still appear in the panel query even though we have a recording rule?

*(Answer in solution.)*

---

## Solution

See `labs/module-3-promql/solutions/lab-18-solution.md`

## Exit Criteria

- [ ] `curl` for recording rule count returns `3`
- [ ] `job:http_requests:rate5m` appears in Prometheus UI
- [ ] `make verify-day-18` passes
- [ ] Traffic panel updated to use recorded metric (graph unchanged)
- [ ] Can answer Exercise 4 question
