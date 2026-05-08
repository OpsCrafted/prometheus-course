# Service Discovery Reference

This course uses `static_configs` throughout — you define targets as a fixed list in `prometheus.yml`. That works for small, stable environments. Production systems use **service discovery** so Prometheus finds targets automatically as they appear and disappear.

---

## Why Static Configs Stop Working

With 10 services, static configs are fine. With 50, you're editing YAML constantly. With Kubernetes, pods come and go in seconds — there's no way to keep a static list current.

Service discovery lets Prometheus ask an external system "what targets exist right now?" on each scrape cycle.

---

## Common SD Mechanisms

### Kubernetes (`kubernetes_sd_configs`)

The most common in production. Prometheus queries the Kubernetes API server for pods, services, or endpoints.

```yaml
scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      # Only scrape pods with annotation prometheus.io/scrape: "true"
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: "true"
      # Use the pod's declared port
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        target_label: __address__
        regex: (.+)
        replacement: "${__meta_kubernetes_pod_ip}:${1}"
```

### Consul (`consul_sd_configs`)

Discovers services registered in a Consul catalog.

```yaml
scrape_configs:
  - job_name: 'consul-services'
    consul_sd_configs:
      - server: 'consul:8500'
        services: ['web', 'api', 'worker']
    relabel_configs:
      - source_labels: [__meta_consul_service]
        target_label: job
```

### EC2 (`ec2_sd_configs`)

Discovers AWS EC2 instances by tag.

```yaml
scrape_configs:
  - job_name: 'ec2'
    ec2_sd_configs:
      - region: us-east-1
        port: 9100
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Role]
        action: keep
        regex: monitoring
```

### File-based (`file_sd_configs`)

A middle ground: Prometheus reads a JSON/YAML file that another system writes. Useful when you have a custom inventory system.

```yaml
scrape_configs:
  - job_name: 'file-discovered'
    file_sd_configs:
      - files:
          - '/etc/prometheus/targets/*.json'
        refresh_interval: 30s
```

The file contains:
```json
[
  {"targets": ["host1:9100", "host2:9100"], "labels": {"env": "prod"}}
]
```

---

## Relabeling

Service discovery exposes metadata as `__meta_*` labels. These are dropped after scraping unless you keep them via `relabel_configs`. The patterns above show the most common relabeling operations:

| Action | What it does |
|--------|-------------|
| `keep` | Only scrape targets where label matches regex |
| `drop` | Exclude targets where label matches regex |
| `replace` | Copy/transform one label into another |
| `labelmap` | Rename labels matching a pattern |

---

## Static Configs vs Service Discovery: When to Switch

| Situation | Use |
|-----------|-----|
| ≤ 20 stable services | `static_configs` — simpler, no moving parts |
| Services in Kubernetes | `kubernetes_sd_configs` |
| Services in Consul/Nomad | `consul_sd_configs` |
| AWS EC2 fleet | `ec2_sd_configs` |
| Custom inventory system | `file_sd_configs` |

The concepts in this course (scrape configs, relabeling, targets, jobs) apply directly to service discovery — you're just replacing the static list with a dynamic source.

---

## Further Reading

- [Prometheus service discovery docs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
- [Relabeling reference](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)
