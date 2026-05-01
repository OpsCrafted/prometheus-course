# Lab 5: Instrument a Go App

**Time:** 30-40 minutes  
**Goal:** Build a simple Go app that exposes Prometheus metrics

## Lab: Create and Run app.go

Create `labs/module-2-instrumentation/app.go` with the code from Day 5.

**Step 1:** Initialize go module (if needed)

```bash
cd labs/module-2-instrumentation
go mod init example.com/prometheus-app
```

**Step 2:** Get dependency

```bash
go get github.com/prometheus/client_golang
```

**Step 3:** Create app.go with code from Day 5 guide

**Step 4:** Run app

```bash
go run app.go
```

Should print: `Starting server on :8000`

**Step 5:** Test metrics endpoint

```bash
curl http://localhost:8000/metrics | grep http_requests
```

Should show empty metrics (no requests made yet).

**Step 6:** Generate traffic

```bash
curl http://localhost:8000/hello
```

Do this 3-5 times.

**Step 7:** Check metrics again

```bash
curl http://localhost:8000/metrics | grep http_requests_total
```

Should show:
```
http_requests_total{method="GET",path="/hello"} 5
```

## Solution

See `labs/module-2-instrumentation/solutions/app-solution.go`

## Exit Criteria

- [ ] Created app.go
- [ ] Got dependencies
- [ ] App runs on :8000
- [ ] `/metrics` endpoint accessible
- [ ] Metrics increment on requests
