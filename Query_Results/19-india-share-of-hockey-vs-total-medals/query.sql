/* What share of India's Olympic medals is it's most successful sport? */

WITH INDIA_OLYMPIC_MEDALS AS (
    SELECT DISTINCT GAMES AS "Olympic Games",
           COUNT(CASE 
                     WHEN NOC = 'IND' AND 
                          MEDAL <> 'NA' AND 
                          SPORT = 'Hockey' THEN 1 
                     ELSE NULL 
                 END) OVER(PARTITION BY GAMES) AS "Hockey Medals",
           COUNT(CASE 
                     WHEN NOC = 'IND' AND 
                          MEDAL <> 'NA' THEN 1 
                     ELSE NULL 
                 END) OVER(PARTITION BY GAMES) AS "Total Medals"
    FROM ATHLETE_EVENTS_SM
)
SELECT "Olympic Games",
       "Hockey Medals",
       "Total Medals",
       (CASE
           WHEN "Total Medals" = 0 THEN 0
           ELSE ROUND(("Hockey Medals" / "Total Medals") * 100, 2)
        END) AS "% Hockey Medals"
FROM INDIA_OLYMPIC_MEDALS
ORDER BY "Olympic Games" ASC;