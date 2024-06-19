/* Who were the oldest athletes to ever win a Gold medal in the Olympics? */

WITH OLD_AND_GOLD_ATHLETES AS (
    SELECT ID, NAME, SEX, AGE, TEAM, NOC, GAMES, CITY, SPORT, EVENT, MEDAL,
           RANK() OVER(ORDER BY AGE DESC) AS "Ranking"
    FROM ATHLETE_EVENTS_SM
    WHERE MEDAL = 'Gold' AND AGE <> 'NA'
)
SELECT ID, NAME, SEX, AGE, TEAM, NOC, GAMES, CITY, SPORT, EVENT, MEDAL
FROM OLD_AND_GOLD_ATHLETES
WHERE "Ranking" = 1;