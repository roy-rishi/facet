package auth

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"github.com/roy-rishi/facet/cors"
	"github.com/roy-rishi/facet/database"
)

type postBody struct {
	AccessToken string
}

func VerifyHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("POST /verify")
	cors.SetCORS(&w)

	var reqBody postBody
	err := json.NewDecoder(r.Body).Decode(&reqBody)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		log.Println(err.Error())
		return
	}
	accessToken := reqBody.AccessToken

	// check if access token exists and has not expired
	res, err2 := database.DB.Query(context.Background(), "SELECT user_id FROM credentials WHERE access_token = $1 AND NOW() < expiration", accessToken)
	if err2 != nil {
		http.Error(w, err2.Error(), http.StatusBadRequest)
		log.Println(err2.Error())
		return
	}
	defer res.Close()
	if res.Next() {
		// token is valid
		log.Println("token is valid")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(""))
		return
	}
	log.Println("token not valid")
	w.WriteHeader(http.StatusUnauthorized)
	w.Write([]byte(""))
}
