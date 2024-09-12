CREATE TABLE public.users (
    id INTEGER NOT NULL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    facet_refresh_token TEXT NOT NULL,
    strava_refresh_token TEXT NOT NULL,
    strava_access_token TEXT NOT NULL
);

INSERT INTO users (id, first_name, last_name, facet_refresh_token, strava_refresh_token, strava_access_token)
    VALUES (44597161, 'Rishi', 'Roy', 'i', 'love', 'meek');
