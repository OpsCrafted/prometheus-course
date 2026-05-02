# Architecture Diagrams

## Diagram 1: Pull Model vs Push Model

### Pull Model

```
+------------------+         scrape /metrics         +-------------------+
|                  | <------------------------------ |                   |
|   Prometheus     |                                 |   Target Service  |
|   Server         |  HTTP GET every scrape_interval |   (app, exporter) |
|                  | ------------------------------> |                   |
+------------------+                                 +-------------------+
        |
        | stores time series
        v
+------------------+
|      TSDB        |
|  (local storage) |
+------------------+
```

Prometheus uses a pull model by default: it reaches out to each target on a
configurable interval and scrapes the `/metrics` endpoint. This design keeps
control centralised — Prometheus decides when and how often to collect data,
which makes it easy to detect when a target has gone silent. It also means
targets do not need to know where Prometheus lives; they simply expose an HTTP
endpoint and wait. The pull approach simplifies firewall rules (outbound from
Prometheus only), makes replay and backfill straightforward, and gives
operators a single configuration file that documents every monitored endpoint.

### Push Model

```
+------------------+    push metrics (UDP/TCP)    +-------------------+
|                  | ---------------------------> |                   |
|   Target Service |                              |   Push Gateway /  |
|   (short-lived   |   POST /metrics/job/name     |   Metrics Store   |
|    batch job)    |                              |                   |
+------------------+                             +-------------------+
                                                          |
                                                          | scraped by
                                                          v
                                                 +-------------------+
                                                 |   Prometheus      |
                                                 |   Server          |
                                                 +-------------------+
```

The push model is used for short-lived jobs (batch jobs, cron tasks) that
finish before Prometheus can scrape them. These jobs push their metrics to the
Pushgateway, which acts as an intermediary store that Prometheus can then
scrape normally. While convenient, the push model introduces a single point of
failure (the gateway), can mask job failures if stale metrics linger, and
requires targets to know the gateway address. It is intentionally limited in
scope within the Prometheus ecosystem — use it only for batch workloads, not
for long-running services.

---

## Diagram 2: Alerting Pipeline

```
+-------------+     evaluate     +----------------+     fire alert     +------------------+
|             |  rule groups     |                | -----------------> |                  |
| Prometheus  | ---------------> |  Alerting      |                    |  Alertmanager    |
|  Server     |  every interval  |  Rules         |  ALERTS metric +   |                  |
|             |                  |  (*.rules.yml) |  HTTP POST         |                  |
+-------------+                  +----------------+                    +------------------+
                                                                               |
                              +------------------------------------------------+
                              |                    |                    |
                              v                    v                    v
                    +--------------+     +------------------+   +------------+
                    |   PagerDuty  |     |   Slack Channel  |   |   Email    |
                    |  (on-call)   |     |   (#alerts)      |   |   (SMTP)   |
                    +--------------+     +------------------+   +------------+
```

The alerting pipeline separates metric evaluation from notification delivery.
Prometheus evaluates alerting rules at a fixed interval and writes results into
a special `ALERTS` time series; when a rule crosses its threshold it sends the
alert to Alertmanager over HTTP. Alertmanager then handles deduplication (so
the same alert from multiple Prometheus servers fires only once), grouping
(batching related alerts into one notification), silencing (suppressing during
maintenance), and routing to the correct receiver. This separation means you
can change notification channels without touching Prometheus, and you can scale
Alertmanager independently of your metrics collection tier.

---

## Diagram 3: Service Discovery

```
+-----------------------------+  +-----------------------------+  +-----------------------------+
|   Option 1: Static Config   |  |  Option 2: File-Based SD    |  |  Option 3: Cloud / Consul   |
|-----------------------------|  |-----------------------------|  |-----------------------------|
|                             |  |                             |  |                             |
|  prometheus.yml             |  |  targets.json (written by   |  |  Consul / AWS EC2 /         |
|  static_configs:            |  |  your own tooling)          |  |  Kubernetes API             |
|    - targets:               |  |                             |  |           |                 |
|        - host1:9090         |  |  [ { "targets":             |  |           | API poll        |
|        - host2:9090         |  |      ["host1:9090"],         |  |           v                 |
|                             |  |      "labels": {...} } ]    |  |  Prometheus SD plugin       |
|  Simple, no dependencies.   |  |                             |  |  auto-discovers targets     |
|  Requires manual updates.   |  |  Prometheus watches file;   |  |  and applies relabeling.    |
|                             |  |  reloads on change.         |  |                             |
+-----------------------------+  +-----------------------------+  +-----------------------------+
             |                                |                                |
             +--------------------------------+--------------------------------+
                                              |
                                              v
                                    +------------------+
                                    |   Prometheus     |
                                    |   scrapes all    |
                                    |   discovered     |
                                    |   targets        |
                                    +------------------+
```

Service discovery solves the problem of targets appearing and disappearing
dynamically. Static configuration works well for small, stable environments but
becomes a maintenance burden as infrastructure scales. File-based service
discovery lets external tooling (Ansible, Terraform, custom scripts) write
target files that Prometheus watches and reloads without a restart. Cloud-native
and orchestration integrations (Kubernetes, Consul, EC2, GCE) let Prometheus
query provider APIs directly, applying relabeling rules to map discovered
metadata — IP addresses, pod labels, service names — into meaningful metric
labels. The relabeling pipeline (`relabel_configs`) is what transforms raw
discovery data into the label set you actually query in PromQL.

---

## Diagram 4: Data Flow

```
+------------------+      /metrics (text)      +------------------+
|                  |  -----------------------> |                  |
|   Exporter       |  HTTP scrape response     |   Prometheus     |
|   (node, app,    |                           |   Scrape Engine  |
|    custom)       |                           |                  |
+------------------+                           +--------+---------+
                                                        |
                                               parse + label inject
                                                        |
                                                        v
                                               +------------------+
                                               |   TSDB           |
                                               |  (chunks on disk)|
                                               |   WAL + compaction|
                                               +--------+---------+
                                                        |
                          +-----------------------------+-----------------------------+
                          |                             |                             |
                          v                             v                             v
               +------------------+        +------------------+         +------------------+
               |  PromQL Query    |        |  Recording Rules |         |  Remote Write    |
               |  (Grafana /      |        |  (pre-aggregate  |         |  (long-term      |
               |   /graph UI)     |        |   heavy queries) |         |   storage)       |
               +------------------+        +------------------+         +------------------+
```

Data flows in one direction: exporters expose metrics in the Prometheus text
format, the scrape engine fetches and parses them, injects job/instance labels,
and writes them to the local TSDB. The TSDB stores data in compressed chunks,
uses a Write-Ahead Log for durability, and runs periodic compaction to merge
blocks and apply retention. From the TSDB, data is accessible via PromQL for
ad-hoc queries and dashboards, via recording rules to pre-compute expensive
aggregations, or via remote write to ship data to long-term storage backends
such as Thanos or Cortex.

**Key Insight:** Every stage is decoupled. Exporters do not know about TSDB
internals; queries do not block ingestion; remote write runs asynchronously.
This decoupling is what lets Prometheus remain operationally simple while
handling millions of time series at high scrape frequency.
