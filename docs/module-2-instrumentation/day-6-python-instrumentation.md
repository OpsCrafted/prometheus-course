# Day 6: Python Instrumentation

**Time:** 90 minutes | **Prerequisites:** Day 5 completed

## Learning Outcomes

- [ ] Know the prometheus-client Python library and its four metric types
- [ ] Instrument a Flask app with Counter, Gauge, and Histogram metrics
- [ ] Expose metrics on a dedicated port using `start_http_server`
- [ ] Apply label dimensions to metrics with `labels()`

## Conceptual Explainer

The `prometheus-client` library is the official Python client for Prometheus. It provides four metric types — Counter, Gauge, Histogram, and Summary — and a built-in HTTP server to expose them.

Metrics are module-level objects. You create them once at import time, then update them inside your request handlers or background threads. The library handles thread safety and the Prometheus text format automatically.

`start_http_server(port)` launches a lightweight HTTP server on a separate port (typically 8000) that serves `/metrics`. This keeps instrumentation traffic separate from your application traffic on port 5000.

Labels are added by passing a list of label names at construction time and calling `.labels(key=value)` when recording a measurement. This mirrors the Go client pattern: define label names upfront, select label values at call time.

Unlike the Go client, there is no explicit registration step. Metrics register themselves with the default registry on construction.

**Install:**
```bash
pip install prometheus-client flask
```

## Hands-On: Flask Example

A minimal Flask app that counts every request and measures its duration:

```python
import time
from prometheus_client import Counter, Histogram, start_http_server
from flask import Flask, request

app = Flask(__name__)

http_requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests.',
    ['method', 'path']
)

http_request_duration_seconds = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds.',
    ['method', 'path']
)


@app.before_request
def start_timer():
    request._start_time = time.time()


@app.after_request
def record_metrics(response):
    duration = time.time() - request._start_time
    http_requests_total.labels(method=request.method, path=request.path).inc()
    http_request_duration_seconds.labels(method=request.method, path=request.path).observe(duration)
    return response


@app.route('/hello')
def hello():
    return 'Hello, World!', 200


if __name__ == '__main__':
    start_http_server(8000)
    print('Metrics: http://localhost:8000/metrics')
    app.run(port=5000)
```

**What this does:**
- `before_request` stamps the start time onto the request object
- `after_request` computes elapsed time and increments both metrics for every route automatically
- Prometheus scrapes `http://localhost:8000/metrics` on its own schedule

**What you will see in `/metrics`:**
```
http_requests_total{method="GET",path="/hello"} 4
http_request_duration_seconds_bucket{le="0.005",method="GET",path="/hello"} 3
http_request_duration_seconds_count{method="GET",path="/hello"} 4
http_request_duration_seconds_sum{method="GET",path="/hello"} 0.012
```

## Real-World Examples

Three standalone examples are in `labs/module-2-instrumentation/solutions/`:

### Example 1: Counter — Track API Requests by Method, Endpoint, and Status

**File: `python-counter-example.py`**

Counters only go up. Use them for totals: requests, errors, bytes sent.

```python
from prometheus_client import Counter, start_http_server
from flask import Flask

app = Flask(__name__)

api_requests_total = Counter(
    'api_requests_total',
    'Total number of API requests by method, endpoint, and status.',
    ['method', 'endpoint', 'status']
)


@app.route('/api/users', methods=['GET'])
def get_users():
    api_requests_total.labels(method='GET', endpoint='/api/users', status='200').inc()
    return {'users': []}, 200


@app.route('/api/users', methods=['POST'])
def create_user():
    api_requests_total.labels(method='POST', endpoint='/api/users', status='201').inc()
    return {'created': True}, 201


if __name__ == '__main__':
    start_http_server(8000)
    print('Metrics server running on http://localhost:8000/metrics')
    print('Flask app running on http://localhost:5000')
    app.run(port=5000)
```

**What you will see in `/metrics`:**
```
api_requests_total{endpoint="/api/users",method="GET",status="200"} 5
api_requests_total{endpoint="/api/users",method="POST",status="201"} 2
```

**Key points:**
- Pass label names as a list at construction: `['method', 'endpoint', 'status']`
- Select label values at call time: `.labels(method='GET', ...)`
- Use `_total` suffix by convention for counters
- Each unique combination of label values is a separate time series

---

### Example 2: Gauge — Track Database Pool and Queue Depth

**File: `python-gauge-example.py`**

Gauges go up and down. Use them for current state: pool size, queue depth, memory usage.

```python
import random
import threading
import time

from prometheus_client import Gauge, start_http_server
from flask import Flask

app = Flask(__name__)

db_pool_size = Gauge('db_pool_size', 'Current number of connections in the database pool.')
queue_depth = Gauge('queue_depth', 'Current number of items waiting in the processing queue.')


def update_gauges():
    while True:
        db_pool_size.set(random.randint(5, 20))
        queue_depth.set(random.randint(0, 100))
        time.sleep(5)


@app.route('/health')
def health():
    return {'status': 'ok'}, 200


if __name__ == '__main__':
    start_http_server(8000)
    print('Metrics server running on http://localhost:8000/metrics')
    print('Flask app running on http://localhost:5000')
    t = threading.Thread(target=update_gauges, daemon=True)
    t.start()
    app.run(port=5000)
```

**What you will see in `/metrics`:**
```
db_pool_size 12.0
queue_depth 47.0
```

**Key points:**
- `.set(n)` replaces the current value — use when you know the exact state
- `.inc()` and `.dec()` are also available for relative changes
- `daemon=True` ensures the thread exits when the main process exits
- No `_total` suffix — a gauge represents a current value, not a cumulative total

---

### Example 3: Histogram — Measure Request Latency

**File: `python-histogram-example.py`**

Histograms record the distribution of values. Use them for latency, payload sizes.

```python
import random
import time

from prometheus_client import Histogram, start_http_server
from flask import Flask

app = Flask(__name__)

request_duration_seconds = Histogram(
    'request_duration_seconds',
    'Duration of HTTP requests in seconds.',
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0]
)


@app.route('/api/slow')
def slow():
    start = time.time()
    sleep_ms = random.randint(10, 500)
    time.sleep(sleep_ms / 1000.0)
    duration = time.time() - start
    request_duration_seconds.observe(duration)
    return {'latency_ms': sleep_ms}, 200


if __name__ == '__main__':
    start_http_server(8000)
    print('Metrics server running on http://localhost:8000/metrics')
    print('Flask app running on http://localhost:5000')
    app.run(port=5000)
```

**What you will see in `/metrics`:**
```
request_duration_seconds_bucket{le="0.01"} 1
request_duration_seconds_bucket{le="0.1"} 4
request_duration_seconds_bucket{le="0.5"} 11
request_duration_seconds_bucket{le="+Inf"} 12
request_duration_seconds_sum 2.847
request_duration_seconds_count 12
```

**Key points:**
- `buckets` defines the `le` (less-than-or-equal) boundaries
- `.observe(seconds)` records one measurement
- Use `histogram_quantile(0.95, rate(request_duration_seconds_bucket[5m]))` in PromQL for p95
- Since latency is 10–500ms, observations spread across the 0.01–0.5 buckets

---

## Key Concepts

**Label dimensions:** Define label names at construction, supply values when recording.

```python
counter = Counter('requests_total', 'help', ['method', 'status'])
counter.labels(method='GET', status='200').inc()
```

**Buckets (Histogram):** Define ranges that cover your expected latency spread.

```python
Histogram('latency_seconds', 'help', buckets=[0.005, 0.01, 0.05, 0.1, 0.5, 1.0])
```

**Two-port pattern:** `start_http_server(8000)` for Prometheus scraping, `app.run(port=5000)` for application traffic. This is the standard pattern in Python services.

## Reference

**prometheus-client docs:** https://github.com/prometheus/client_python

**Metric naming conventions:**
- Use `_total` suffix for Counters
- Use `_seconds`, `_bytes` for units
- Prefix with subsystem: `http_`, `db_`, `queue_`

**Installation:**
```bash
pip install prometheus-client flask
```

## Lab

See `labs/module-2-instrumentation/solutions/` for the three runnable examples.

## Exit Criteria

- [ ] Understand prometheus-client metric types and when to use each
- [ ] Know how to create labeled metrics and update them in Flask routes
- [ ] Can run `start_http_server` alongside a Flask app
- [ ] Can read Histogram bucket output and write a `histogram_quantile` query
