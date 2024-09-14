package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"github.com/joho/godotenv"
	"github.com/roy-rishi/facet/app_links"
	"github.com/roy-rishi/facet/auth"
	"github.com/roy-rishi/facet/database"
	"github.com/roy-rishi/facet/strava"
	"github.com/roy-rishi/facet/web_host"
	"google.golang.org/api/option"
)

func main() {
	log.Println("Loading env from .env")
	godotenv.Load(".env")
	port := os.Getenv("PORT")

	// connect to database
	log.Println("Connecting to database at DATABASE_URL from .env")
	database.ConnectToDB()

	// initate Firebase
	log.Println("Initializing Firebase with credentials at assets/private/serviceAccountKey.json")
	opt := option.WithCredentialsFile("assets/private/serviceAccountKey.json")
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("Error initializing app: %v", err)
	}
	ctx := context.Background()
	client, err := app.Messaging(ctx)
	if err != nil {
		log.Fatalf("Error getting Messaging client: %v\n", err)
	}
	// <send test message>
	// TODO: use actual reg. token from database of clients
	registrationToken := "dteI2AADSPOe4YegoxrIjS:APA91bEPZhsR-AhMjf2a434mV1w4t5YuPmamw9U-i6gLcBZHwhBbaHP8mWdP6CBVeRM54psCu7dAnj_7noM0cqJLEAAN0s-9OXxBxE2SchbcNqT8DX7HHsnTwEvL3TXuAXeE1dN1G64K"
	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: "Facet via Server",
			Body:  "Test message is working!",
		},
		Token: registrationToken,
	}
	response, err := client.Send(ctx, message)
	if err != nil {
		log.Fatalln(err)
	}
	log.Println("Successfully sent message:", response)
	// </ send test message>

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
