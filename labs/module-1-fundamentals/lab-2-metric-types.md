# Lab 2: Identifying Metric Types

**Time:** 20-30 minutes  
**Goal:** Practice identifying metric types from Prometheus data

## Background

Different metrics serve different purposes. Counters track totals, gauges track current values.

## Lab: Categorize Metrics

Below are 8 metrics from Node Exporter. For each, write:
1. Metric type (gauge, counter, histogram, summary)
2. Why (your reasoning)

**Metrics to categorize:**

1. `node_memory_MemFree_bytes` — Free memory in bytes
   - Type: ?
   - Why: ?

2. `node_cpu_seconds_total` — Total CPU seconds used
   - Type: ?
   - Why: ?

3. `node_disk_reads_completed_total` — Total disk reads
   - Type: ?
   - Why: ?

4. `node_filesystem_avail_bytes` — Available filesystem space
   - Type: ?
   - Why: ?

5. `node_network_receive_bytes_total` — Total bytes received
   - Type: ?
   - Why: ?

6. `node_load1` — 1-minute load average
   - Type: ?
   - Why: ?

7. `node_boot_time_seconds` — Time of last boot (epoch)
   - Type: ?
   - Why: ?

8. `node_uptime_seconds` — Seconds since boot
   - Type: ?
   - Why: ?

## Solution

See `labs/module-1-fundamentals/solutions/lab-2-solution.md`

## Tips

- `_total` in name → usually counter
- Can go down → gauge
- Static value → gauge
- Bytes/seconds increasing → counter

## Exit Criteria

- [ ] Categorized all 8 metrics
- [ ] Can explain reasoning for each
