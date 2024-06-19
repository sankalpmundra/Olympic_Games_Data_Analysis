/* Which year saw the highest and lowest number of countries participating in the Olympics? */

WITH OLYMPIC_PARTICIPATION AS (
    SELECT A.GAMES AS "Olympic Games", 
           COUNT(DISTINCT N.REGION) AS "Countries"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    GROUP BY A.GAMES
)
SELECT FIRST_VALUE("Olympic Games" || ' (' || "Countries" || ' nations)') 
                    OVER(ORDER BY "Countries" ASC) AS "Lowest Participation",
       FIRST_VALUE("Olympic Games" || ' (' || "Countries" || ' nations)') 
                    OVER(ORDER BY "Countries" DESC) AS "Highest Participation"
FROM OLYMPIC_PARTICIPATION
FETCH FIRST 1 ROWS ONLY;