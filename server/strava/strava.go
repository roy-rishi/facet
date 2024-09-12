package strava

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"slices"
	"strings"
)

type StravaCodeExchange struct {
	Code  string
	Scope string
	Email string
	Token string
}

func StravaAuthCallbackHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("POST /strava/exchange-code")
	// decode request body
	var body StravaCodeExchange
	err := json.NewDecoder(r.Body).Decode(&body)
	if err != nil {
		log.Println(err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

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
	newBody, err := json.Marshal(bodyParams{ClientID: os.Getenv("CLIENT_ID"), ClientSecret: os.Getenv("CLIENT_SECRET"), Code: body.Code, GrantType: "authorization_code"})
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
		http.Error(w, "", http.StatusInternalServerError)
		return
	}
	// TODO: register refresh_token in database
	w.Write([]byte(""))
}
