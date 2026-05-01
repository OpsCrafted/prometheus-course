# Setup & Configuration Reference

## prometheus.yml Structure

```
global:
  scrape_interval: 15s        # Default interval
  evaluation_interval: 15s    # Alert eval interval
  scrape_timeout: 10s         # Per-target timeout
  external_labels:            # Add to all metrics
    environment: production

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels:               # Custom labels
          region: us-east
  
  - job_name: 'myapp'
    scrape_interval: 30s      # Override global
    metrics_path: '/metrics'  # Custom path
    scheme: 'http'            # http or https
    static_configs:
      - targets:
        - 'localhost:8000'
        - 'localhost:8001'

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']

rule_files:
  - 'alerts.yml'
  - 'rules.yml'
```

## Global Options

- `scrape_interval` — Default scrape frequency (15s)
- `evaluation_interval` — Alert rule frequency (15s)
- `scrape_timeout` — Max time to wait per scrape (10s)
- `external_labels` — Add to all metrics

## Scrape Config Options

- `job_name` — Name of job (becomes `job` label)
- `static_configs` — Hard-coded targets
- `targets` — List of `host:port` to scrape
- `labels` — Custom labels to add
- `scrape_interval` — Override global
- `metrics_path` — Path to metrics (default `/metrics`)
- `scheme` — HTTP or HTTPS (default `http`)
- `params` — Query parameters
- `basic_auth` — Username/password
- `bearer_token` — Bearer token for auth

## Common Patterns

### Basic Single Job

```
scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['localhost:8000']
```

### Multiple Targets

```
scrape_configs:
  - job_name: 'my-cluster'
    static_configs:
      - targets:
        - 'node1:8000'
        - 'node2:8000'
        - 'node3:8000'
```

### With Custom Labels

```
scrape_configs:
  - job_name: 'multi-region'
    static_configs:
      - targets: ['us-east-app:8000']
        labels:
          region: us-east
      - targets: ['eu-west-app:8000']
        labels:
          region: eu-west
```

### HTTPS with Auth

```
scrape_configs:
  - job_name: 'secure-api'
    scheme: https
    basic_auth:
      username: 'user'
      password: 'pass'
    static_configs:
      - targets: ['api.example.com:443']
```

### High Frequency Scraping

```
scrape_configs:
  - job_name: 'high-freq'
    scrape_interval: 5s
    scrape_timeout: 3s
    static_configs:
      - targets: ['localhost:8000']
```

## Reloading Configuration

Reload without restart:

```bash
curl -X POST http://localhost:9090/-/reload
```

Or send SIGHUP:

```bash
kill -SIGHUP <prometheus-pid>
```

## File Locations

- Config: `/etc/prometheus/prometheus.yml`
- Data: `/var/lib/prometheus/`
- Rules: `/etc/prometheus/rules/`
- Logs: stdout (or `/var/log/prometheus.log`)

## Docker Compose Setup

```yaml
version: '3'
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"

volumes:
  prometheus_data:
```

Start: `docker-compose up -d`

## Retention

Default retention: 15 days

Configure:

```bash
prometheus --storage.tsdb.retention.time=30d
```

Or in config:

```yaml
global:
  external_labels:
    __retention: 30d
```
