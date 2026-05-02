.PHONY: setup verify down clean logs-prometheus logs-grafana logs-app verify-rules help

help:
	@echo "Prometheus Course — Available targets:"
	@echo "  make setup              — Start Docker environment"
	@echo "  make verify             — Validate setup and services"
	@echo "  make down               — Stop Docker containers"
	@echo "  make clean              — Stop Docker and remove volumes"
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

logs-prometheus:
	cd labs && docker compose logs -f prometheus

logs-grafana:
	cd labs && docker compose logs -f grafana

logs-app:
	cd labs && docker compose logs -f sample-app

verify-rules:
	docker compose exec prometheus promtool check rules /etc/prometheus/alert_rules.yml

.DEFAULT_GOAL := help
