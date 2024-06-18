/* What is the ratio of male to female athletes in the Olympics? */

WITH GENDER_TALLY AS (
    SELECT (SELECT COUNT(DISTINCT ID) 
            FROM ATHLETE_EVENTS_SM 
            WHERE SEX = 'M') AS "Male Athletes",
           (SELECT COUNT(DISTINCT ID) 
            FROM ATHLETE_EVENTS_SM 
            WHERE SEX = 'F') AS "Female Athletes"
    FROM ATHLETE_EVENTS_SM
    FETCH FIRST 1 ROWS ONLY
)
SELECT "Male Athletes",
       "Female Athletes",
       ROUND("Male Athletes" / "Female Athletes", 5) AS "M:F Ratio"
FROM GENDER_TALLY;