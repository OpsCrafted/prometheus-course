# Broken Lab - Solution

## Bug 1: Wrong Port (node-exporter)

**Location:** Line 9
```yaml
- targets: ['localhost:9999']  # WRONG: 9999 doesn't exist
```

**Fix:**
```yaml
- targets: ['localhost:9100']  # CORRECT: node-exporter runs on 9100
```

**Why:** Node Exporter listens on :9100 by default. Prometheus can't connect to :9999.

---

## Bug 2: Missing Colon in Hostname (prometheus)

**Location:** Line 16
```yaml
- targets: ['localhost9090']  # WRONG: No colon between host and port
```

**Fix:**
```yaml
- targets: ['localhost:9090']  # CORRECT: host:port format
```

**Why:** Targets must be in `host:port` format. Missing colon breaks parsing.

---

## Bug 3: Typo in Relabel Action (postgres-exporter)

**Location:** Line 24
```yaml
action: 'kep'  # WRONG: Typo
```

**Fix:**
```yaml
action: 'keep'  # CORRECT: Valid action is 'keep'
```

**Why:** Invalid relabel action. Valid actions: keep, drop, replace, hashmod, labelmap, etc.

---

## Bug 4: Empty Targets Config (redis-exporter)

**Location:** Line 31-32
```yaml
- targets: ['redis-exporter:9121']
- {}  # WRONG: Empty config
```

**Fix:**
```yaml
- targets: ['redis-exporter:9121']
```

**Why:** Each static_configs entry must have `targets` field. Empty {} is invalid.

---

## Bug 5: Indentation Error in Relabel Configs (alertmanager)

**Location:** Line 40-41
```yaml
metric_relabel_configs:
- source_labels: [__name__]  # WRONG: Only 1 space indent
```

**Fix:**
```yaml
metric_relabel_configs:
  - source_labels: [__name__]  # CORRECT: 2 space indent
    regex: 'alertmanager_.*'
    action: 'keep'
```

**Why:** YAML indentation matters. List items need 2 spaces under parent key.

---

## Debugging Tools Used

1. **promtool check config** — Validates syntax
2. **Docker logs** — Shows scrape errors
3. **Prometheus /config endpoint** — View active config
4. **Prometheus /targets endpoint** — See which targets UP/DOWN

These are the same tools on-call engineers use daily.
