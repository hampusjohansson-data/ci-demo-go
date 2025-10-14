package main

import (
	"log"
	"net/http"
	"os"

	apphttp "github.com/hampusjohansson-data/ci-demo-go/internal/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", apphttp.HealthHandler)

	addr := ":" + env("PORT", "8080")
	log.Printf("listening on %s", addr)

	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}

func env(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
