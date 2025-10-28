# =========[ Go – BEFINTLIG DEL ]================================================
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

# =========[ Python / Compose / Migrations ]===========================

PY ?= python3
PIP ?= pip3

.PHONY: lint-py test-py build-py up down logs migrate-up migrate-down migrate-create

# ---- Python ----
lint-py:
	@$(PY) -m pip install --upgrade pip ruff pytest >/dev/null
	@ruff check pyservice
	@ruff format --check pyservice || true
	@ruff format pyservice
	@ruff check --fix pyservice

test-py:
	@$(PY) -m pip install --upgrade pip >/dev/null
	@$(PY) -m pip install -r pyservice/requirements.txt >/dev/null
	@PYTHONPATH=pyservice pytest -q

build-py:
	@docker build -t ci-demo-py:local pyservice

# ---- Docker Compose (lokalt) ----
up:
	@docker compose up --build -d

down:
	@docker compose down -v

logs:
	@docker compose logs -f

# ---- Migreringar (kräver att compose-nätet finns – kör 'make up' först eller låt kommandot funka fristående) ----
# Använder samma DATABASE_URL som Compose; om den saknas används default-URL.
migrate-up:
	@docker run --rm \
		--network ci-demo-go_default \
		-v "$(PWD)/db/migrations:/migrations" \
		-e DATABASE_URL="$${DATABASE_URL:-postgres://postgres:postgres@db:5432/app}" \
		migrate/migrate:v4.17.1 -path=/migrations -database "$${DATABASE_URL}?sslmode=disable" up

migrate-down:
	@docker run --rm \
		--network ci-demo-go_default \
		-v "$(PWD)/db/migrations:/migrations" \
		-e DATABASE_URL="$${DATABASE_URL:-postgres://postgres:postgres@db:5432/app}" \
		migrate/migrate:v4.17.1 -path=/migrations -database "$${DATABASE_URL}?sslmode=disable" down 1

# Skapa nya tomma migrationsfiler: make migrate-create name=add_table
migrate-create:
	@test -n "$(name)" || (echo "Usage: make migrate-create name=add_table"; exit 1)
	@ts=$$(date +%Y%m%d%H%M%S); \
	mkdir -p db/migrations; \
	touch db/migrations/$${ts}_$(name).up.sql db/migrations/$${ts}_$(name).down.sql; \
	echo "Created db/migrations/$${ts}_$(name).up.sql (and .down.sql)"
