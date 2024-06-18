/* Has female participation in the Summer Olympics grown over time? */

SELECT GAMES AS "Olympic Games", 
       COUNT(DISTINCT ID) AS "Female Athletes"
FROM ATHLETE_EVENTS_SM
WHERE SEX = 'F' AND GAMES LIKE '%Summer%'
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;