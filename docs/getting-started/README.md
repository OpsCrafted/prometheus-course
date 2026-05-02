# Getting Started with Prometheus

**Time:** 2-3 hours  
**Goal:** Set hands-on context before diving into theory. Get Prometheus running locally, explore the UI, write your first PromQL queries.

## What You'll Do

1. Install Docker (if not already installed)
2. Clone the course repository
3. Start the full monitoring stack via Docker Compose
4. Explore Prometheus UI
5. Write 5 basic PromQL queries
6. Understand what those queries mean

## What is Docker? (Quick Explanation)

Docker is a tool that packages applications and their dependencies into isolated containers. Think of it like a shipping container:
- **Traditional approach:** Install Node.js, Prometheus, databases directly on your machine. Different versions on different machines. Conflicts and chaos.
- **Docker approach:** Package everything (Prometheus + all dependencies) in a container. Same container runs identically on your machine, a colleague's laptop, production servers, etc.

For this course, Docker lets you run Prometheus and other tools without cluttering your machine. When you're done, delete the container — nothing left behind.

## Prerequisites

- Docker + Docker Compose installed (see below for installation)
- ~2 hours free time
- Basic command line familiarity (cd, ls, basic commands)
- A text editor (any will do: VS Code, nano, vim, etc.)
- Terminal/command prompt access

## Step 1: Install Docker

### macOS

1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Click the `.dmg` file to install
3. Drag Docker icon to Applications folder
4. Launch Docker from Applications
5. Enter your password when prompted (Docker needs system-level access)
6. Wait for Docker to finish starting (look for the whale icon in top menu bar)

**Verify installation:**
```bash
docker --version
docker compose version
```

Expected output:
```
Docker version 24.0.x, build ...
Docker Compose version 2.x.x
```

### Linux (Ubuntu/Debian)

```bash
# Install Docker
sudo apt-get update
sudo apt-get install docker.io docker-compose-plugin -y

# Add your user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker compose version
```

### Windows

1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Run the installer
3. Choose "WSL 2 backend" (recommended)
4. Restart your computer when prompted
5. Launch Docker Desktop
6. Wait for Docker to finish starting

**Verify in PowerShell or Git Bash:**
```bash
docker --version
docker compose version
```

## Step 2: Clone the Repository

```bash
# Navigate to a folder where you want to work
cd ~/projects  # or wherever you prefer

# Clone the course
git clone https://github.com/OpsCrafted/prometheus-course.git
cd prometheus-course
```

Expected output:
```
Cloning into 'prometheus-course'...
remote: Enumerating objects...
...
```

Navigate into labs:
```bash
cd labs
ls -la
```

You should see:
- `docker-compose.yml` — Configuration to start the full 11-service monitoring stack
- `prometheus.yml` — Prometheus scrape configuration (6 scrape jobs)
- `alertmanager.yml` — Alertmanager routing configuration
- `blackbox.yml` — Blackbox exporter probe configuration
- `setup.sh` — Helper script

## Step 2b: Using Make Commands (Optional but Recommended)

From the course root directory, you can use the Makefile for quick commands:

```bash
# Start the entire environment
make setup

# Verify all services are running
make verify

# View logs for debugging
make logs-prometheus
make logs-grafana
make logs-app

# Stop everything
make down

# Full cleanup (removes data volumes)
make clean
```

If you prefer direct Docker commands, proceed to Step 3 below.

## Step 3: Start the Monitoring Stack

```bash
# From inside labs/ directory
docker compose up -d
```

Expected output:
```
[+] Running 11/11
 - Container labs-prometheus-1         Started
 - Container labs-grafana-1            Started
 - Container labs-alertmanager-1       Started
 - Container labs-node-exporter-1      Started
 - Container labs-blackbox-exporter-1  Started
 - Container labs-sample-app-1         Started
 - Container labs-load-generator-1     Started
 - Container labs-postgres-1           Started
 - Container labs-postgres-exporter-1  Started
 - Container labs-redis-1              Started
 - Container labs-redis-exporter-1     Started
```

`-d` means "detached" (runs in background). If you want to see logs, use `docker compose up` without `-d` (Ctrl+C to stop).

**Verify containers are running:**
```bash
docker compose ps
```

Expected output:
```
NAME                          COMMAND                   STATE           PORTS
labs-alertmanager-1           "/bin/alertmanager ..."   Up              0.0.0.0:9093->9093/tcp
labs-blackbox-exporter-1      "/bin/blackbox_expo..."   Up              0.0.0.0:9115->9115/tcp
labs-grafana-1                "/run.sh"                 Up              0.0.0.0:3000->3000/tcp
labs-load-generator-1         "/app/load-generato..."   Up
labs-node-exporter-1          "/bin/node_exporter"      Up              0.0.0.0:9100->9100/tcp
labs-postgres-1               "docker-entrypoint...."   Up              0.0.0.0:5432->5432/tcp
labs-postgres-exporter-1      "/bin/postgres_expo..."   Up              0.0.0.0:9187->9187/tcp
labs-prometheus-1             "/bin/prometheus ..."     Up              0.0.0.0:9090->9090/tcp
labs-redis-1                  "docker-entrypoint...."   Up              0.0.0.0:6379->6379/tcp
labs-redis-exporter-1         "/redis_exporter ..."     Up              0.0.0.0:9121->9121/tcp
labs-sample-app-1             "/app/server"             Up              0.0.0.0:8080->8080/tcp
```

All services should show "Up". If any shows "Exited", see Troubleshooting below.

## Step 3b: Testing Your Environment

Before proceeding to queries, verify connectivity to your running services:

**Test Prometheus is accessible:**
```bash
curl http://localhost:9090
```

Expected output: HTML page (Prometheus UI HTML)

**Test Node Exporter metrics:**
```bash
curl http://localhost:9100/metrics | head -20
```

Expected output: Lines starting with `# HELP` and `# TYPE` followed by metric data.

**Test Prometheus is scraping metrics:**
```bash
curl http://localhost:9090/api/v1/query?query=up
```

Expected output: JSON with target statuses. You should see entries for `prometheus`, `node-exporter`, `sample-app`, `postgres-exporter`, `redis-exporter`, and `blackbox` — each with value `1`.

If any curl command fails, review Troubleshooting section below.

## Step 4: Open Prometheus UI

Open your browser and navigate to:
```
http://localhost:9090
```

You should see:
- Large search box at top
- "Graph" and "Table" tabs below
- Left sidebar with query history
- "Alerts" and "Status" menus in top bar

**Check the Targets:** Click "Status" → "Targets" in the menu. You should see 6+ scrape jobs, each with one or more targets:
- `prometheus` — Prometheus scraping itself
- `node-exporter` — Host system metrics (CPU, memory, disk)
- `sample-app` — Application metrics from the demo service
- `postgres-exporter` — PostgreSQL database metrics
- `redis-exporter` — Redis cache metrics
- `blackbox` — HTTP probe of the sample app endpoint

All targets should show "UP" in green. If any show "DOWN", wait 30 seconds and refresh. Targets take time to initialize.

## Step 5: Write Your First PromQL Queries

In the search box at the top, type each query below, then click "Execute" or press Enter.

### Query 1: `up`

```
up
```

**What does this mean?** "Show me the status of all targets"
- `1` = target is healthy and responding
- `0` = target is down

**What you'll see:** A table with 6+ rows (one per scrape target), all showing `1`.

### Query 2: `node_cpu_seconds_total`

```
node_cpu_seconds_total
```

**What does this mean?** "Show me cumulative CPU seconds used by the system"

Prometheus collects this over time. Each row is a different CPU core or mode (user, system, idle, etc.). The number is cumulative—it only goes up.

**What you'll see:** Multiple rows, each with a large number (thousands or millions) representing CPU seconds since the system started.

### Query 3: `node_memory_MemFree_bytes`

```
node_memory_MemFree_bytes
```

**What does this mean?** "How much free memory (in bytes) does the system have right now?"

This is a snapshot—it changes as you use more or less RAM.

**What you'll see:** One number, probably in the billions (1,000,000,000+ = 1 GB).

### Query 4: `count(up)`

```
count(up)
```

**What does this mean?** "Count how many targets are being monitored"

`count()` is an aggregation function. It counts the number of time series returned by `up`. With 6 scrape jobs all reporting healthy, the result is 6 or higher.

**What you'll see:** A single number: `6` or more

### Query 5: `rate(node_cpu_seconds_total[5m])`

```
rate(node_cpu_seconds_total[5m])
```

**What does this mean?** "What's the CPU usage rate over the last 5 minutes?"

`rate()` calculates how fast a counter is increasing. `[5m]` means "look at the last 5 minutes of data."

**What you'll see:** If Prometheus has been running for at least 5 minutes, you'll see a decimal number (like `0.05` = 5% CPU). If Prometheus just started, you might get an error—that's OK, we'll explain `rate()` in detail in Module 3.

## Troubleshooting

### Docker not found / Docker Desktop not running

**Error:** `Cannot connect to Docker daemon`

**Fix:** 
- macOS: Make sure Docker is running (check menu bar for whale icon)
- Windows: Make sure Docker Desktop is running (check Start menu)
- Linux: Run `sudo systemctl start docker`

### Port 9090 already in use

**Error:** `Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:9090`

**Fix:**
```bash
# Find what's using port 9090
# macOS/Linux:
lsof -i :9090

# Windows PowerShell:
netstat -ano | findstr :9090

# Stop the container using that port or choose a different port
# If it's our Prometheus, stop it:
docker compose down
```

### Targets showing DOWN

**Error:** Status → Targets shows "DOWN" for one or more targets

**Fix:**
- Wait 30 seconds and refresh (targets take time to initialize)
- Check Docker logs:
  ```bash
  docker compose logs prometheus
  docker compose logs node-exporter
  ```
- Look for error messages. Common issues:
  - Misconfigured prometheus.yml (check syntax)
  - Host network permissions (try `docker compose down && docker compose up -d` again)

### Prometheus UI won't load (blank page, timeout)

**Error:** `localhost:9090` times out or shows blank page

**Fix:**
```bash
# Check if Prometheus container is running
docker compose ps

# Check logs
docker compose logs prometheus

# Restart
docker compose down
docker compose up -d
```

### Query returns "No Data"

**Error:** Query executes but shows "No data" or "Vector"

**Possible causes:**
- Prometheus just started (needs ~30 seconds to collect data)
- Target is not scraping (check Targets page, make sure target is UP)
- Query name is typo'd (check exact metric names on Status → Targets)

**Fix:**
- Wait 60 seconds for initial metrics to collect
- Check target status (Status → Targets)
- Try a simple query like `up` first

### Permission denied on prometheus-data volume

**Error:** `Permission denied` when Docker tries to write to `./labs/prometheus-data`

**Fix:**
```bash
# Ensure prometheus-data directory exists with correct permissions
mkdir -p labs/prometheus-data
chmod 777 labs/prometheus-data

# If still failing, remove and restart
docker compose down
rm -rf labs/prometheus-data
docker compose up -d
```

### Docker network conflict (ports already in use)

**Error:** `cannot create network` or multiple port conflicts (9090, 3000, 5432, etc.)

**Fix:**
```bash
# Stop all running containers
docker compose down

# Remove dangling networks
docker network prune

# Restart
docker compose up -d

# If still failing, check what's using these ports
docker ps -a  # See all containers
```

### Can't connect to http://localhost:9090 from another machine

**Note:** Docker runs on localhost by default. You can only access it from your own machine. To expose Prometheus to other machines, see Day 1 of the course.

## Next Steps

Congrats! You now have:
- Prometheus running locally with a full 11-service stack
- System, application, database, and cache metrics being collected automatically
- Written 5 real PromQL queries
- Verified connectivity to all services

**Immediate Next:** Head to **Module 1, Day 1** to learn Prometheus architecture in depth. You've got the hands-on foundation. Now we'll explain what's happening under the hood.

**Later:** After completing Days 9-12 (PromQL fundamentals), tackle **Module 3, Day 15: Capstone Scenarios**. These 5 real-world challenges will teach you to:
- Debug latency spikes and cardinality explosions
- Analyze request rates and error patterns
- Monitor SLOs (Service Level Objectives)
- Plan for capacity growth
- Correlate multiple metrics for root cause analysis

**To stop the stack when done:**
```bash
# From the labs/ directory
docker compose down

# Or use make
make down
```

**To do a complete cleanup (remove volumes, clear old data):**
```bash
# IMPORTANT: The -v flag removes volumes (old data, configs)
# Use this if metrics seem stale or configs aren't updating
docker compose down -v

# This removes:
# - prometheus-data/ (TSDB chunks)
# - grafana-data/ (dashboards, datasources)
# - postgres-data/ (database)

# Warning: This deletes all local monitoring data. Only use if starting fresh.
```

**To start it again later:**
```bash
# From the labs/ directory
docker compose up -d

# Or use make
make setup
```

## After This Course

After completing Module 3, you're ready for:

1. **[Golden Signals Lab](../capstone/golden-signals-lab/)** — Use 4 signals to troubleshoot a real incident
2. **[Module 6: Pitfalls](../06-pitfalls/)** — Learn what breaks Prometheus and how to fix it
3. **Production Deployment** — Your course environment is production-like. Deploy with confidence.

## Summary Checklist

- [ ] Docker installed and running
- [ ] Repository cloned
- [ ] Containers started with `docker compose up -d`
- [ ] http://localhost:9090 loads
- [ ] Status → Targets shows 6+ targets, all "UP"
- [ ] All 5 queries above execute without error
- [ ] Understand what each query means (reread explanations if needed)

Once all checkboxes are done, you're ready for Module 1!
