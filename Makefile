.PHONY: setup verify down clean reset logs-prometheus logs-grafana logs-app verify-rules verify-day-11 verify-day-14 help

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

verify-rules:
	docker compose exec prometheus promtool check rules /etc/prometheus/alert_rules.yml

.PHONY: verify-day-11
verify-day-11:
	@echo "Verifying Day 11 PromQL (rate/increase functions)..."
	docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=rate(http_requests_total%5B5m%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ rate() query OK" || (echo "✗ rate() query failed"; exit 1)
	docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=increase(http_requests_total%5B1h%5D)' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ increase() query OK" || (echo "✗ increase() query failed"; exit 1)

.PHONY: verify-day-14
verify-day-14:
	@echo "Verifying Day 14 PromQL (histogram_quantile)..."
	docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=histogram_quantile(0.95,%20sum(rate(http_request_duration_seconds_bucket%5B5m%5D))%20by%20(le))' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ histogram_quantile() query OK" || (echo "✗ histogram_quantile() query failed"; exit 1)
	docker compose exec prometheus wget -q -O - 'http://localhost:9090/api/v1/query?query=http_request_duration_seconds_bucket' | jq -e '.status == "success" and (.data.result | length > 0)' > /dev/null && echo "✓ histogram buckets exist" || (echo "✗ histogram buckets not found"; exit 1)

.DEFAULT_GOAL := help
