# Getting Started with Prometheus

**Time:** 2-3 hours  
**Goal:** Set hands-on context before diving into theory. Get Prometheus running locally, explore the UI, write your first PromQL queries.

## What You'll Do

1. Install Docker (if not already installed)
2. Clone the course repository
3. Start Prometheus via Docker Compose
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
docker-compose --version
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
sudo apt-get install docker.io docker-compose -y

# Add your user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker-compose --version
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
docker-compose --version
```

## Step 2: Clone the Repository

```bash
# Navigate to a folder where you want to work
cd ~/projects  # or wherever you prefer

# Clone the course
git clone https://github.com/boris-aws/prometheus-course.git
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
- `docker-compose.yml` — Configuration to start Prometheus + Node Exporter
- `prometheus.yml` — Prometheus scrape configuration
- `setup.sh` — Helper script

## Step 3: Start Prometheus

```bash
# From inside labs/ directory
docker-compose up -d
```

Expected output:
```
Creating network "labs_default" with the default driver
Creating labs-prometheus-1    ... done
Creating labs-node-exporter-1 ... done
```

`-d` means "detached" (runs in background). If you want to see logs, use `docker-compose up` without `-d` (Ctrl+C to stop).

**Verify containers are running:**
```bash
docker-compose ps
```

Expected output:
```
NAME                       COMMAND                   STATE           PORTS
labs-prometheus-1          "/bin/prometheus ..."     Up 2 minutes    0.0.0.0:9090->9090/tcp
labs-node-exporter-1       "/bin/node_exporter"      Up 2 minutes    0.0.0.0:9100->9100/tcp
```

Both should be "Up". If either shows "Exited", see Troubleshooting below.

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

**Check the Targets:** Click "Status" → "Targets" in the menu. You should see:
- `prometheus` target (monitoring Prometheus itself)
- `node-exporter` target (monitoring system metrics like CPU, memory, disk)
- Both should show "UP" in green

If targets show "DOWN", wait 30 seconds and refresh. Targets take time to initialize.

## Step 5: Write Your First PromQL Queries

In the search box at the top, type each query below, then click "Execute" or press Enter.

### Query 1: `up`

```
up
```

**What does this mean?** "Show me the status of all targets"
- `1` = target is healthy and responding
- `0` = target is down

**What you'll see:** A table with two rows (one for prometheus, one for node-exporter), both showing `1`.

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

`count()` is an aggregation function. It adds up all the `up` values. Since we have 2 targets and each is 1, the result is 2.

**What you'll see:** A single number: `2`

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
docker-compose down
```

### Targets showing DOWN

**Error:** Status → Targets shows "DOWN" for one or both targets

**Fix:**
- Wait 30 seconds and refresh (targets take time to initialize)
- Check Docker logs:
  ```bash
  docker-compose logs prometheus
  docker-compose logs node-exporter
  ```
- Look for error messages. Common issues:
  - Misconfigured prometheus.yml (check syntax)
  - Host network permissions (try `docker-compose down && docker-compose up -d` again)

### Prometheus UI won't load (blank page, timeout)

**Error:** `localhost:9090` times out or shows blank page

**Fix:**
```bash
# Check if Prometheus container is running
docker-compose ps

# Check logs
docker-compose logs prometheus

# Restart
docker-compose down
docker-compose up -d
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

### Can't connect to http://localhost:9090 from another machine

**Note:** Docker runs on localhost by default. You can only access it from your own machine. To expose Prometheus to other machines, see Day 1 of the course.

## Next Steps

Congrats! You now have:
- ✅ Prometheus running
- ✅ System metrics being collected
- ✅ Written 5 real PromQL queries

**Next:** Head to **Module 1, Day 1** to learn Prometheus architecture in depth. You've got the hands-on foundation. Now we'll explain what's happening under the hood.

**To stop Prometheus when done:**
```bash
docker-compose down
```

**To start it again later:**
```bash
# From the labs/ directory
docker-compose up -d
```

## Summary Checklist

- [ ] Docker installed and running
- [ ] Repository cloned
- [ ] Containers started with `docker-compose up -d`
- [ ] http://localhost:9090 loads
- [ ] Status → Targets shows at least 2 targets, both "UP"
- [ ] All 5 queries above execute without error
- [ ] Understand what each query means (reread explanations if needed)

Once all checkboxes are done, you're ready for Module 1!
