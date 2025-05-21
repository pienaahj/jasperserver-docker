PLATFORMS=linux/amd64,linux/arm64
IMAGE=pienaahj/jasperserver
TAG=latest
# build the image
build:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  -t $(IMAGE):$(TAG) \
	  --push .

# switch the db
switch-db:
	@if [ -z "$(DB)" ]; then \
		echo "Usage: make switch-db DB=postgres|mysql|mariadb"; \
		exit 1; \
	fi
	@if [ ! -f config/$(DB)_master.properties ]; then \
		echo "config/$(DB)_master.properties not found!"; \
		exit 1; \
	fi
	@cp config/$(DB)_master.properties config/default_master.properties
	@echo "Switched to $(DB) configuration."

up-postgres:
	@$(MAKE) switch-db DB=postgres
	@docker-compose --env-file .env up -d --build

up-mysql:
	@$(MAKE) switch-db DB=mysql
	@docker-compose --env-file .env up -d --build

up-mariadb:
	@$(MAKE) switch-db DB=mariadb
	@docker-compose --env-file .env up -d --build

# Usage
# make switch-db DB=postgres
# make switch-db DB=mysql
# make switch-db DB=mariadb	
# make up-postgres
# make up-mysql
# make up-mariadb
	
# Switch the .env and default_master.properties in one go
env-switch:
	@if [ -z "$(DB)" ]; then \
		echo "Usage: make env-switch DB=postgres|mysql|mariadb"; \
		exit 1; \
	fi
	@if [ ! -f .env.$(DB) ]; then \
		echo ".env.$(DB) not found!"; \
		exit 1; \
	fi
	@if [ ! -f config/$(DB)_master.properties ]; then \
		echo "config/$(DB)_master.properties not found!"; \
		exit 1; \
	fi
	cp .env.$(DB) .env
	cp config/$(DB)_master.properties config/default_master.properties
	echo "✅ Switched to $(DB) environment."
