# === [ Befintlig del – OFÖRÄNDRAD ] ==========================================
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

# === [ Ny del – TILLÄGG ] =====================================================
# Python / Docker Compose mål är helt separata från Go-målen ovan.
# De kolliderar inte med dina nuvarande mål-namn.

PY ?= python3
PIP ?= pip3

.PHONY: lint-py test-py build-py up down logs

# Lint för Python (ruff) – kör kodstil/kvalitet på pyservice/
lint-py:
	@$(PY) -m pip install --upgrade pip ruff pytest >/dev/null
	@ruff check pyservice
	@ruff format --check pyservice || true   # rapportera endast
	@ruff format pyservice                   # formatera
	@ruff check --fix pyservice              # auto-fixa där det går

# Tester för Python (pytest)
test-py:
	@$(PY) -m pip install -r pyservice/requirements.txt pytest >/dev/null
	@PYTHONPATH=pyservice pytest -q

# Bygg Docker-image för Python-tjänsten
build-py:
	@docker build -t ci-demo-py:local pyservice

# Orkestrera Go + Python + Postgres via docker compose
up:
	@docker compose up --build -d

down:
	@docker compose down -v

logs:
	@docker compose logs -f
