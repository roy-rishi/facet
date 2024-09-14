# facet
insights into every facet of your bike. built with Flutter and Go

## setup
### variables
configure the server by writing the following to `server/.env`
```
PORT=<server_port>
DATABASE_URL=postgres://<remainder_of_url>

# Strava API
CLIENT_ID=<client_id>
CLIENT_SECRET=<client_secret>
WEBHOOK_VERIFY_TOKEN=<any_random_token>
```

to sign Android Apps, write the following to `app/android/key.properties`
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<keystore-file-location>
```

### web build
run `flutter build web` and copy resulting web build files into `server/assets/public`

### database
a database and tables must be created manually

### setup firebase
TODO: instructions
- setup instructions for Flutter in Firebase Console
- server: https://firebase.google.com/docs/cloud-messaging/auth-server
- see .gitignore for expected Firebase files
