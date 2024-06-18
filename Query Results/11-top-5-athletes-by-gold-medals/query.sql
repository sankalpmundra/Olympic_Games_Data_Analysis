/* Who are the top 5 athletes with the most gold medals? */

WITH GOLD_TALLY AS (
    SELECT ID, NAME, COUNT(*) AS "Gold Medals",
           RANK() OVER(ORDER BY COUNT(*) DESC, ID ASC) AS "Ranking"
    FROM ATHLETE_EVENTS_SM
    WHERE MEDAL = 'Gold'
    GROUP BY ID, NAME
)
SELECT ID, 
       NAME AS "Name", 
       "Gold Medals"
FROM GOLD_TALLY
WHERE "Ranking" <= 5;