/* Who are the top 5 most successful countries in the Olympics? Success is defined by the number of medals won. */

WITH MEDALS_TALLY AS (
    SELECT N.REGION AS "Country",
           COUNT(*) AS "Total Medals",
           RANK() OVER(ORDER BY COUNT(*) DESC) AS "Ranking"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    WHERE MEDAL <> 'NA'
    GROUP BY N.REGION
)
SELECT "Country", "Total Medals"
FROM MEDALS_TALLY
WHERE "Ranking" <= 5;