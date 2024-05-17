-- Q1. Write a code to check NULL values

SELECT *
FROM corona_virus_dataset
WHERE Province IS NULL
   OR Country_Region IS NULL
   OR Latitude IS NULL
   OR Longitude IS NULL
   OR Date IS NULL
   OR Confirmed IS NULL
   OR Deaths IS NULL
   OR Recovered IS NULL;


--Q2. If NULL values are present, update them with zeros for all columns. 

UPDATE corona_virus_dataset
SET Province = COALESCE(Province, ''),
    Country_Region = COALESCE(Country_Region, ''),
    Latitude = COALESCE(Latitude, 0),
    Longitude = COALESCE(Longitude, 0),
    Date = COALESCE(Date, Current_date),
    Confirmed = COALESCE(Confirmed, 0),
    Deaths = COALESCE(Deaths, 0),
    Recovered = COALESCE(Recovered, 0);


-- Q3. check total number of rows

SELECT COUNT(*)
FROM corona_virus_dataset;

-- Q4. Check what is start_date and end_date

SELECT MIN(Date) AS start_date, MAX(Date) AS end_date
FROM corona_virus_dataset;


-- Q5. Number of month present in dataset

SELECT EXTRACT(MONTH FROM Date) AS month_number, COUNT(*) AS num_of_records FROM corona_virus_dataset
GROUP BY EXTRACT(MONTH FROM Date)
ORDER BY month_number;

-- Q6. Find monthly average for confirmed, deaths, recovered

SELECT 
    EXTRACT(YEAR FROM Date) AS year,
    EXTRACT(MONTH FROM Date) AS month,
    ROUND(AVG(Confirmed), 3) AS avg_confirmed,
    ROUND(AVG(Deaths), 3) AS avg_deaths,
    ROUND(AVG(Recovered), 3) AS avg_recovered
FROM corona_virus_dataset
GROUP BY EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY year, month;

-- Q7. Find most frequent value for confirmed, deaths, recovered each mont

SELECT
    month_no,
    year,
    Confirmed,
    Deaths,
    Recovered
FROM (
    SELECT
        EXTRACT(MONTH FROM Date) AS month_no,
        EXTRACT(YEAR FROM Date) AS year,
        Confirmed,
        Deaths,
        Recovered,
        RANK() OVER (PARTITION BY EXTRACT(MONTH FROM Date), EXTRACT(YEAR FROM Date) ORDER BY COUNT(*) DESC) AS rank
    FROM
        corona_virus_dataset
    GROUP BY
        EXTRACT(MONTH FROM Date), EXTRACT(YEAR FROM Date), Confirmed, Deaths, Recovered
) AS FrequentData
WHERE
    rank = 1
ORDER BY
    year, month_no;

-- Q8. Find minimum values for confirmed, deaths, recovered per year

SELECT 
    EXTRACT(YEAR FROM Date) AS year,
    MIN(Confirmed) AS min_confirmed,
    MIN(Deaths) AS min_deaths,
    MIN(Recovered) AS min_recovered
FROM 
    corona_virus_dataset
GROUP BY 
    EXTRACT(YEAR FROM Date)
ORDER BY 
    year;


-- Q9. Find maximum values of confirmed, deaths, recovered per year

SELECT 
    EXTRACT(YEAR FROM Date) AS year,
    MAX(Confirmed) AS max_confirmed,
    MAX(Deaths) AS max_deaths,
    MAX(Recovered) AS max_recovered
FROM 
    corona_virus_dataset
GROUP BY 
    EXTRACT(YEAR FROM Date)
ORDER BY 
    year;


-- Q10. The total number of case of confirmed, deaths, recovered each month

SELECT 
    EXTRACT(YEAR FROM Date) AS year,
    EXTRACT(MONTH FROM Date) AS month,
    SUM(Confirmed) AS total_confirmed,
    SUM(Deaths) AS total_deaths,
    SUM(Recovered) AS total_recovered
FROM 
    corona_virus_dataset
GROUP BY 
    EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY 
    year, month;


-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT 
    EXTRACT(YEAR FROM Date) AS year,
    EXTRACT(MONTH FROM Date) AS month,
    SUM(Confirmed) AS total_confirmed_cases,
    ROUND(AVG(Confirmed), 3) AS average_confirmed_cases,
    ROUND(VARIANCE(Confirmed), 3) AS variance_confirmed_cases,
    ROUND(STDDEV(Confirmed), 3) AS std_dev_confirmed_cases
FROM 
    corona_virus_dataset
GROUP BY 
    EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY 
    year, month;

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT 
    EXTRACT(YEAR FROM Date) AS year,
    EXTRACT(MONTH FROM Date) AS month,
    SUM(Deaths) AS total_death_cases,
    ROUND(AVG(Deaths), 3) AS average_death_cases,
    ROUND(VARIANCE(Deaths), 3) AS variance_death_cases,
    ROUND(STDDEV(Deaths), 3) AS std_dev_death_cases
FROM 
    corona_virus_dataset
GROUP BY 
    EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY 
    year, month;


-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )

SELECT 
    EXTRACT(YEAR FROM Date) AS year,
    EXTRACT(MONTH FROM Date) AS month,
    SUM(Recovered) AS total_recovered_cases,
    ROUND(AVG(Recovered), 3) AS average_recovered_cases,
    ROUND(VARIANCE(Recovered), 3) AS variance_recovered_cases,
    ROUND(STDDEV(Recovered), 3) AS std_dev_recovered_cases
FROM 
    corona_virus_dataset
GROUP BY 
    EXTRACT(YEAR FROM Date), EXTRACT(MONTH FROM Date)
ORDER BY 
    year, month;


-- Q14. Find Country having highest number of the Confirmed case

SELECT 
    Country_Region,
    SUM(Confirmed) AS total_confirmed_cases
FROM 
    corona_virus_dataset
GROUP BY 
    Country_Region
ORDER BY 
    total_confirmed_cases DESC
LIMIT 1;


-- Q15. Find Country having lowest number of the death case

SELECT 
    Country_Region,
    SUM(Deaths) AS total_death_cases
FROM 
    corona_virus_dataset
GROUP BY 
    Country_Region
HAVING 
    SUM(Deaths) = (
        SELECT 
            MIN(total_deaths)
        FROM 
            (SELECT 
                SUM(Deaths) AS total_deaths
            FROM 
                corona_virus_dataset
            GROUP BY 
                Country_Region) AS subquery
    );


-- Q16. Find top 5 countries having highest recovered case

SELECT 
    Country_Region,
    total_recovered_cases
FROM (
    SELECT 
        Country_Region,
        SUM(Recovered) AS total_recovered_cases,
        ROW_NUMBER() OVER (ORDER BY SUM(Recovered) DESC) AS rank
    FROM 
        corona_virus_dataset
    GROUP BY 
        Country_Region
) AS ranked_countries
WHERE 
    rank <= 5;
