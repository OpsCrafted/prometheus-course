.PHONY: setup verify down clean reset logs-prometheus logs-grafana logs-app verify-rules verify-day-5 verify-day-9 verify-day-10 verify-day-12 verify-day-13 verify-day-15 verify-day-16 verify-day-11 verify-day-14 help

help:
	@echo "Prometheus Course — Available targets:"
	@echo "  make setup              — Start Docker environment"
	@echo "  make verify             — Validate setup and services"
	@echo "  make down               — Stop Docker containers"
	@echo "  make clean              — Stop Docker and remove volumes"
	@echo "  make reset              — Clean then restart (fresh state)"
	@echo "  make logs-prometheus    — Tail Prometheus logs"
	@echo "  make logs-grafana       — Tail Grafana logs"
	@echo "  make logs-app           — Tail sample-app logs"
	@echo "  make verify-day-5       — Verify Day 5 (Go instrumentation metrics)"
	@echo "  make verify-day-9       — Verify Day 9 (instant queries and label selectors)"
	@echo "  make verify-day-10      — Verify Day 10 (aggregation operators)"
	@echo "  make verify-day-12      — Verify Day 12 (binary operators)"
	@echo "  make verify-day-13      — Verify Day 13 (PromQL functions)"
	@echo "  make verify-day-15      — Verify Day 15 (SLOs and burn rates)"
	@echo "  make verify-day-16      — Verify Day 16 (PromQL capstone)"

setup:
	cd labs && docker compose up -d

verify:
	bash labs/verify-setup.sh

down:
	cd labs && docker compose down

clean:
	cd labs && docker compose down -v && rm -rf prometheus-data

reset: clean setup

logs-prometheus:
	cd labs && docker compose logs -f prometheus

logs-grafana:
	cd labs && docker compose logs -f grafana

logs-app:
	cd labs && docker compose logs -f sample-app

verify-day-5:
	@echo "Verifying Day 5 (Go instrumentation)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_requests_total' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ http_requests_total counter exists" || (echo "✗ http_requests_total not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_request_duration_seconds_bucket' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ http_request_duration_seconds histogram exists" || (echo "✗ http_request_duration_seconds not found"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_request_size_bytes_bucket' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ http_request_size_bytes histogram exists" || (echo "✗ http_request_size_bytes not found"; exit 1)

verify-day-9:
	@echo "Verifying Day 9 (instant queries and label selectors)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=up%7Bjob%3D%22prometheus%22%7D' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ exact label match works" || (echo "✗ exact label match failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_requests_total%7Bendpoint%3D%22%2F%22%7D' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ endpoint label filter works" || (echo "✗ endpoint label filter failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_requests_total%7Bmethod%3D~%22G.*%22%7D' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ regex label filter works" || (echo "✗ regex label filter failed"; exit 1)

verify-day-10:
	@echo "Verifying Day 10 (aggregation operators)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=count(up)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ count(up) works" || (echo "✗ count(up) failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(http_requests_total)%20by%20(method)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ sum() by (method) works" || (echo "✗ sum() by (method) failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=avg(node_cpu_seconds_total)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ avg() works" || (echo "✗ avg() failed"; exit 1)

verify-day-12:
	@echo "Verifying Day 12 (binary operators)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(http_request_duration_seconds_sum)%20%2F%20sum(http_request_duration_seconds_count)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ arithmetic binary op (sum/sum) works" || (echo "✗ arithmetic binary op failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%7Bstatus%3D%22200%22%7D%5B5m%5D))%20%2F%20sum(rate(http_requests_total%5B5m%5D))' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ success ratio query works" || (echo "✗ success ratio query failed — stack may need 5+ minutes of uptime"; exit 1)

verify-day-13:
	@echo "Verifying Day 13 (PromQL functions)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=round(node_memory_MemFree_bytes%20%2F%201e9)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ round() math function works" || (echo "✗ round() failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=changes(up%5B15m%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ changes() range function works" || (echo "✗ changes() failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=rate(http_requests_total%5B5m%5D%20offset%201m)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ offset modifier works" || (echo "✗ offset modifier failed — stack may need 1+ minute of uptime"; exit 1)

verify-day-15:
	@echo "Verifying Day 15 (SLOs and burn rates)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%7Bstatus!~%225..%22%7D%5B5m%5D))%2Fsum(rate(http_requests_total%5B5m%5D))' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ availability SLI query returns data" || (echo "✗ availability SLI query failed — stack may need 5+ minutes of uptime"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=(sum(rate(http_requests_total%7Bstatus%3D~%225..%22%7D%5B5m%5D))%2Fsum(rate(http_requests_total%5B5m%5D)))%2F0.01' | jq -e '.status == "success"' > /dev/null && echo "✓ burn rate query executes" || (echo "✗ burn rate query failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/rules' | jq -e '[.data.groups[].rules[] | select(.name == "HighErrorBudgetBurn")] | length > 0' > /dev/null && echo "✓ HighErrorBudgetBurn alert loaded" || (echo "✗ HighErrorBudgetBurn alert not found — add it to labs/alert_rules.yml and reload"; exit 1)

verify-day-16:
	@echo "Verifying Day 16 (PromQL capstone)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=count(up%20%3D%3D%201)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ boolean comparison (up == 1) works" || (echo "✗ boolean comparison failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total%5B5m%5D))%20by%20(endpoint)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ rate by endpoint works" || (echo "✗ rate by endpoint failed — stack may need 5+ minutes of uptime"; exit 1)

verify-rules:
	cd labs && docker compose exec prometheus promtool check rules /etc/prometheus/alert_rules.yml

verify-day-11:
	@echo "Verifying Day 11 PromQL (rate/increase functions)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=rate(http_requests_total%5B5m%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ rate() query OK" || (echo "✗ rate() query failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=increase(http_requests_total%5B1h%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ increase() query OK" || (echo "✗ increase() query failed"; exit 1)

verify-day-14:
	@echo "Verifying Day 14 PromQL (histogram_quantile)..."
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=histogram_quantile(0.95,%20sum(rate(http_request_duration_seconds_bucket%5B5m%5D))%20by%20(le))' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ histogram_quantile() query OK" || (echo "✗ histogram_quantile() query failed"; exit 1)
	cd labs && docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_request_duration_seconds_bucket' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ histogram buckets exist" || (echo "✗ histogram buckets not found"; exit 1)

.DEFAULT_GOAL := help
