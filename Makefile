.PHONY: help up down build logs test migrate shell dbshell clean lint format

help: ## Show this help message
	@echo 'Hotel Booking Project Management'
	@echo '================================'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Start containers in background
	docker-compose up -d --build

down: ## Stop and remove containers
	docker-compose down

build: ## Build images
	docker-compose build

logs: ## View logs from all services
	docker-compose logs -f

test: ## Run tests
	docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit

migrate: ## Run Django migrations
	docker-compose exec web python manage.py migrate

makemigrations: ## Create new migrations
	docker-compose exec web python manage.py makemigrations

shell: ## Open Django shell
	docker-compose exec web python manage.py shell

dbshell: ## Open PostgreSQL shell
	docker-compose exec db psql -U postgres -d hotel_db

createsuperuser: ## Create Django superuser
	docker-compose exec web python manage.py createsuperuser

clean: ## Remove all containers, volumes and images
	docker-compose down -v
	docker system prune -af

lint: ## Run ruff linter
	docker-compose exec web ruff check .

format: ## Format code with ruff
	docker-compose exec web ruff format .

load-test-data: ## Load test data (if you create fixtures)
	docker-compose exec web python manage.py loaddata test_data.json

check-deps: ## Check for outdated dependencies
	docker-compose exec web poetry show --outdated