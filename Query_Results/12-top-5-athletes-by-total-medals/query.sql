/* Who are the top 5 athletes with the most medals (gold/silver/bronze) in total? */

WITH MEDALS_TALLY AS (
    SELECT ID, NAME, COUNT(*) AS "Total Medals",
           RANK() OVER(ORDER BY COUNT(*) DESC, ID ASC) AS "Ranking"
    FROM ATHLETE_EVENTS_SM
    WHERE MEDAL <> 'NA'
    GROUP BY ID, NAME
)
SELECT ID, NAME, "Total Medals"
FROM MEDALS_TALLY
WHERE "Ranking" <= 5;