package cors

import "net/http"

// TODO: properly enforce CORS
func SetCORS(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
}
