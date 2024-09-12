package auth

import (
	"log"
	"net/http"

	"github.com/roy-rishi/facet/cors"
)

func VerifyHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /verify")
	cors.SetCORS(&w)
	w.WriteHeader(http.StatusUnauthorized) // 401
	// w.WriteHeader(http.StatusOK) // 200
	w.Write([]byte(""))
}
