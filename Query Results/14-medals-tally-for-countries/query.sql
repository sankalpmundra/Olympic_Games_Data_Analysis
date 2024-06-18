/* How many medals has each country won in the Olympics? */

SELECT N.REGION AS "Country",
       COUNT(CASE WHEN MEDAL = 'Gold' THEN 1 ELSE NULL END) AS "Gold",
       COUNT(CASE WHEN MEDAL = 'Silver' THEN 1 ELSE NULL END) AS "Silver",
       COUNT(CASE WHEN MEDAL = 'Bronze' THEN 1 ELSE NULL END) AS "Bronze",
       COUNT(CASE WHEN MEDAL <> 'NA' THEN 1 ELSE NULL END) AS "Total"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
GROUP BY N.REGION
ORDER BY "Total" DESC,
         "Gold" DESC,
         "Silver" DESC,
         "Bronze" DESC;