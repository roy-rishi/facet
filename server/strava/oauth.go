package strava

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/json"
	"io"
	"log"
	"math/big"
	"net/http"
	"os"
	"slices"
	"strings"
	"time"

	"github.com/roy-rishi/facet/database"
)

type postBody struct {
	Code     string
	Scope    string
	FCMtoken string
}

type resBody struct {
	RefreshToken string            `json:"refresh_token"`
	AccessToken  string            `json:"access_token"`
	Athlete      resAthleteSubBody `json:"athlete"`
}

type resAthleteSubBody struct {
	ID            int    `json:"id"`
	Username      string `json:"username"`
	Firstname     string `json:"firstname"`
	Lastname      string `json:"lastname"`
	Bio           string `json:"bio"`
	ProfileMedium string `json:"profile_medium"`
	Profile       string `json:"profile"`
}

func generateRandomString(n int) (string, error) {
	const letters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	ret := make([]byte, n)
	for i := 0; i < n; i++ {
		num, err := rand.Int(rand.Reader, big.NewInt(int64(len(letters))))
		if err != nil {
			return "", err
		}
		ret[i] = letters[num.Int64()]
	}
	return string(ret), nil
}

func StravaAuthCallbackHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("POST /strava/exchange-code")
	// decode request body
	var reqBody postBody
	err := json.NewDecoder(r.Body).Decode(&reqBody)
	if err != nil {
		log.Println(err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// check if necessary scopes were granted
	scopesExpected := [...]string{"read", "activity:read_all"}
	scopesGranted := strings.Split(reqBody.Scope, ",")
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
	newBody, err := json.Marshal(bodyParams{ClientID: os.Getenv("CLIENT_ID"), ClientSecret: os.Getenv("CLIENT_SECRET"), Code: reqBody.Code, GrantType: "authorization_code"})
	request, err := http.NewRequest("POST", "https://www.strava.com/oauth/token", bytes.NewBuffer(newBody))
	request.Header.Set("Content-Type", "application/json")

	// execute POST
	client := http.Client{}
	stravaRes, err := client.Do(request)
	defer stravaRes.Body.Close()
	stravaResBytes, err := io.ReadAll(stravaRes.Body)
	if stravaRes.StatusCode != 200 {
		http.Error(w, "", http.StatusBadGateway)
		log.Printf("ERROR: Strava status code %v\n", stravaRes.StatusCode)
		log.Printf("strava json response: %v", string(stravaResBytes))
		return
	}

	// unmarshall strava response
	res := &resBody{}
	err = json.Unmarshal(stravaResBytes, res)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// generate facet refresh token
	facetAccessToken, err := generateRandomString(40)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	// calculate token expiration
	expTime := time.Now().Add(time.Minute / 2)
	expTimestamp := expTime.Format("2006-01-02 15:04:05 -07:00")

	// upsert user in db
	_, err = database.DB.Exec(context.Background(), `
		INSERT INTO users (id, first_name, last_name, username, profile_image, profile_image_medium, bio, strava_refresh_token, strava_access_token, accessRevoked)
		VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		ON CONFLICT(id)
		DO UPDATE SET
			first_name = EXCLUDED.first_name,
			last_name = EXCLUDED.last_name,
			username = EXCLUDED.username,
			profile_image = EXCLUDED.profile_image,
			profile_image_medium = EXCLUDED.profile_image_medium,
			bio = EXCLUDED.bio,
			strava_refresh_token = EXCLUDED.strava_refresh_token,
			strava_access_token = EXCLUDED.strava_access_token,
			accessRevoked = EXCLUDED.accessRevoked;`,
		res.Athlete.ID,
		res.Athlete.Firstname,
		res.Athlete.Lastname,
		res.Athlete.Username,
		res.Athlete.Profile,
		res.Athlete.ProfileMedium,
		res.Athlete.Bio,
		res.RefreshToken,
		res.AccessToken,
		false)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// store access token in db
	_, err = database.DB.Exec(context.Background(), `
		INSERT INTO credentials (user_id, access_token, expiration)
		VALUES ($1, $2, $3);`,
		res.Athlete.ID,
		facetAccessToken,
		expTimestamp)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// store fcm reg token if not exists
	_, err = database.DB.Exec(context.Background(), `
		INSERT INTO fcm_reg_tokens (token, user_id)
		VALUES ($1, $2)
		ON CONFLICT (token) DO NOTHING;`,
		reqBody.FCMtoken, res.Athlete.ID)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Write([]byte(facetAccessToken))
}
