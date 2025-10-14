APP := ci-demo-go
PKG := github.com/hampusjohansson-data/ci-demo-go
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "dev")
DATE := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
VERSION ?= 0.1.0

LDFLAGS := -X $(PKG)/pkg/version.Version=$(VERSION) \
           -X $(PKG)/pkg/version.Commit=$(COMMIT) \
           -X $(PKG)/pkg/version.Date=$(DATE)

.PHONY: tidy test build run lint

tidy:
	go mod tidy

test:
	go test ./... -race -coverprofile=coverage.out

build:
	go build -ldflags "$(LDFLAGS)" -o bin/$(APP) ./cmd/server

run:
	go run -ldflags "$(LDFLAGS)" ./cmd/server

lint:
	golangci-lint run
