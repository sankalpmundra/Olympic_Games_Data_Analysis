/* How many countries have participated in each Olympics edition? */

SELECT A.GAMES AS "Olympic Games",
       COUNT(DISTINCT N.REGION) AS "Total Participating Countries"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
GROUP BY A.GAMES
ORDER BY "Olympic Games" ASC;