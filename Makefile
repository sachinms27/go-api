API_BINARY=go-api

up:
	@echo "Starting Docker images..."
	docker-compose up -d
	@echo "Docker images started!"

## up_build: stops docker-compose (if running), builds all projects and starts docker compose
up_build: build_api
	@echo "Stopping docker images (if running...)"
	docker-compose down
	@echo "Building (when required) and starting docker images..."
	docker-compose up --build -d
	@echo "Docker images built and started!"

## down: stop docker compose
down:
	@echo "Stopping docker compose..."
	docker-compose down
	@echo "Done!"

## build_api: builds the listener binary as a linux executable
build_api: build_swagger
	@echo "Building listener service binary..."
	env GOOS=linux CGO_ENABLED=0 go build -o ${API_BINARY} ./
	@echo "Done!"

## build_swagger: generate swagger API automation
build_swagger:
	@echo "generate swagger API docs"
	rm -rf ./docs
	go get github.com/swaggo/swag/cmd/swag && swag init --parseInternal
	@echo "Done!"

test:
	@go test -v ./...
