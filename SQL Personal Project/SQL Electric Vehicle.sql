-------------------------------------------------------------------------------------------------------------------
-- IMPORT DATASET 
--USING BULK INSERT --
-------------------------------------------------------------------------------------------------------------------

USE [Electric Vehicle];
GO

CREATE TABLE Electric_Vehicle
(
VIN nvarchar(50),
County nvarchar(50),
City nvarchar(50),
State nvarchar(50),
Postal_Code int,
Model_Year smallint,
Make nvarchar(50),
Model nvarchar(50),
Electric_Vehicle_Type nvarchar(100),
Clean_Alternative_Fuel_Vehicle_Eligibility nvarchar(100),
Electric_Range	smallint,
Base_MSRP int,
Legislative_District tinyint,
DOL_Vehicle_ID int,
Vehicle_Location nvarchar(50),
Electric_Utility varchar(225),
_2020_Census_Tract bigint
)

GO

BULK INSERT Electric_Vehicle 
FROM 'C:\Users\User\Documents\DATA ANALYST LEARN\PYTHON\Personal Project Python\Electric Vehicle Project\Electric_Vehicle_Population_Data.csv'
WITH (
	  FORMAT = 'CSV',
	  FIRSTROW = 2,
	  FIELDTERMINATOR = ',',
	  ROWTERMINATOR = '0x0a'
	  );
GO

-------------------------------------------------------------------------------------------------------------------------
 -- DATA CLEANING --
 -----------------------------------------------------------------------------------------------------------------------
-- Delete NULL values --
-----------------------------------------------------------------------------------------------------------------------

DELETE 
FROM Electric_Vehicle 
WHERE Legislative_District IS NULL

-----------------------------------------------------------------------------------------------------------------------
-- Change Values in Clean Alternative Fuel Vehicle Eligibility --
-----------------------------------------------------------------------------------------------------------------------

UPDATE Electric_Vehicle
SET Clean_Alternative_Fuel_Vehicle_Eligibility = 
	CASE
		WHEN Clean_Alternative_Fuel_Vehicle_Eligibility = 'Clean Alternative Fuel Vehicle Eligible' THEN 'Eligible'
		WHEN Clean_Alternative_Fuel_Vehicle_Eligibility = 'Eligibility unknown as battery range has not been researched' THEN 'Unknown'
		ELSE 'Not Eligible'
	END 

-----------------------------------------------------------------------------------------------------------------------
-- Replace '||' & '|' into '.' --
-----------------------------------------------------------------------------------------------------------------------

SELECT
	REPLACE(Electric_Utility,'||','.')
FROM Electric_Vehicle

UPDATE Electric_Vehicle
SET Electric_Utility = REPLACE(Electric_Utility,'||','.')

-------------------------------------------------------------------------------------------------------------------------

SELECT
	REPLACE(Electric_Utility,'|','.')
FROM Electric_Vehicle

UPDATE Electric_Vehicle
SET Electric_Utility = REPLACE(Electric_Utility,'|','.')

-----------------------------------------------------------------------------------------------------------------------
-- Breaking out Electrict Utility --
-----------------------------------------------------------------------------------------------------------------------

SELECT 
PARSENAME(Electric_Utility,3)
, PARSENAME(Electric_Utility,2)
, PARSENAME(Electric_Utility,1)
FROM Electric_Vehicle

-------------------------------------------------------------------------------------------------------------------------

ALTER TABLE Electric_Vehicle
ADD Electric_Utility_Split_1 varchar(100)

UPDATE Electric_Vehicle
SET Electric_Utility_Split_1 = PARSENAME(Electric_Utility,3)

-------------------------------------------------------------------------------------------------------------------------

ALTER TABLE Electric_Vehicle
ADD Electric_Utility_Split_2 varchar(100)

UPDATE Electric_Vehicle
SET Electric_Utility_Split_2 = PARSENAME(Electric_Utility,2)

-------------------------------------------------------------------------------------------------------------------------

ALTER TABLE Electric_Vehicle
ADD Electric_Utility_Split_3 varchar(100)

UPDATE Electric_Vehicle
SET Electric_Utility_Split_3 = PARSENAME(Electric_Utility,1)

-----------------------------------------------------------------------------------------------------------------------
-- Populate NULL Values in Electric_Utility_Split_1 and Electric_Utility_Split_2 Columns --
-----------------------------------------------------------------------------------------------------------------------

UPDATE a
SET a.Electric_Utility_Split_2 = a.Electric_Utility_Split_3
FROM Electric_Vehicle a
WHERE a.Electric_Utility_Split_2 IS NULL


UPDATE b
SET b.Electric_Utility_Split_1 = b.Electric_Utility_Split_2
FROM Electric_Vehicle b
WHERE b.Electric_Utility_Split_1 IS NULL

-------------------------------------------------------------------------------------------------------------------------
-- DATA EXPLORATION -- 
-------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
--  County With The Most Vehicle Production --
-------------------------------------------------------------------------------------------------------------------------

SELECT TOP 10 WITH TIES County, COUNT(County) AS Total_Production
FROM Electric_Vehicle
GROUP BY County
ORDER BY Total_Production DESC

-------------------------------------------------------------------------------------------------------------------------
-- TOP 5 Electric Vehicle Make --
-------------------------------------------------------------------------------------------------------------------------

SELECT TOP 5 WITH TIES Make, COUNT(Make) AS Total
FROM Electric_Vehicle
GROUP BY Make
ORDER BY Total DESC

-------------------------------------------------------------------------------------------------------------------------
-- Trending Electric Vehicle Based on Make, Model And Type --
-------------------------------------------------------------------------------------------------------------------------

SELECT TOP 10 WITH TIES Electric_Vehicle_Type ,Model, Make, COUNT(Model) AS Total
FROM Electric_Vehicle
GROUP BY Model, Make, Electric_Vehicle_Type
ORDER BY Total DESC

-------------------------------------------------------------------------------------------------------------------------
-- Eligibility of Clean Alternative Fuel --
-------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT Model, Make, Model_Year, Clean_Alternative_Fuel_Vehicle_Eligibility, COUNT(Clean_Alternative_Fuel_Vehicle_Eligibility)
FROM Electric_Vehicle
GROUP BY Model, Make, Model_Year, Clean_Alternative_Fuel_Vehicle_Eligibility
ORDER BY Model_Year DESC, Make, Model

SELECT DISTINCT Clean_Alternative_Fuel_Vehicle_Eligibility, COUNT(Clean_Alternative_Fuel_Vehicle_Eligibility)
FROM Electric_Vehicle
GROUP BY Clean_Alternative_Fuel_Vehicle_Eligibility

-------------------------------------------------------------------------------------------------------------------------
-- Average Base MSRP Based on Model, Model Year and Make --
-------------------------------------------------------------------------------------------------------------------------

SELECT Model, Model_Year ,Make, AVG(Base_MSRP) Average
FROM Electric_Vehicle
WHERE Base_MSRP <> 0
GROUP BY Model, Model_Year, Make, Base_MSRP
ORDER BY 2 DESC

-------------------------------------------------------------------------------------------------------------------------
-- The Most Purchased Type of Electric Vehicle --
-------------------------------------------------------------------------------------------------------------------------

SELECT Electric_Vehicle_Type, COUNT(Electric_Vehicle_Type) AS Total
FROM Electric_Vehicle
GROUP BY Electric_Vehicle_Type
ORDER BY Total DESC

-------------------------------------------------------------------------------------------------------------------------
-- Different Between Battery Electric Vehicle (BEV) And Plug-in Hybrid Electric Vehicle (PHEV) --
-------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT(Electric_Vehicle_Type), Electric_Range
FROM Electric_Vehicle
WHERE Electric_Range <> 0
GROUP BY Electric_Vehicle_Type, Electric_Range
ORDER BY Electric_Vehicle_Type ASC, Electric_Range DESC

-------------------------------------------------------------------------------------------------------------------------
-- Year VS Model VS Range --
-- What determines the size of the electric vehicle range? --
-------------------------------------------------------------------------------------------------------------------------

-- Between Battery Electric Vehicle (BEV)
SELECT DISTINCT Electric_Vehicle_Type, Make, Model, Model_Year, Electric_Range
FROM Electric_Vehicle
WHERE Electric_Vehicle_Type = 'Battery Electric Vehicle (BEV)' AND Electric_Range <> 0
ORDER BY Model_Year DESC, 2 DESC, 3

-- Plug-in Hybrid Electric Vehicle (PHEV)
SELECT DISTINCT Electric_Vehicle_Type, Make, Model, Model_Year, Electric_Range
FROM Electric_Vehicle
WHERE Electric_Vehicle_Type = 'Plug-in Hybrid Electric Vehicle (PHEV)' AND Electric_Range <> 0
ORDER BY Model_Year DESC, Electric_Range DESC

-------------------------------------------------------------------------------------------------------------------------
-- TOP 1 The Highest Range Based on Make, Model and Year --
-------------------------------------------------------------------------------------------------------------------------

--Battery Electric Vehicle (BEV)
SELECT DISTINCT TOP 1 Electric_Vehicle_Type, Make, Model, Model_Year, Electric_Range
FROM Electric_Vehicle
WHERE Electric_Range <> 0 AND Electric_Vehicle_Type = 'Battery Electric Vehicle (BEV)'
ORDER BY Electric_Range DESC

-- Plug-in Hybrid Electric Vehicle (PHEV)
SELECT DISTINCT TOP 1 Electric_Vehicle_Type, Make, Model, Model_Year, Electric_Range
FROM Electric_Vehicle
WHERE Electric_Range <> 0 AND Electric_Vehicle_Type = 'Plug-in Hybrid Electric Vehicle (PHEV)'
ORDER BY Electric_Range DESC

-------------------------------------------------------------------------------------------------------------------------
-- The Most Popular Distribution Facilities for Delivery of Electric Energy --
-------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT Electric_Utility_Split_1 , State, COUNT(Electric_Utility_Split_1) Total
FROM Electric_Vehicle
GROUP BY Electric_Utility_Split_1, State
ORDER BY Total DESC
