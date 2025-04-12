# Makefile for managing the MySQL Docker Compose setup

# Project name
PROJECT_NAME := mysql_setup

# Docker Compose file
COMPOSE_FILE := docker-compose.yml

# Default target
.DEFAULT_GOAL := help

# Help target
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  setup       Create the .env file with a default password (interactive)."
	@echo "  start       Start the containers (MySQL, phpMyAdmin)."
	@echo "  stop        Stop the containers."
	@echo "  restart     Restart the containers."
	@echo "  logs        View the logs of the containers."
	@echo "  clean       Stop and remove containers, volumes, and networks."
	@echo "  help        Show this help message."

# Setup target: Create the .env file
setup:
	@if [ ! -f .env ]; then \
		read -p "Enter MySQL root password (default: root): " MYSQL_ROOT_PASSWORD; \
		MYSQL_ROOT_PASSWORD=$${MYSQL_ROOT_PASSWORD:-root}; \
		echo "MYSQL_ROOT_PASSWORD=$$MYSQL_ROOT_PASSWORD" > .env; \
		echo ".env file created with password: $$MYSQL_ROOT_PASSWORD"; \
	else \
		echo ".env file already exists."; \
	fi

# Start target: Start the containers
start:
	@echo "Starting containers..."
	docker compose -f $(COMPOSE_FILE) up -d

# Stop target: Stop the containers
stop:
	@echo "Stopping containers..."
	docker compose -f $(COMPOSE_FILE) down

# Restart target: Restart the containers
restart: stop
	@echo "Restarting containers..."
	$(MAKE) stop
	$(MAKE) start

# Logs target: View the logs
logs:
	@echo "Viewing logs..."
	docker compose -f $(COMPOSE_FILE) logs -f

# Clean target: Stop and remove everything
clean: stop
	@echo "Removing containers, volumes, and networks..."
	docker compose -f $(COMPOSE_FILE) down -v --rmi all

.PHONY: help setup start stop restart logs clean
