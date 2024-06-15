----------------------------- Intermediate Queries ----------------------------

/* How many olympics games have been held? */

SELECT COUNT(DISTINCT GAMES) AS "Total Olympic Games"
FROM ATHLETE_EVENTS_SM;


/* List down all Olympics games held so far */

SELECT DISTINCT GAMES AS "Olympic Games"
FROM ATHLETE_EVENTS_SM
ORDER BY "Olympic Games" ASC;

/* Mention the total no of nations who participated in each olympics game? */

SELECT GAMES AS "Olympic Games", 
       COUNT(DISTINCT NOC) AS "Total Participating Nations"
FROM ATHLETE_EVENTS_SM
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;


/* 
Which year saw the highest and lowest no of countries participating 
in the olympics? 
*/

WITH SUMMER_ANALYSIS AS (
    SELECT GAMES AS "Olympic Games", 
           COUNT(DISTINCT NOC) AS "Total Participating Nations"
    FROM ATHLETE_EVENTS_SM
    WHERE GAMES LIKE '%Summer%'
    GROUP BY GAMES
), WINTER_ANALYSIS AS (
    SELECT GAMES AS "Olympic Games", 
           COUNT(DISTINCT NOC) AS "Total Participating Nations"
    FROM ATHLETE_EVENTS_SM
    WHERE GAMES LIKE '%Winter%'
    GROUP BY GAMES
), HIGHEST_SUMMER AS (
    SELECT *
    FROM SUMMER_ANALYSIS
    ORDER BY "Total Participating Nations" DESC
    FETCH FIRST 1 ROWS ONLY
), HIGHEST_WINTER AS (
    SELECT *
    FROM WINTER_ANALYSIS
    ORDER BY "Total Participating Nations" DESC
    FETCH FIRST 1 ROWS ONLY
), LOWEST_SUMMER AS (
    SELECT *
    FROM SUMMER_ANALYSIS
    ORDER BY "Total Participating Nations" ASC
    FETCH FIRST 1 ROWS ONLY
), LOWEST_WINTER AS (
    SELECT *
    FROM WINTER_ANALYSIS
    ORDER BY "Total Participating Nations" ASC
    FETCH FIRST 1 ROWS ONLY
)
SELECT * FROM HIGHEST_SUMMER
UNION ALL
SELECT * FROM HIGHEST_WINTER
UNION ALL
SELECT '------------', NULL FROM dual
UNION ALL
SELECT * FROM LOWEST_SUMMER
UNION ALL
SELECT * FROM LOWEST_WINTER;


/* Which nation(s) has participated in all of the olympic games? */

WITH CTE AS (
    SELECT NOC,
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM
    GROUP BY NOC
)
SELECT C.NOC, N.REGION
FROM CTE C
INNER JOIN NOC_REGIONS_SM N ON C.NOC = N.NOC
WHERE "Olympic Appearences" = (SELECT COUNT(DISTINCT GAMES) 
                               FROM ATHLETE_EVENTS_SM);


/* Identify the sport which was played in all summer olympics */

WITH CTE AS (
    SELECT SPORT AS "Sport",
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM
    WHERE GAMES LIKE '%Summer%'
    GROUP BY SPORT
)
SELECT "Sport" AS "Sports Played in Every Summer Olympics"
FROM CTE
WHERE "Olympic Appearences" = (SELECT COUNT(DISTINCT GAMES)
                               FROM ATHLETE_EVENTS_SM
                               WHERE GAMES LIKE '%Summer%');


/* Which Sports were just played only once in the olympics? */

WITH CTE AS (
    SELECT SPORT AS "Sport",
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM
    GROUP BY SPORT
)
SELECT "Sport" AS "One-Time Olympic Sports"
FROM CTE
WHERE "Olympic Appearences" = 1;


/* Fetch the total no of sports played in each olympic games */

SELECT GAMES AS "Olympic Games",
       COUNT(DISTINCT SPORT) AS "Sports Played"
FROM ATHLETE_EVENTS_SM
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;


/* Fetch details of the oldest athletes to win a gold medal */

SELECT ID, NAME, SEX, AGE, TEAM, NOC, GAMES, CITY, SPORT, EVENT
FROM ATHLETE_EVENTS_SM
WHERE MEDAL = 'Gold' AND AGE NOT LIKE '%NA%'
ORDER BY AGE DESC, GAMES DESC
FETCH FIRST 10 ROWS ONLY;


/* 
Find the Ratio of male and female athletes that participated in all 
olympic games.
*/

WITH GENDER_TALLY AS (
    SELECT (SELECT COUNT(DISTINCT ID) 
            FROM ATHLETE_EVENTS_SM 
            WHERE SEX = 'M') AS "Males",
           (SELECT COUNT(DISTINCT ID) 
            FROM ATHLETE_EVENTS_SM 
            WHERE SEX = 'F') AS "Females"
    FROM ATHLETE_EVENTS_SM
    FETCH FIRST 1 ROWS ONLY
)
SELECT "Males",
       "Females",
       ROUND("Males" / "Females", 5) AS "M/F Ratio" 
FROM GENDER_TALLY;


/* Fetch the top 5 athletes who have won the most gold medals */

SELECT ID, 
       NAME, 
       COUNT(*) AS "Gold Medals"
FROM ATHLETE_EVENTS_SM
WHERE MEDAL = 'Gold'
GROUP BY ID, NAME
ORDER BY "Gold Medals" DESC, 
         ID ASC
FETCH FIRST 5 ROWS ONLY;

SELECT DISTINCT ID,
       NAME,
       COUNT(*) OVER(PARTITION BY ID, NAME) AS "Gold Medals"
FROM ATHLETE_EVENTS_SM
WHERE MEDAL = 'Gold'
ORDER BY "Gold Medals" DESC, 
         ID ASC
FETCH FIRST 5 ROWS ONLY;


/* Fetch the top 5 athletes who have won the most medals (gold/silver/bronze) */

SELECT ID, 
       NAME, 
       COUNT(*) AS "Total Medals"
FROM ATHLETE_EVENTS_SM
WHERE MEDAL NOT LIKE '%NA%'
GROUP BY ID, NAME
ORDER BY "Total Medals" DESC, 
         ID ASC
FETCH FIRST 5 ROWS ONLY;

SELECT DISTINCT ID,
       NAME,
       COUNT(*) OVER(PARTITION BY ID, NAME) AS "Total Medals"
FROM ATHLETE_EVENTS_SM
WHERE MEDAL NOT LIKE '%NA%'
ORDER BY "Total Medals" DESC, 
         ID ASC
FETCH FIRST 5 ROWS ONLY;


/*
Fetch the top 5 most successful countries in olympics. 
Success is defined by no of medals won.
*/

SELECT A.NOC AS "Code", 
       N.REGION AS "Country",
       COUNT(*) AS "Total Medals"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
WHERE MEDAL NOT LIKE '%NA%'
GROUP BY A.NOC, N.REGION
ORDER BY "Total Medals" DESC
FETCH FIRST 5 ROWS ONLY;

SELECT DISTINCT A.NOC AS "Code", 
       N.REGION AS "Country",
       COUNT(*) OVER(PARTITION  BY A.NOC, N.REGION) AS "Total Medals"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
WHERE MEDAL NOT LIKE '%NA%'
ORDER BY "Total Medals" DESC
FETCH FIRST 5 ROWS ONLY;


/* List down total gold, silver and broze medals won by each country */

SELECT A.NOC AS "Code",
       N.REGION AS "Country",
       COUNT(CASE WHEN MEDAL = 'Gold' THEN 1 ELSE NULL END) AS "Gold",
       COUNT(CASE WHEN MEDAL = 'Silver' THEN 1 ELSE NULL END) AS "Silver",
       COUNT(CASE WHEN MEDAL = 'Bronze' THEN 1 ELSE NULL END) AS "Bronze",
       COUNT(CASE WHEN MEDAL NOT LIKE '%NA%' THEN 1 ELSE NULL END) AS "Total"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
GROUP BY A.NOC, N.REGION
ORDER BY "Total" DESC,
         "Gold" DESC,
         "Silver" DESC,
         "Bronze" DESC;


/*
List down total gold, silver and broze medals won by each country 
corresponding to each olympic games
*/

SELECT A.GAMES AS "Olympic Games", 
       A.NOC AS "Code",
       N.REGION AS "Country",
       COUNT(CASE WHEN MEDAL = 'Gold' THEN 1 ELSE NULL END) AS "Gold",
       COUNT(CASE WHEN MEDAL = 'Silver' THEN 1 ELSE NULL END) AS "Silver",
       COUNT(CASE WHEN MEDAL = 'Bronze' THEN 1 ELSE NULL END) AS "Bronze",
       COUNT(CASE WHEN MEDAL NOT LIKE '%NA%' THEN 1 ELSE NULL END) AS "Total"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
GROUP BY A.GAMES, A.NOC, N.REGION
ORDER BY "Olympic Games" ASC, 
         "Total" DESC,
         "Gold" DESC,
         "Silver" DESC,
         "Bronze" DESC;


/*
Identify which country won the most gold, most silver and most bronze 
medals in each olympic games
*/

WITH MEDALS_TALLY AS (
    SELECT DISTINCT A.GAMES AS "Olympic Games", 
           A.NOC AS "Code",
           N.REGION AS "Country",
           COUNT(CASE WHEN MEDAL = 'Gold' THEN 1 ELSE NULL END) 
                OVER(PARTITION BY A.GAMES, A.NOC, N.REGION) AS "Gold",
           COUNT(CASE WHEN MEDAL = 'Silver' THEN 1 ELSE NULL END) 
                OVER(PARTITION BY A.GAMES, A.NOC, N.REGION) AS "Silver",
           COUNT(CASE WHEN MEDAL = 'Bronze' THEN 1 ELSE NULL END) 
                OVER(PARTITION BY A.GAMES, A.NOC, N.REGION) AS "Bronze",
           COUNT(CASE WHEN MEDAL NOT LIKE '%NA%' THEN 1 ELSE NULL END) 
                OVER(PARTITION BY A.GAMES, A.NOC, N.REGION) AS "Total"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    ORDER BY "Olympic Games" ASC, 
             "Total" DESC,
             "Gold" DESC,
             "Silver" DESC,
             "Bronze" DESC
), TALLY_ANALYSIS AS (
    SELECT "Olympic Games", 
           "Code", 
           "Country", 
           "Gold", 
           "Silver", 
           "Bronze", 
           "Total",
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
       "Country" || ' (' || "Code" || ')' AS "Most Successful Country",
       "Gold", 
       "Silver", 
       "Bronze", 
       "Total"
FROM TALLY_ANALYSIS
WHERE "Overall Ranking" = 1;


/*
Identify which country won the most gold, most silver, most bronze 
medals and the most medals in each olympic games
*/

WITH MEDALS_TALLY AS (
    SELECT DISTINCT A.GAMES AS "Olympic Games", 
           A.NOC AS "Code",
           N.REGION AS "Country",
           COUNT(CASE WHEN MEDAL = 'Gold' THEN 1 ELSE NULL END) 
                OVER(PARTITION BY A.GAMES, A.NOC, N.REGION) AS "Gold",
           COUNT(CASE WHEN MEDAL = 'Silver' THEN 1 ELSE NULL END) 
                OVER(PARTITION BY A.GAMES, A.NOC, N.REGION) AS "Silver",
           COUNT(CASE WHEN MEDAL = 'Bronze' THEN 1 ELSE NULL END) 
                OVER(PARTITION BY A.GAMES, A.NOC, N.REGION) AS "Bronze",
           COUNT(CASE WHEN MEDAL NOT LIKE '%NA%' THEN 1 ELSE NULL END) 
                OVER(PARTITION BY A.GAMES, A.NOC, N.REGION) AS "Total"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    ORDER BY "Olympic Games" ASC, 
             "Total" DESC,
             "Gold" DESC,
             "Silver" DESC,
             "Bronze" DESC
), TALLY_ANALYSIS AS (
    SELECT "Olympic Games", 
           "Code", 
           "Country", 
           "Gold", 
           "Silver", 
           "Bronze", 
           "Total",
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
       "Country" || ' (' || "Code" || ')' AS "Most Successful Country",
       "Gold", 
       "Silver", 
       "Bronze", 
       "Total"
FROM TALLY_ANALYSIS
WHERE "Overall Ranking" = 1;


/* 
Which countries have never won gold medals but have won silver/bronze medals? 
*/

WITH MEDALS_TABLE AS (
    SELECT A.NOC AS "Code",
           N.REGION AS "Country",
           COUNT(CASE WHEN MEDAL = 'Gold' THEN 1 ELSE NULL END) AS "Gold",
           COUNT(CASE WHEN MEDAL = 'Silver' THEN 1 ELSE NULL END) AS "Silver",
           COUNT(CASE WHEN MEDAL = 'Bronze' THEN 1 ELSE NULL END) AS "Bronze",
           COUNT(CASE WHEN MEDAL NOT LIKE '%NA%' THEN 1 ELSE NULL END) AS "Total"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    GROUP BY A.NOC, N.REGION
    ORDER BY "Total" DESC,
             "Gold" DESC,
             "Silver" DESC,
             "Bronze" DESC
)
SELECT *
FROM MEDALS_TABLE
WHERE "Total" > 0 AND "Gold" = 0
ORDER BY "Total" DESC, 
         "Silver" DESC, 
         "Bronze" DESC;


/* In which Sport/event, India has won highest medals */

WITH INDIA_OLYMPIC_MEDALS AS (
    SELECT SPORT, 
           EVENT, 
           COUNT(*) AS "MEDALS",
           DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS "RANKING"
    FROM ATHLETE_EVENTS_SM
    WHERE NOC = 'IND' AND MEDAL NOT LIKE '%NA%'
    GROUP BY SPORT, EVENT
    ORDER BY "MEDALS" DESC
)
SELECT SPORT, 
       EVENT, 
       MEDALS
FROM INDIA_OLYMPIC_MEDALS
FETCH FIRST 1 ROWS ONLY;


/*
Break down all olympic games where india won medal for Hockey and how 
many medals in each olympic games
*/

WITH INDIA_OLYMPIC_MEDALS AS (
    SELECT DISTINCT GAMES AS "Olympic Games",
           COUNT(CASE 
                     WHEN NOC = 'IND' AND 
                          MEDAL NOT LIKE '%NA%' AND 
                          SPORT = 'Hockey' THEN 1 
                     ELSE NULL 
                 END) OVER(PARTITION BY GAMES) AS "Hockey Medals",
           COUNT(CASE 
                     WHEN NOC = 'IND' AND 
                          MEDAL NOT LIKE '%NA%' THEN 1 
                     ELSE NULL 
                 END) OVER(PARTITION BY GAMES) AS "Total Medals"
    FROM ATHLETE_EVENTS_SM
    ORDER BY GAMES ASC
)
SELECT "Olympic Games",
       "Hockey Medals",
       "Total Medals",
       CASE
           WHEN "Total Medals" = 0 THEN 0
           ELSE ROUND(("Hockey Medals"/"Total Medals") * 100, 2)
       END AS "% Hockey Medals"
FROM INDIA_OLYMPIC_MEDALS;

/* Trend of women participation by summer olympic editions */

SELECT GAMES AS "Olympic Games", 
       COUNT(DISTINCT ID) AS "Female Athletes"
FROM ATHLETE_EVENTS_SM
WHERE SEX = 'F' AND GAMES LIKE '%Summer%'
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;


/*
I have made a bar chart to visualize the trend of female participation
in olympic games and pasted it on the pdf document.
*/


------- Shortcuts:

DESC ATHLETE_EVENTS_SM;
DESC NOC_REGIONS_SM;

SELECT * FROM ATHLETE_EVENTS_SM;
SELECT * FROM NOC_REGIONS_SM;
-------------------------------------------------------------------------------