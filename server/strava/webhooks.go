package strava

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/roy-rishi/facet/database"
	"github.com/roy-rishi/facet/firebase"
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

func createActivityHandler(reqBody eventData) {
	// get fcm reg tokens and push notif. to all clients
	rows, err := database.DB.Query(context.Background(), `SELECT token from fcm_reg_tokens WHERE user_id = $1;`, reqBody.OwnerID)
	if err != nil {
		log.Println(err.Error())
		return
	}
	defer rows.Close()
	for rows.Next() {
		var fcmRegToken string
		err := rows.Scan(&fcmRegToken)
		if err != nil {
			log.Println(err.Error())
			return
		}
		// TODO: deeplinking
		firebase.PushNotificationToClient("Nice ride! 🚴", "Tap to see more", fcmRegToken)
	}
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

	objectType := reqBody.ObjectType
	if objectType == "activity" {
		// activityID := reqBody.ObjectID
		aspectType := reqBody.AspectType
		switch aspectType {
		case "create":
			log.Println("Create activity")
			w.Write([]byte(""))
			createActivityHandler(reqBody)

		case "delete":
			log.Println("Delete activity")
			w.Write([]byte(""))

		case "update":
			if reqBody.Updates.Title != "" {
				newTitle := reqBody.Updates.Title
				log.Println("New title:", newTitle)
			}
			if reqBody.Updates.Type != "" {
				newType := reqBody.Updates.Type
				log.Println("New type:", newType)
			}
			if reqBody.Updates.Private != "" {
				newPrivacy := reqBody.Updates.Private
				log.Println("New privacy:", newPrivacy)
			}
			return
		}
	} else if objectType == "athlete" {
		athleteID := reqBody.ObjectID
		if reqBody.Updates.Authorized == "false" {
			log.Println("Deauthorization request")
			w.Write([]byte(""))
			_, err := database.DB.Exec(context.Background(), `UPDATE users SET accessRevoked = TRUE WHERE id = $1;`, athleteID)
			if err != nil {
				log.Println(err.Error())
				return
			}
			return
		} else {
			log.Println("Error: Unknown request")
			http.Error(w, "Error: Unknown request", http.StatusInternalServerError)
			return
		}
	}
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
