/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Location]
      ,[INDICATOR]
      ,[Typeofmeat]
      ,[MEASURE]
      ,[Year]
      ,[Meatkg]
  FROM [ProjectDiseases].[dbo].[Meat$]

SELECT *
FROM [ProjectDiseases].[dbo].[Meat$]

--Convert Meatkg from nvarchar to float to use aggregate function 

ALTER TABLE Meat$
ADD MeatKgConverted Float

UPDATE [ProjectDiseases].[dbo].[Meat$]
SET MeatKgConverted = CONVERT (Float, Meatkg)

UPDATE [ProjectDiseases].[dbo].[Meat$]
SET Location = 'Thailand'
WHERE Location = 'Thailandland'


  --Check for NULL values in columns I am going to use for analysis

SELECT *
FROM [ProjectDiseases].[dbo].[Meat$]
WHERE Location IS NULL 
OR Typeofmeat IS NULL
OR Year IS NULL
OR MeatKgConverted IS NULL


--Delete Unused Columns

ALTER TABLE [ProjectDiseases].[dbo].[Meat$]
DROP COLUMN Meatkg, INDICATOR



--Find out which type of meat was the most consumed back in 1990 and most currently in 2020

SELECT Typeofmeat, year, SUM(MeatKgConverted) AS sum_meat_per_country
FROM [ProjectDiseases].[dbo].[Meat$]
WHERE Year = 1990
GROUP BY year, Typeofmeat
ORDER BY 3 DESC


SELECT Typeofmeat, year, SUM(MeatKgConverted) AS sum_meat_per_country
FROM [ProjectDiseases].[dbo].[Meat$]
WHERE Year = 2020
GROUP BY year, Typeofmeat
ORDER BY 3 DESC


--Poultry is the type of meat most consumed in 1990 and also in 2020, however Beef is in second place in 1990 and in third place in 2020. 
--Beef consumption is decreasing perhaps because population is becoming more aware about the risks of a diet high in red meat in their own health and also the environmental impact caused by beef production.   


--For curiosity, what is the country with the highest meat consumption in 2020?


WITH CTE_meat as
(SELECT Location, Year, SUM(MeatKgConverted) AS total_meat
FROM [ProjectDiseases].[dbo].[Meat$]
GROUP BY Location, Year
)
SELECT *
FROM CTE_meat
WHERE Year = 2020
ORDER BY 3 DESC

--USA had the highest meat consumption of all countries in 2020 with 101,5 Kg per capita.

--Percentage of beef and poultry consumption in 2020 worldwide

SELECT Year, 
	(SELECT SUM(MeatKgConverted)
	FROM [ProjectDiseases].[dbo].[Meat$]
	WHERE Typeofmeat='beef' AND Year=2020
	GROUP BY Year) /
	(SELECT SUM(MeatkgConverted)
	FROM [ProjectDiseases].[dbo].[Meat$]
	WHERE YEAR=2020
	GROUP BY Year) * 100 AS beef_percentage
FROM [ProjectDiseases].[dbo].[Meat$]
WHERE YEAR = 2020
GROUP BY YEAR

SELECT Year, 
	(SELECT SUM(MeatKgConverted)
	FROM [ProjectDiseases].[dbo].[Meat$]
	WHERE Typeofmeat='Poultry' AND Year=2020
	GROUP BY Year) /
	(SELECT SUM(MeatkgConverted)
	FROM [ProjectDiseases].[dbo].[Meat$]
	WHERE YEAR=2020
	GROUP BY Year) * 100 AS beef_percentage
FROM [ProjectDiseases].[dbo].[Meat$]
WHERE YEAR = 2020
GROUP BY YEAR

--21% of beef of 50% of Poultry!


--According to American Heart Association, eating more meat, especially red meat and processed meat is linked to a higher risk of atherosclerotic cardiovascular disease.
-- For curiosity, let's find out if there is a relationship between meat consumption and Cardiovascular disease death rates

--Combining the two data tables together: Meat consumption and Cardiovascular disease death rates:

WITH CTE_meat as
(SELECT Location, Year, SUM(MeatKgConverted) AS total_meat
FROM [ProjectDiseases].[dbo].[Meat$]
GROUP BY Location, Year
),
CTE_cvdeaths as
(SELECT Entity, Year, SUM(deathsover70 + deaths50_69 + deaths15_49 + deaths5_14 + deathsunder5) as total_deaths
FROM [ProjectDiseases].[dbo].['cardiovascular-disease-deaths-b$']
GROUP BY Entity, Year
)
SELECT m.Location, m.Year, m.total_meat, cv.total_deaths
FROM CTE_meat m
JOIN CTE_cvdeaths cv
ON m.Location = cv.Entity 
AND m.Year = cv.Year