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
	registrationToken := "dLkdcKwqTxuuxdsQmS-yA1:APA91bHssF09ardP4q-sTRVsPCA99c-pj4BHTAv-BrqNIm_4ksT9i4i-6G6QqeL86EcJYDQBpR8CnYOefZCLlG_7HOxJJGBkkU4ozkZwZAzAQpBke0L8Afj3QMOqVCnF8Np0wm3MlWQU"
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

	server := &http.Server{
		Addr:         "127.0.0.1:" + port,
		WriteTimeout: 10 * time.Second,
		ReadTimeout:  10 * time.Second,
		Handler:      mux,
	}
	log.Printf("Server listening on port %v\n", port)
	server.ListenAndServe()
}
