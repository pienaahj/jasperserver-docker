PLATFORMS=linux/amd64,linux/arm64
IMAGE=pienaahj/jasperserver
TAG=latest

build:
	docker buildx build \
	  --platform $(PLATFORMS) \
	  -t $(IMAGE):$(TAG) \
	  --push .
