package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"
)

type TokenReq struct {
	Token string
}

type StravaCodeExchange struct {
	Code  string
	Scope string
	Email string
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
	log.Println("POST /strava/exchange-code")
	// decode request body
	var body StravaCodeExchange
	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// check if necessary scopes were granted
	if body.Scope != "read,activity:read_all" {
		http.Error(w, "Bad Scope", http.StatusBadRequest)
		log.Println("Bad scope")
		return
	}

	// form POST body to send to Strava API
	type bodyParams struct {
		ClientID     string `json:"client_id"`
		ClientSecret string `json:"client_secret"`
		Code         string `json:"code"`
		GrantType    string `json:"authorization_code"`
	}
	clientID := os.Getenv("CLIENT_ID")
	clientSecret := os.Getenv("CLIENT_SECRET")
	// TODO: error handling on this whole func body
	newBody, err := json.Marshal(bodyParams{ClientID: clientID, ClientSecret: clientSecret, Code: body.Code, GrantType: "authorization_code"})
	request, err := http.NewRequest("POST", "https://www.strava.com/oauth/token", bytes.NewBuffer(newBody))
	request.Header.Set("Content-Type", "application/json")

	// execute POST
	client := http.Client{}
	stravaRes, err := client.Do(request)
	defer stravaRes.Body.Close()
	stravaResBody, err := io.ReadAll(stravaRes.Body)
	log.Println(string(stravaResBody))

	// process Strava response
	var stravaResJSON map[string]interface{}
	err = json.Unmarshal(stravaResBody, &stravaResJSON)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Badly Formed Response from Strava", http.StatusInternalServerError)
		return
	}
	if stravaRes.StatusCode != 200 || stravaResJSON["refresh_token"] != nil {
		http.Error(w, "", http.StatusBadRequest)
		return
	}
	// TODO: register refresh_token in database
	w.Write([]byte(""))
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
	mux.HandleFunc("/strava/exchange-code", stravaAuthCallbackHandler)
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
