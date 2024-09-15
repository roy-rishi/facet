package firebase

import (
	"context"
	"log"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"google.golang.org/api/option"
)

var app *firebase.App
var client *messaging.Client

func InitializeFirebaseFCM() {
	serviceAccountKeyPath := "assets/private/serviceAccountKey.json"
	log.Println("Initializing Firebase with", serviceAccountKeyPath)
	opt := option.WithCredentialsFile(serviceAccountKeyPath)
	var err error
	app, err = firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatalf("Error initializing app: %v", err)
	}
	ctx := context.Background()
	client, err = app.Messaging(ctx)
	if err != nil {
		log.Fatalf("Error getting messaging client: %v\n", err)
	}
}

func PushNotificationToClient(title string, body string, regToken string) {
	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Token: regToken,
	}
	response, err := client.Send(context.Background(), message)
	if err != nil {
		log.Fatalln(err)
	}
	log.Println("Sent message:", response)
}
