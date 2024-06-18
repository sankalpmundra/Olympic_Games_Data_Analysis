# Olympic Games Data Analysis

This repository contains a comprehensive analysis of the [Olympic Games](https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results) dataset from Kaggle. The analysis was conducted using SQL queries to answer various questions about the dataset and discover interesting findings and patterns in the Olympic games, athletes, nations, and sports.

## Database Schema

This dataset contains two tables: `noc_regions_sm` and `athlete_events_sm`. The former is a lookup table for all the countries that have participated in the Olympics and their unique 3-letter codes in the competition and the latter is the main table storing each record of a participation by an athlete in a specific sport and event, and what medal they won (if they did). 

``` SQL [] 
DESC ATHLETE_EVENTS_SM;
DESC NOC_REGIONS_SM;
```

### Table: noc_regions_sm

This table contains information about the National Olympic Committees (NOCs) and regions.

| Column Name | Data Type    | Nullable | Description                     |
| :---------- | :----------- | :------- | :------------------------------ |
| NOC         | CHAR(3)      | No       | National Olympic Committee code |
| REGION      | VARCHAR(50)  | No       | Country name                    |
| NOTES       | VARCHAR(128) | No       | Additional notes for the country |


### Table: athlete_events_sm

This table contains detailed information about athletes and their participation in various Olympic Games.

| Column Name | Data Type      | Nullable | Description                             |
| :---------- | :------------- | :------- | :-------------------------------------- |
| ID          | NUMBER(38, 0)  | No       | Unique identifier for each athlete      |
| NAME        | VARCHAR(128)   | No       | Athlete's name                          |
| SEX         | CHAR(1)        | No       | Athlete's sex (M/F)                     |
| AGE         | VARCHAR(38)    | Yes      | Athlete's age                           |
| HEIGHT      | VARCHAR(26)    | Yes      | Athlete's height                        |
| WEIGHT      | VARCHAR(26)    | Yes      | Athlete's weight                        |
| TEAM        | VARCHAR(50)    | No       | Team name                               |
| NOC         | VARCHAR(26)    | No       | National Olympic Committee code         |
| GAMES       | VARCHAR(50)    | No       | Year and season of the Olympic event    |
| YEAR        | NUMBER(4, 0)   | No       | Year of the Olympic event               |
| SEASON      | VARCHAR(26)    | No       | Season (Summer/Winter)                  |
| CITY        | VARCHAR(50)    | No       | Host city                               |
| SPORT       | VARCHAR(50)    | No       | Sport category                          |
| EVENT       | VARCHAR(128)   | No       | Specific event                          |
| MEDAL       | VARCHAR(26)    | Yes      | Medal won (Gold/Silver/Bronze/NA)       |

### Schema Diagram in the Crow's Foot Notation:

![DATABASE SCHEMA DIAGRAM PREVIEW](Database_Schema_Diagrams/schema_diagram.png?raw=true)

## Queries

### How many Olympics games have been held?

``` SQL []
SELECT COUNT(DISTINCT GAMES) AS "Total Olympic Games"
FROM ATHLETE_EVENTS_SM;
```

### List down all the different Olympics games held so far.

``` SQL []
SELECT DISTINCT GAMES AS "Olympic Games"
FROM ATHLETE_EVENTS_SM
ORDER BY "Olympic Games" ASC;
```

### How many countries have participated in each Olympics edition?

``` SQL []
SELECT A.GAMES AS "Olympic Games",
       COUNT(DISTINCT N.REGION) AS "Total Participating Countries"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
GROUP BY A.GAMES
ORDER BY "Olympic Games" ASC;
```

### Which year saw the highest and lowest number of countries participating in the Olympics? 

``` SQL []
WITH OLYMPIC_PARTICIPATION AS (
    SELECT A.GAMES AS "Olympic Games", 
           COUNT(DISTINCT N.REGION) AS "Countries"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    GROUP BY A.GAMES
)
SELECT FIRST_VALUE("Olympic Games" || ' (' || "Countries" || ' nations)') 
                    OVER(ORDER BY "Countries" ASC) AS "Lowest Participation",
       FIRST_VALUE("Olympic Games" || ' (' || "Countries" || ' nations)') 
                    OVER(ORDER BY "Countries" DESC) AS "Highest Participation"
FROM OLYMPIC_PARTICIPATION
FETCH FIRST 1 ROWS ONLY;
```

### Which nation(s) has participated in every Olympic edition?

``` SQL []
WITH APPEARENCES_BY_COUNTRY AS (
    SELECT N.REGION AS "Country",
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM A
    INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
    GROUP BY N.REGION
)
SELECT "Country" AS "Countries Participating in Each Olympics"
FROM APPEARENCES_BY_COUNTRY
WHERE "Olympic Appearences" = (SELECT COUNT(DISTINCT GAMES) 
                               FROM ATHLETE_EVENTS_SM);
```

### Which sport(s) has been played in every Summer Olympic edition?

``` SQL []
WITH SUMMER_SPORTS AS (
    SELECT SPORT AS "Sport",
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM
    WHERE GAMES LIKE '%Summer%'
    GROUP BY SPORT
)
SELECT "Sport" AS "Sports Played in Every Summer Olympics"
FROM SUMMER_SPORTS
WHERE "Olympic Appearences" = (SELECT COUNT(DISTINCT GAMES)
                               FROM ATHLETE_EVENTS_SM
                               WHERE GAMES LIKE '%Summer%');
```

### Which sport(s) has been played only once in the Olympics?

``` SQL []
WITH OLYMPIC_SPORTS AS (
    SELECT SPORT AS "Sport",
           COUNT(DISTINCT GAMES) AS "Olympic Appearences"
    FROM ATHLETE_EVENTS_SM
    GROUP BY SPORT
)
SELECT "Sport" AS "One-Time Olympic Sports"
FROM OLYMPIC_SPORTS
WHERE "Olympic Appearences" = 1;
```

### How many sports have been played in each Olympic edition?

``` SQL []
SELECT GAMES AS "Olympic Games",
       COUNT(DISTINCT SPORT) AS "Sports Played"
FROM ATHLETE_EVENTS_SM
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;
```

### Who were the oldest athletes to ever win a Gold medal in the Olympics?

``` SQL []
WITH OLD_AND_GOLD_ATHLETES AS (
    SELECT ID, NAME, SEX, AGE, TEAM, NOC, GAMES, CITY, SPORT, EVENT, MEDAL,
           RANK() OVER(ORDER BY AGE DESC) AS "Ranking"
    FROM ATHLETE_EVENTS_SM
    WHERE MEDAL = 'Gold' AND AGE <> 'NA'
)
SELECT ID, NAME, SEX, AGE, TEAM, NOC, GAMES, CITY, SPORT, EVENT, MEDAL
FROM OLD_AND_GOLD_ATHLETES
WHERE "Ranking" = 1;
```

### What is the ratio of male to female athletes in the Olympics?

``` SQL []
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
```

### Who are the top 5 athletes with the most gold medals?

``` SQL []
WITH GOLD_TALLY AS (
    SELECT ID, NAME, COUNT(*) AS "Gold Medals",
           RANK() OVER(ORDER BY COUNT(*) DESC, ID ASC) AS "Ranking"
    FROM ATHLETE_EVENTS_SM
    WHERE MEDAL = 'Gold'
    GROUP BY ID, NAME
)
SELECT ID, NAME, "Gold Medals"
FROM GOLD_TALLY
WHERE "Ranking" <= 5;
```

### Who are the top 5 athletes with the most medals (gold/silver/bronze) in total?

``` SQL []
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
```

### Who are the top 5 most successful countries in the Olympics? _Success is defined by the number of medals won._

``` SQL []
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
```


### How many medals has each country won in the Olympics?

``` SQL []
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
```

### How many medals has each country won in each Olympic edition?

``` SQL []
SELECT A.GAMES AS "Olympic Games", 
       N.REGION AS "Country",
       COUNT(CASE WHEN MEDAL = 'Gold' THEN 1 ELSE NULL END) AS "Gold",
       COUNT(CASE WHEN MEDAL = 'Silver' THEN 1 ELSE NULL END) AS "Silver",
       COUNT(CASE WHEN MEDAL = 'Bronze' THEN 1 ELSE NULL END) AS "Bronze",
       COUNT(CASE WHEN MEDAL <> 'NA' THEN 1 ELSE NULL END) AS "Total"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
GROUP BY A.GAMES, N.REGION
ORDER BY "Olympic Games" ASC, 
         "Total" DESC,
         "Gold" DESC,
         "Silver" DESC,
         "Bronze" DESC;
```

### Which were the top performing countries in each Olympic edition?

``` SQL []
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
```

### Which countries have only ever won silver or bronze medals in the Olympics? 

``` SQL []
WITH MEDALS_TABLE AS (
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
             "Bronze" DESC
)
SELECT *
FROM MEDALS_TABLE
WHERE "Total" > 0 AND "Gold" = 0
ORDER BY "Total" DESC, 
         "Silver" DESC, 
         "Bronze" DESC;
```


### In which Olympic sport and event has India won the most medals?

``` SQL []
WITH INDIA_OLYMPIC_MEDALS AS (
    SELECT SPORT, EVENT, COUNT(*) AS "MEDALS",
           DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS "RANKING"
    FROM ATHLETE_EVENTS_SM
    WHERE NOC = 'IND' AND MEDAL <> 'NA'
    GROUP BY SPORT, EVENT
)
SELECT SPORT, EVENT, MEDALS
FROM INDIA_OLYMPIC_MEDALS
WHERE "RANKING" = 1;
```

### What share of India's Olympic medals is it's most successful sport?

``` SQL []
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
```

### Has female participation in the Summer Olympics grown over time?

``` SQL []
SELECT GAMES AS "Olympic Games", 
       COUNT(DISTINCT ID) AS "Female Athletes"
FROM ATHLETE_EVENTS_SM
WHERE SEX = 'F' AND GAMES LIKE '%Summer%'
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;
```

