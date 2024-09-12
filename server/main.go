package main

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"slices"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
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
	setCORS(&w)
	// time.Sleep(4000000000)                 // delay 4s
	w.WriteHeader(http.StatusUnauthorized) // 401
	// w.WriteHeader(http.StatusOK) // 200
	w.Write([]byte(""))
}

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
	log.Println(body)
	// TODO: check if Facet token is valid

	// check if necessary scopes were granted
	scopesExpected := [...]string{"read", "activity:read_all"}
	scopesGranted := strings.Split(body.Scope, ",")
	for i := 0; i < len(scopesGranted); i++ {
		scopesGranted[i] = strings.TrimSpace(scopesGranted[i])
	}
	for i := 0; i < len(scopesExpected); i++ {
		scope := scopesExpected[i]
		if !slices.Contains(scopesGranted, scope) {
			http.Error(w, "Bad Scope", http.StatusBadRequest)
			log.Println("Bad scope")
			return
		}
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
	if stravaRes.StatusCode != 200 || stravaResJSON["refresh_token"] == nil {
		http.Error(w, "", http.StatusBadRequest)
		return
	}
	// TODO: register refresh_token in database
	w.Write([]byte(""))
}

func androidAppLinkFingerprintsHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /.well-known/assetlinks.json")
	assetlinksJSON, err := os.ReadFile("assets/assetlinks.json")
	if err != nil {
		log.Fatalln(err)
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(assetlinksJSON))
}

// TODO: properly enforce CORS
func setCORS(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
}

type intercept404 struct {
	http.ResponseWriter
	statusCode int
}

func (w *intercept404) Write(b []byte) (int, error) {
	if w.statusCode == http.StatusNotFound {
		return len(b), nil
	}
	if w.statusCode != 0 {
		w.WriteHeader(w.statusCode)
	}
	return w.ResponseWriter.Write(b)
}

func (w *intercept404) WriteHeader(statusCode int) {
	if statusCode >= 300 && statusCode < 400 {
		w.ResponseWriter.WriteHeader(statusCode)
		return
	}
	w.statusCode = statusCode
}

func spaFileServeHandler(dir string) func(http.ResponseWriter, *http.Request) {
	fileServer := http.FileServer(http.Dir(dir))
	return func(w http.ResponseWriter, r *http.Request) {
		wt := &intercept404{ResponseWriter: w}
		fileServer.ServeHTTP(wt, r)
		if wt.statusCode == http.StatusNotFound {
			r.URL.Path = "/"
			w.Header().Set("Content-Type", "text/html")
			fileServer.ServeHTTP(w, r)
		}
	}
}

func main() {
	log.Println("Loading env from .env")
	godotenv.Load(".env")
	port := os.Getenv("PORT")

	// connect to database
	log.Println("Connecting to database at DATABASE_URL from .env")
	db, err := pgxpool.New(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err.Error())
	}
	defer db.Close()

	// initiate server
	mux := http.NewServeMux()
	mux.HandleFunc("/verify", verifyHandler)
	mux.HandleFunc("/verify-email-token", verifyEmailTokenHandler)
	mux.HandleFunc("/strava/exchange-code", stravaAuthCallbackHandler)
	mux.HandleFunc("/.well-known/assetlinks.json", androidAppLinkFingerprintsHandler)
	mux.HandleFunc("/", spaFileServeHandler("public")) // host web build files from /server/public

	server := &http.Server{
		Addr:         "127.0.0.1:" + port,
		WriteTimeout: 10 * time.Second,
		ReadTimeout:  10 * time.Second,
		Handler:      mux,
	}
	log.Printf("Server listening on port %v\n", port)
	server.ListenAndServe()
}
