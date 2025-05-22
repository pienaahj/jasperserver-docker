PLATFORMS = linux/amd64,linux/arm64
IMAGE = pienaahj/jasperserver
TAG = latest

# === Direct Docker Build ===
build:
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE):$(TAG) \
		--push .

# === Docker Compose Up Targets ===
up-%: switch-db
	@docker-compose --env-file .env up -d --build

# === DB Switch Logic ===
switch-db:
	@if [ -z "$(DB)" ]; then \
		echo "Usage: make switch-db DB=postgres|mysql|mariadb"; \
		exit 1; \
	fi
	@if [ ! -f config/$(DB)_master.properties ]; then \
		echo "config/$(DB)_master.properties not found!"; \
		exit 1; \
	fi
	cp config/$(DB)_master.properties config/default_master.properties
	@echo "🔁 Switched config to $(DB)."

# === Environment and Config Sync ===
env-switch:
	@if [ -z "$(DB)" ]; then \
		echo "Usage: make env-switch DB=postgres|mysql|mariadb"; \
		exit 1; \
	fi
	@if [ ! -f .env.$(DB) ]; then \
		echo "❌ .env.$(DB) not found!"; \
		exit 1; \
	fi
	@if [ ! -f config/$(DB)_master.properties ]; then \
		echo "❌ config/$(DB)_master.properties not found!"; \
		exit 1; \
	fi
	cp .env.$(DB) .env
	cp config/$(DB)_master.properties config/default_master.properties
	@echo "✅ Environment and config switched to $(DB)"

# === Docker Bake Targets ===
bake:
	set -a && . .env && set +a && docker buildx bake

bake-push:
	set -a && . .env && set +a && docker buildx bake --push

bake-arm:
	docker buildx bake --set jasperserver.platform=linux/arm64

bake-amd:
	docker buildx bake --set jasperserver.platform=linux/amd64

# === Env Sanity Check (optional add-on) ===
check-env:
	@for var in JRS_DB_TYPE JRS_DB_HOST JRS_DB_PORT JRS_DB_NAME JRS_DB_USER JRS_DB_PASSWORD; do \
		if ! grep -q $$var= .env; then \
			echo "Missing $$var in .env"; exit 1; \
		fi; \
	done
# === Clean Docker Cache and Images ===
clean:
	@echo "🧹 Cleaning Docker build cache and dangling images..."
	docker builder prune --force
	docker image prune --force
