.PHONY: setup reset clean help

help:
	@echo "Prometheus Course — Available targets:"
	@echo "  make setup      — Start Docker environment"
	@echo "  make reset      — Reset Docker volumes and restart"
	@echo "  make clean      — Stop Docker containers"

setup:
	cd labs && bash setup.sh

reset:
	cd labs && docker-compose down -v && docker-compose up -d

clean:
	cd labs && docker-compose down

.DEFAULT_GOAL := help
