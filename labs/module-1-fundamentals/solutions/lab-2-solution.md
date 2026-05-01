# Lab 2 Solution: Metric Types

1. `node_memory_MemFree_bytes` — **Gauge**
   - Reason: Memory varies up and down over time

2. `node_cpu_seconds_total` — **Counter**
   - Reason: `_total` suffix + only increases

3. `node_disk_reads_completed_total` — **Counter**
   - Reason: `_total` suffix + cumulative count

4. `node_filesystem_avail_bytes` — **Gauge**
   - Reason: Available space changes as files are added/deleted

5. `node_network_receive_bytes_total` — **Counter**
   - Reason: `_total` suffix + only increases (total bytes received since boot)

6. `node_load1` — **Gauge**
   - Reason: Load average varies over time (no `_total`)

7. `node_boot_time_seconds` — **Gauge**
   - Reason: Static value (epoch timestamp of last boot)

8. `node_uptime_seconds` — **Gauge** or **Counter**
   - Reason: Increases over time but resets on boot (could be either, but typically gauge in Prometheus)
