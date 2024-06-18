/* Which were the top performing countries in each Olympic edition? */

WITH MEDALS_TALLY AS (
    SELECT DISTINCT A.GAMES AS "Olympic Games",
                    N.REGION AS "Country",
                    COUNT(CASE WHEN MEDAL = 'Gold' THEN 1 ELSE NULL END) 
                        OVER(PARTITION BY A.GAMES, N.REGION) AS "Gold",
                    COUNT(CASE WHEN MEDAL = 'Silver' THEN 1 ELSE NULL END) 
                        OVER(PARTITION BY A.GAMES, N.REGION) AS "Silver",
                    COUNT(CASE WHEN MEDAL = 'Bronze' THEN 1 ELSE NULL END) 
                        OVER(PARTITION BY A.GAMES, N.REGION) AS "Bronze",
                    COUNT(CASE WHEN MEDAL <> 'NA' THEN 1 ELSE NULL END) 
                        OVER(PARTITION BY A.GAMES, N.REGION) AS "Total"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    ORDER BY "Olympic Games" ASC, 
             "Total" DESC,
             "Gold" DESC,
             "Silver" DESC,
             "Bronze" DESC
), TALLY_ANALYSIS AS (
    SELECT "Olympic Games", "Country", "Gold", "Silver", "Bronze", "Total",
            DENSE_RANK() OVER(PARTITION BY "Olympic Games"
                              ORDER BY "Gold" DESC) AS "Gold Ranking",
            DENSE_RANK() OVER(PARTITION BY "Olympic Games"
                              ORDER BY "Silver" DESC) AS "Silver Ranking",
            DENSE_RANK() OVER(PARTITION BY "Olympic Games"
                              ORDER BY "Bronze" DESC) AS "Bronze Ranking",
            DENSE_RANK() OVER(PARTITION BY "Olympic Games"
                              ORDER BY "Total" DESC) AS "Overall Ranking"
    FROM MEDALS_TALLY
    ORDER BY "Olympic Games" ASC, 
             "Overall Ranking" ASC
)
SELECT "Olympic Games",
       "Country" AS "Most Successful Country",
       "Gold", 
       "Silver", 
       "Bronze", 
       "Total"
FROM TALLY_ANALYSIS
WHERE "Overall Ranking" = 1;