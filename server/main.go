package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"
)

type TokenReq struct {
	Token string
}

func verifyHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /verify")
	// time.Sleep(2000000000)                 // delay 2s
	w.WriteHeader(http.StatusUnauthorized) // 401
	// w.WriteHeader(http.StatusOK) // 200
	w.Write([]byte(""))
}

// serve html page for verifying email
func verifyEmailPageHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /verify-email")
	// read email verification file
	verificationHTML, err := os.ReadFile("assets/email_verification.html")
	if err != nil {
		log.Fatalln(err)
	}
	w.Write([]byte(verificationHTML))
}

// html email verification page POSTs here
// checks if the jwt is valid
func verifyEmailTokenHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("POST /verify-email-token")
	var t TokenReq
	err := json.NewDecoder(r.Body).Decode(&t)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	jwt := t.Token
	log.Println(jwt)
	// check if token is valid
	// TODO: jwt checking
	if jwt == "crazy.rich.asians" {
		w.Write([]byte(""))
	} else {
		w.WriteHeader(http.StatusUnauthorized)
		w.Write([]byte(""))
	}
}

func stravaAuthCallbackHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("POST /strava-callback")
	r.ParseForm()
	params := r.Form
	log.Println(params)
	// code := params.Get("code")
	// scope := params.Get("scope")
	w.Write([]byte("<h1>Authorization with Strava Complete</h1>You may close this tab and return to the application"))
}

func serveAndroidAppLinkFingerprints(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /.well-known/assetlinks.json")
	assetlinksJSON, err := os.ReadFile("assets/assetlinks.json")
	if err != nil {
		log.Fatalln(err)
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(assetlinksJSON))
}

func main() {
	log.Printf("Loading env from .env")
	godotenv.Load(".env")
	port := os.Getenv("PORT")
	// clientId := os.Getenv("CLIENT_ID")
	// clientSecret := os.Getenv("CLIENT_SECRET")

	// initiate server
	mux := http.NewServeMux()
	mux.HandleFunc("/verify", verifyHandler)
	mux.HandleFunc("/verify-email", verifyEmailPageHandler)
	mux.HandleFunc("/verify-email-token", verifyEmailTokenHandler)
	mux.HandleFunc("/strava-callback", stravaAuthCallbackHandler)
	mux.HandleFunc("/.well-known/assetlinks.json", serveAndroidAppLinkFingerprints)
	server := &http.Server{
		Addr:         "127.0.0.1:" + port,
		WriteTimeout: 10 * time.Second,
		ReadTimeout:  10 * time.Second,
		Handler:      mux,
	}
	log.Printf("Listening on port %v\n", port)
	server.ListenAndServe()
}
