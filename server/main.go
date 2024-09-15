package main

import (
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"
	"github.com/roy-rishi/facet/app_links"
	"github.com/roy-rishi/facet/auth"
	"github.com/roy-rishi/facet/database"
	"github.com/roy-rishi/facet/firebase"
	"github.com/roy-rishi/facet/strava"
	"github.com/roy-rishi/facet/web_host"
)

func main() {
	log.Println("Loading env from .env")
	godotenv.Load(".env")
	port := os.Getenv("PORT")

	// connect to database
	log.Println("Connecting to database at DATABASE_URL from .env")
	database.ConnectToDB()

	// initate Firebase
	firebase.InitializeFirebaseFCM()

	// initiate server
	mux := http.NewServeMux()
	mux.HandleFunc("/verify", auth.VerifyHandler)
	mux.HandleFunc("/strava/exchange-code", strava.StravaAuthCallbackHandler)
	mux.HandleFunc("/.well-known/assetlinks.json", app_links.AndroidAppLinkFingerprintsHandler)
	mux.HandleFunc("/", web_host.SPAFileServeHandler("assets/public")) // host web build files from /server/public
	mux.HandleFunc("/strava/webhook", strava.StravaWebhookHandler)

	server := &http.Server{
		Addr:         "127.0.0.1:" + port,
		WriteTimeout: 10 * time.Second,
		ReadTimeout:  10 * time.Second,
		Handler:      mux,
	}
	log.Printf("Server listening on port %v\n", port)
	server.ListenAndServe()
}
