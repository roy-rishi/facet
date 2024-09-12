package app_links

import (
	"log"
	"net/http"
	"os"
)

func AndroidAppLinkFingerprintsHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /.well-known/assetlinks.json")
	assetlinksJSON, err := os.ReadFile("assets/assetlinks.json")
	if err != nil {
		log.Fatalln(err)
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(assetlinksJSON))
}
