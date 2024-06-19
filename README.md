# Olympic Games Data Analysis

This repository contains a comprehensive analysis of the [Olympic Games](https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results) dataset from Kaggle. This project was carried out to answer various questions about the dataset and discover interesting findings and patterns in the Olympic Games, athletes, nations, and sports. Also, because I am a huge fan of the Olympics— India's great performances in Hockey being my inspiration!

#### Tools Used:

- **SQL**: Querying and analyzing data from the Olympic Games dataset.
- **Oracle Database**: The Database Management System utilized for storing and querying the dataset.
- **Visual Studio Code (VS Code)**: Integrated development environment used for writing and executing the SQL queries and managing the resulting sets as CSV files. It was also used to prepare the markdown documents in this repository.
- **Lucidchart**: Creating the schema diagrams (ERDs) to visualize the structure of the Olympic Games dataset.
- **Microsoft Excel**: Graphing distributions and creating bar charts from the result sets of the SQL queries to visualize the data.

This analysis can be valuable for sports historians, data enthusiasts, and anyone interested in learning about the Olympic Games really. So read on and enjoy exploring some fascinating insights into one of the world's most celebrated sporting events!

## Database Schema

The Olympic Games dataset contains two tables: `noc_regions_sm` and `athlete_events_sm`. 

The former is a lookup table for all the countries that have taken part in the Olympics and their unique 3-letter National Olympic Committee codes, the `NOC`, which acts as the primary key for this table.

``` SQL []
DESC NOC_REGIONS_SM;
```

| Column Name | Data Type    | Nullable | Description                      |
| :---------- | :----------- | :------- | :------------------------------- |
| NOC         | CHAR(3)      | No       | National Olympic Committee code  |
| REGION      | VARCHAR(50)  | No       | Country name                     |
| NOTES       | VARCHAR(128) | No       | Additional notes for the country |

> **Note:** The `NOTES` column is for teams with more than one name, some old alias, or any other niche characteristics.

The latter is the main table that contains detailed information about athletes and their participation in the various Olympic Games. This table stores each record of a participation by an athlete, down to the specific sport and event, and what medal they won (if they did). It also documents the personal details of each athlete (e.g. name, age, weight, etc.) and the country they represented. Here, the `NOC` column is a foreign key to the previous lookup table. Finally, the `ID` column is the primary key for this table, which is used to uniquely identify each athlete that ever participated in the Olympic Games.

``` SQL []
DESC ATHLETE_EVENTS_SM;
```

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

---

### Schema Diagram in the Crow's Foot Notation:

![DATABASE SCHEMA DIAGRAM PREVIEW](Database_Schema_Diagrams/schema_diagram.png?raw=true)

---

## Queries

Here, I am presenting a series of SQL queries used to analyze the Olympic Games dataset. These queries answer a wide range of questions about the history and details of the Olympic Games.
Topics covered include the number of Olympic Games held, the countries and athletes who participated, medal counts, and specific achievements by nations and athletes. Each query is accompanied by a snippet of the result set to provide a glimpse of the findings, offering interesting insights into the Olympics.

> **Note:** Due to the large size of some result sets, only snippets are displayed here. For the
complete SQL result sets, please click on the provided hyperlinks.

---

### How many Olympics games have been held?

``` SQL []
SELECT COUNT(DISTINCT GAMES) AS "Total Olympic Games"
FROM ATHLETE_EVENTS_SM;
```

| Total Olympic Games |
| :------------------ |
| 51                  |

---

### Which Olympics games have been held so far?

``` SQL []
SELECT DISTINCT GAMES AS "Olympic Games"
FROM ATHLETE_EVENTS_SM
ORDER BY "Olympic Games" ASC;
```

| Olympic Games |
| :------------ |
| 1896 Summer   |
| 1900 Summer   |
| 1904 Summer   |
| 1906 Summer   |
| 1908 Summer   |
| ...           |
| 2012 Summer   |
| 2014 Winter   |
| 2016 Summer   |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/02-list-of-all-olympic-games/query_result.csv)

---

### How many countries have participated in each Olympics edition?

``` SQL []
SELECT A.GAMES AS "Olympic Games",
       COUNT(DISTINCT N.REGION) AS "Total Participating Countries"
FROM ATHLETE_EVENTS_SM A
INNER JOIN NOC_REGIONS_SM N ON A.NOC = N.NOC
GROUP BY A.GAMES
ORDER BY "Olympic Games" ASC;
```

| Olympic Games | Total Participating Countries |
| :------------ | ----------------------------: |
| 1896 Summer   | 12                            |
| 1900 Summer   | 31                            |
| 1904 Summer   | 14                            |
| 1906 Summer   | 20                            |
| 1908 Summer   | 22                            |
| ...           |                               |
| 2012 Summer   | 203                           |
| 2014 Winter   | 88                            |
| 2016 Summer   | 204                           |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/03-olympic-participation-by-country/query_result.csv)

---

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

| Lowest Participation      | Highest Participation     |
| :------------------------ | :------------------------ |
| 1896 Summer (12  nations) | 2016 Summer (204 nations) |

---

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

| Countries Participating in Each Olympics |
| :--------------------------------------- |
| Italy                                    |
| France                                   |
| UK                                       |
| Switzerland                              |

---

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

| Sports Played in Every Summer Olympics |
| :------------------------------------- |
| Athletics                              |
| Swimming                               |
| Cycling                                |
| Fencing                                |
| Gymnastics                             |

---

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

| One-Time Olympic Sports |
| :---------------------- |
| Roque                   |
| Jeu De Paume            |
| Rugby Sevens            |
| Croquet                 |
| Racquets                |
| Motorboating            |
| Aeronautics             |
| Basque Pelota           |
| Military Ski Patrol     |
| Cricket                 |

---

### How many sports have been played in each Olympic edition?

``` SQL []
SELECT GAMES AS "Olympic Games",
       COUNT(DISTINCT SPORT) AS "Sports Played"
FROM ATHLETE_EVENTS_SM
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;
```

| Olympic Games | Sports Played |
| :------------ | ------------: |
| 1896 Summer   | 9             |
| 1900 Summer   | 20            |
| 1904 Summer   | 18            |
| 1906 Summer   | 13            |
| 1908 Summer   | 24            |
| ...           |               |
| 2012 Summer   | 32            |
| 2014 Winter   | 15            |
| 2016 Summer   | 34            |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/08-olympic-participation-by-sport/query_result.csv)

---

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

| ID     | NAME              | SEX | AGE | TEAM          | NOC | GAMES       | CITY      | SPORT    | EVENT                                            | MEDAL |
| :----- | :---------------- | :-- | :-- | :------------ | :-- | :---------- | :-------- | :------- | :----------------------------------------------- | :---- |
| 53238  | Charles Jacobus   | M   | 64  | United States | USA | 1904 Summer | St. Louis | Roque    | Roque Men's Singles                              | Gold  |
| 117046 | Oscar Gomer Swahn | M   | 64  | Sweden        | SWE | 1912 Summer | Stockholm | Shooting | Shooting Men's Running Target, Single Shot, Team | Gold  |

---

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

| Male Athletes  | Female Athletes  | M:F Ratio  |
| :------------: | :--------------: | :--------: |
| 101590         | 33981            | 2.98961    |

---

### Who are the top 5 athletes with the most gold medals?

``` SQL []
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
```

| ID    | Name                               | Gold Medals |
| :---- | :--------------------------------- | ----------: |
| 94406 | Michael Fred Phelps, II            | 23          |
| 33557 | Raymond Clarence "Ray" Ewry        | 10          |
| 67046 | Larysa Semenivna Latynina (Diriy-) | 9           |
| 69210 | Frederick Carlton "Carl" Lewis     | 9           |
| 87390 | Paavo Johannes Nurmi               | 9           |

---

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

| ID    | Name                               | Total Medals |
| :---- | :--------------------------------- | -----------: |
| 94406 | Michael Fred Phelps, II            | 28           |
| 67046 | Larysa Semenivna Latynina (Diriy-) | 18           |
| 4198  | Nikolay Yefimovich Andrianov       | 15           |
| 11951 | Ole Einar Bjrndalen                | 13           |
| 74420 | Edoardo Mangiarotti                | 13           |

---

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

| Country | Total Medals |
| :------ | -----------: |
| USA     | 5637         |
| Russia  | 3947         |
| Germany | 3756         |
| UK      | 2068         |
| France  | 1777         |

---

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

| Country     | Gold  | Silver | Bronze | Total |
| :------     | ----: | -----: | -----: | ----: |
| USA         | 2638  | 1641   | 1358   | 5637  |
| Russia      | 1599  | 1170   | 1178   | 3947  |
| Germany     | 1301  | 1195   | 1260   | 3756  |
| UK          | 678   | 739    | 651    | 2068  |
| France      | 501   | 610    | 666    | 1777  |
| ...         |       |        |        |       |
| Greece      | 62    | 109    | 84     | 255   |
| New Zealand | 90    | 56     | 82     | 228   |
| Ukraine     | 47    | 52     | 100    | 199   |
| India       | 138   | 19     | 40     | 197   |
| Jamaica     | 38    | 75     | 44     | 157   |
| ...         |       |        |        |       |
| Bolivia     | 0     | 0      | 0      | 0     |
| Nauru       | 0     | 0      | 0      | 0     |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/14-medals-tally-for-countries/query_result.csv)

---

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

| Olympic Games | Country  | Gold  | Silver | Bronze | Total |
| :------------ | :------- | ----: | -----: | -----: | ----: |
| 1896 Summer   | Greece   | 10	   | 18	    | 20     | 48    |
| 1896 Summer   | Germany  | 25	   | 5      | 2      | 32    |
| 1896 Summer   | USA      | 11    | 7      | 2      | 20    |
| ...           |          |       |        |        |       |
| 1900 Summer   | France   | 52    | 101    | 82     | 235   |
| 1900 Summer   | UK       | 59    | 34     | 15     | 108   |
| 1900 Summer   | USA      | 30    | 16     | 17     | 63    |
| ...           |          |       |        |        |       |
| 1904 Summer   | USA      | 128   | 141    | 125    | 394   |
| 1904 Summer   | Canada   | 27    | 9      | 12     | 48    |
| 1904 Summer   | Germany  | 4     | 5      | 7      | 16    |
| ...           |          |       |        |        |       |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/15-medals-tally-for-countries-by-olympic-edition/query_result.csv)

---

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

| Olympic Games | Most Successful Country | Gold  | Silver | Bronze | Total |
| :------------ | :---------------------- | ----: | -----: | -----: | ----: |
| 1896 Summer   | Greece                  | 10    | 18     | 20     | 48    |
| 1900 Summer   | France	              | 52	  | 101	   | 82     | 235   |
| 1904 Summer   | USA	                  | 128	  | 141	   | 125    | 394   |
| 1906 Summer   | Greece	              | 24	  | 48	   | 30     | 102   |
| 1908 Summer   | UK	                  | 147	  | 131	   | 90     | 368   |
| ...           |                         |       |        |        |       |
| 2012 Summer   | USA	                  | 145	  | 57	   | 46     | 248   |
| 2014 Winter   | Canada	              | 59    | 22	   | 5	    | 86    |
| 2016 Summer   | USA	                  | 139	  | 54	   | 71     | 264   |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/16-top-performing-countries-by-olympic-edition/query_result.csv)

---

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

| Country     | Gold  | Silver | Bronze | Total |
| :------     | ----: | -----: | -----: | ----: |
| Ghana       | 0     | 1      | 22     | 23    |
| Paraguay    | 0     | 17     | 0      | 17    |
| Iceland     | 0     | 15     | 2      | 17    |
| Malaysia    | 0     | 11     | 5      | 16    |
| Montenegro  | 0     | 14     | 0      | 14    |
| ...         |       |        |        |       |
| Barbados    | 0     | 0      | 1      | 1     |
| Djibouti    | 0     | 0      | 1      | 1     |
| Macedonia   | 0     | 0      | 1      | 1     |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/17-countries-winning-only-silver-or-bronze/query_result.csv)

---

### In which Olympic sport and event has India won the most medals?

``` SQL []
WITH INDIA_OLYMPIC_MEDALS AS (
    SELECT SPORT AS "Sport", 
           EVENT AS "Event", 
           COUNT(*) AS "Medals",
           DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS "Ranking"
    FROM ATHLETE_EVENTS_SM
    WHERE NOC = 'IND' AND MEDAL <> 'NA'
    GROUP BY SPORT, EVENT
)
SELECT "Sport", "Event", "Medals"
FROM INDIA_OLYMPIC_MEDALS
WHERE "Ranking" = 1;
```

| Sport  | Event               | Medals |
| :----- | :------------------ | -----: |
| Hockey | Hockey Men's Hockey | 173    |

---

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

| Olympic Games | Hockey Medals | Total Medals | % Hockey Medals |
| :------------ | ------------: | -----------: | --------------: |
| 1896 Summer   | 0             | 0            | 0               |
| 1900 Summer   | 0             | 2            | 0               |
| 1904 Summer   | 0             | 0            | 0               |
| ...           |               |              |                 |
| 1928 Summer   | 14            | 14           | 100             |
| 1928 Winter   | 0             | 0            | 0               |
| 1932 Summer   | 15            | 15           | 100             |
| 1932 Winter   | 0             | 0            | 0               |
| 1936 Summer   | 19            | 19           | 100             |
| 1936 Winter   | 0             | 0            | 0               |
| 1948 Summer   | 20            | 20           | 100             |
| 1948 Winter   | 0             | 0            | 0               |
| 1952 Summer   | 14            | 15           | 93.33           |
| 1952 Winter   | 0             | 0            | 0               |
| 1956 Summer   | 17            | 17           | 100             |
| ...           |               |              |                 |
| 2012 Summer   | 0             | 6            | 0               |
| 2014 Winter   | 0             | 0            | 0               |
| 2016 Summer   | 0             | 2            | 0               |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/19-india-share-of-hockey-vs-total-medals/query_result.csv)

---

### Has female participation in the Summer Olympics grown over time?

``` SQL []
SELECT GAMES AS "Olympic Games", 
       COUNT(DISTINCT ID) AS "Female Athletes"
FROM ATHLETE_EVENTS_SM
WHERE SEX = 'F' AND GAMES LIKE '%Summer%'
GROUP BY GAMES
ORDER BY "Olympic Games" ASC;
```

| Olympic Games | Female Athletes |
| :------------ | --------------: | 
| 1900 Summer   | 23              |
| 1904 Summer   | 6               |
| 1906 Summer   | 6               |
| 1908 Summer   | 44              |
| 1912 Summer   | 53              |
| 1920 Summer   | 78              |
| 1924 Summer   | 156             |
| 1928 Summer   | 312             |
| 1932 Summer   | 201             |
| 1936 Summer   | 361             |
| 1948 Summer   | 446             |
| 1952 Summer   | 521             |
| ...           |                 |
| 2008 Summer   | 4609            |
| 2012 Summer   | 4654            |
| 2016 Summer   | 5034            |

[CLICK HERE TO SEE FULL RESULT](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/ea7118dc3bb5c63ecf22e4e6a090543b6c4dcd64/Query_Results/20-female-participation-by-olympic-edition/query_result.csv)

![FEMALE PARTICIPATION IN THE OLYMPICS DISTRIBUTION PREVIEW](https://github.com/sankalpmundra/Olympic_Games_Data_Analysis/blob/9e680aece9dced6ce8d43fe1338c78b3f6bc64e5/Query%20Results/20-female-participation-by-olympic-edition/female_olympics_participation_GRAPH.png?raw=true)

---
