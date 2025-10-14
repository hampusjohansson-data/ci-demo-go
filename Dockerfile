# ---- build stage ----
FROM golang:1.25 AS build
WORKDIR /src

# Kopiera hela projektet (enkelt när vi saknar externa deps)
COPY . .

# Debug-info (hjälper om build skulle fallera)
RUN go version && go env && ls -la && echo "Packages:" && go list ./...

# Bygg med inbakad versionsinfo
ARG VERSION=0.1.0
ARG COMMIT=dev
ARG DATE=unknown
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w \
    -X github.com/hampusjohansson-data/ci-demo-go/pkg/version.Version=${VERSION} \
    -X github.com/hampusjohansson-data/ci-demo-go/pkg/version.Commit=${COMMIT} \
    -X github.com/hampusjohansson-data/ci-demo-go/pkg/version.Date=${DATE}" \
    -o /out/app ./cmd/server

# ---- run stage ----
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=build /out/app /app
ENV PORT=8080
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]
