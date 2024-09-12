CREATE TABLE public.users (
    id INTEGER NOT NULL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    username TEXT NOT NULL,
    profile_image TEXT NOT NULL,
    profile_image_medium TEXT NOT NULL,
    bio TEXT NOT NULL,

    facet_refresh_token TEXT NOT NULL,
    strava_refresh_token TEXT NOT NULL,
    strava_access_token TEXT NOT NULL
);

-- INSERT
INSERT INTO users (id, first_name, last_name, username, profile_image, profile_image_medium, bio, facet_refresh_token, strava_refresh_token, strava_access_token)
    VALUES (...);

-- UPSERT
INSERT INTO users (id, first_name, last_name, username, profile_image, profile_image_medium, bio, facet_refresh_token, strava_refresh_token, strava_access_token) 
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    ON CONFLICT(id)
    DO UPDATE SET first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, username = EXCLUDED.username, profile_image = EXCLUDED.profile_image, profile_image_medium = EXCLUDED.profile_image_medium, bio = EXCLUDED.bio, facet_refresh_token = EXCLUDED.facet_refresh_token, strava_refresh_token = EXCLUDED.strava_refresh_token, strava_access_token = EXCLUDED.strava_access_token;
