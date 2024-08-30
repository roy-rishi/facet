package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

type TokenReq struct {
	Token string
}

func verifyRoute(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /verify")
	time.Sleep(1000000000)                 // delay 1s
	w.WriteHeader(http.StatusUnauthorized) // 401
	// w.WriteHeader(http.StatusOK) // 200
	w.Write([]byte(""))
}

// serve html page for verifying email
func verifyEmailPageRoute(w http.ResponseWriter, r *http.Request) {
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
func verifyEmailTokenRoute(w http.ResponseWriter, r *http.Request) {
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

func main() {
	log.Println("Listening on port 3010")
	http.HandleFunc("/verify", verifyRoute)
	http.HandleFunc("/verify-email", verifyEmailPageRoute)
	http.HandleFunc("/verify-email-token", verifyEmailTokenRoute)
	log.Fatal(http.ListenAndServe(":3010", nil))
}
