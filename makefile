PLATFORMS=linux/amd64,linux/arm64
IMAGE=pienaahj/jasperserver
TAG=latest

build:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  -t $(IMAGE):$(TAG) \
	  --push .
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

	# Usage
	# make switch-db DB=postgres
	# make switch-db DB=mysql
	# make switch-db DB=mariadb	
	