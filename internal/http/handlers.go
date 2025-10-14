package http

import (
	"encoding/json"
	"net/http"

	"github.com/hampusjohansson-data/ci-demo-go/pkg/version"
)

type healthResp struct {
	Status  string `json:"status"`
	Service string `json:"service"`
	Version string `json:"version"`
	Commit  string `json:"commit"`
	Date    string `json:"date"`
}

func HealthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	resp := healthResp{
		Status:  "ok",
		Service: version.AppName,
		Version: version.Version,
		Commit:  version.Commit,
		Date:    version.Date,
	}
	json.NewEncoder(w).Encode(resp)
}
