/* Which sport(s) has been played in every Summer Olympic edition? */

WITH SUMMER_SPORTS AS (
    SELECT SPORT AS "Sport",
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM
    WHERE GAMES LIKE '%Summer%'
    GROUP BY SPORT
)
SELECT "Sport" AS "Sports Played in Every Summer Olympics"
FROM SUMMER_SPORTS
WHERE "Olympic Appearences" = (SELECT COUNT(DISTINCT GAMES)
                               FROM ATHLETE_EVENTS_SM
                               WHERE GAMES LIKE '%Summer%');