/* Which sport(s) has been played only once in the Olympics? */

WITH OLYMPIC_SPORTS AS (
    SELECT SPORT AS "Sport",
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM
    GROUP BY SPORT
)
SELECT "Sport" AS "One-Time Olympic Sports"
FROM OLYMPIC_SPORTS
WHERE "Olympic Appearences" = 1;