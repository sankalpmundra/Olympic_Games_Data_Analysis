/* Which nation(s) has participated in every Olympic edition? */

WITH APPEARENCES_BY_COUNTRY AS (
    SELECT N.REGION AS "Country",
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    GROUP BY N.REGION
)
SELECT "Country" AS "Countries Participating in Each Olympics"
FROM APPEARENCES_BY_COUNTRY
WHERE "Olympic Appearences" = (SELECT COUNT(DISTINCT GAMES) 
                               FROM ATHLETE_EVENTS_SM);