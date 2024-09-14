package strava

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
)

type eventData struct {
	ObjectType     string     `json:"object_type"`
	ObjectID       int64      `json:"object_id"`
	AspectType     string     `json:"aspect_type"`
	Updates        updateData `json:"updates"`
	OwnerID        int64      `json:"owner_id"`
	SubscriptionID int        `json:"subscription_id"`
	EventTime      int64      `json:"event_time"`
}

type updateData struct {
	Title      string `json:"title"`
	Type       string `json:"type"`
	Private    string `json:"private"`
	Authorized string `json:"authorized"`
}

func subscriptionValidationHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("GET /strava/webhook")
	mode := r.URL.Query().Get("hub.mode")
	challenge := r.URL.Query().Get("hub.challenge")
	verifyToken := r.URL.Query().Get("hub.verify_token")
	if mode == "" || challenge == "" || verifyToken == "" {
		log.Println("Error: one or more query params were null or empty")
		http.Error(w, "", http.StatusBadRequest)
		return
	}
	if verifyToken != os.Getenv("WEBHOOK_VERIFY_TOKEN") {
		log.Println("Error: verify token does not match")
		http.Error(w, "", http.StatusUnauthorized)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	res, _ := json.Marshal(map[string]string{"hub.challenge": challenge})
	w.Write(res)
}

func eventHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("POST /strava/webhook")
	rawReqBody, _ := io.ReadAll(r.Body)
	log.Println("raw req body: " + string(rawReqBody))
	var reqBody eventData
	err := json.NewDecoder(io.NopCloser(bytes.NewReader(rawReqBody))).Decode(&reqBody)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	defer r.Body.Close()
	log.Printf("parsed req body: %+v\n", reqBody)
	w.Write([]byte(""))
}

func StravaWebhookHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		// handle webhook subscription validation request
		subscriptionValidationHandler(w, r)
	} else if r.Method == "POST" {
		// handle regular webhook events
		eventHandler(w, r)
	}
}
