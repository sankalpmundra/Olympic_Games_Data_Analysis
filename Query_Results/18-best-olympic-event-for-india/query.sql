/* In which Olympic sport and event has India won the most medals? */

WITH INDIA_OLYMPIC_MEDALS AS (
    SELECT SPORT AS "Sport", 
           EVENT AS "Event", 
           COUNT(*) AS "Medals",
           DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS "Ranking"
    FROM ATHLETE_EVENTS_SM
    WHERE NOC = 'IND' AND MEDAL <> 'NA'
    GROUP BY SPORT, EVENT
)
SELECT "Sport", "Event", "Medals"
FROM INDIA_OLYMPIC_MEDALS
WHERE "Ranking" = 1;