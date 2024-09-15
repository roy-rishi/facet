CREATE TABLE public.users (
    id INTEGER NOT NULL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    username TEXT NOT NULL,
    profile_image TEXT NOT NULL,
    profile_image_medium TEXT NOT NULL,
    bio TEXT NOT NULL,
    strava_refresh_token TEXT,
    strava_access_token TEXT,
    accessRevoked BOOLEAN DEFAULT FALSE
);

CREATE TABLE public.credentials (
    access_token TEXT NOT NULL PRIMARY KEY,
    expiration TIMESTAMPTZ NOT NULL,
    user_id INTEGER REFERENCES users(id)
);

CREATE TABLE public.fcm_reg_tokens (
    token TEXT NOT NULL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id)
);

SET timezone = 'America/Los_Angeles';

INSERT INTO credentials (user_id, access_token, expiration) VALUES (44597161, 'accesstokentestvalue', '2006-01-02 15:04:05 -07:00');

-- DELETE all expired access tokens
DELETE FROM credentials WHERE NOW() > expiration;

-- SELECT the valid user_id for the access token, if exists
SELECT user_id FROM credentials WHERE access_token = 'u7FEu2skNwo1Ano9WHCqmJFBwoy9Vn8iq1Yx0bFk' AND NOW() < expiration;

-- revoke access
UPDATE users SET accessRevoked = TRUE WHERE id = IDIDID;


-- INSERT
INSERT INTO users (id, first_name, last_name, username, profile_image, profile_image_medium, bio, facet_refresh_token, strava_refresh_token, strava_access_token)
    VALUES (...);

-- UPSERT
INSERT INTO users (id, first_name, last_name, username, profile_image, profile_image_medium, bio, facet_refresh_token, strava_refresh_token, strava_access_token) 
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    ON CONFLICT(id)
    DO UPDATE SET first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name, username = EXCLUDED.username, profile_image = EXCLUDED.profile_image, profile_image_medium = EXCLUDED.profile_image_medium, bio = EXCLUDED.bio, facet_refresh_token = EXCLUDED.facet_refresh_token, strava_refresh_token = EXCLUDED.strava_refresh_token, strava_access_token = EXCLUDED.strava_access_token;
