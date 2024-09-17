package firebase

import (
	"context"
	"log"
	"strings"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"github.com/roy-rishi/facet/database"
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
		log.Println(err)
		if strings.Contains(err.Error(), "code: registration-token-not-registered") {
			// token has been unregistered (likely due to an app uninstall), so remove it from db
			log.Println("Removing from db fcm token", regToken)
			_, dbErr := database.DB.Exec(context.Background(), `DELETE FROM fcm_reg_tokens WHERE token=$1`, regToken)
			if dbErr != nil {
				log.Println(dbErr.Error())
				return
			}
			return
		}
	}
	log.Println("Sent message:", response)
}
