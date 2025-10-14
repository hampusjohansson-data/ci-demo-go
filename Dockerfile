# ---- build stage ----
FROM golang:1.22 AS build
WORKDIR /src

# Kopiera allt (enklast när projektet saknar externa deps)
COPY . .

# Ladda ner moduler (gör inget om du saknar externa deps, men är ofarligt)
RUN go mod download

# Bygg med version/commit/date inbakade
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
