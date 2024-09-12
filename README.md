# facet
insights into every facet of your bike. built with Flutter and Go

## setup
### variables
configure the server by writing the following to `server/.env`
```
PORT=3010
# Strava API https://www.strava.com/settings/api
CLIENT_ID=<client_id>
CLIENT_SECRET=<client_secret>
DATABASE_URL=postgres://<remainder_of_url>
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
