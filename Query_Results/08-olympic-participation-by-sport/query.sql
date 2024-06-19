/* How many sports have been played in each Olympic edition? */

SELECT GAMES AS "Olympic Games",
       COUNT(DISTINCT SPORT) AS "Sports Played"
FROM ATHLETE_EVENTS_SM
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;