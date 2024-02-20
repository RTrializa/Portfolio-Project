SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING --

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

-- LOOKING AT TOTAL CASES VS TOTAL DATE
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY --
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPersentage
FROM CovidDeaths
WHERE location like '%indonesia%'
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS PERSEN OF POPULATION GOT COVID --
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPersentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- WHAT COUNTRY HAVE THE HIGHEST COVID CASES --
SELECT location, MAX(total_cases) AS HighestCases, Population
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestCases DESC

-- COUNTRY THAT HAVE THE HIGHEST POPULATION INFECTION --
SELECT location, Population, Date, MAX(total_cases) AS HighestCase
, MAX(total_cases/population)*100 AS PersenPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PersenPopulationInfected DESC

--------------
SELECT location, Population, MAX(total_cases) AS HighestCase
, MAX(total_cases/population)*100 AS PersenPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PersenPopulationInfected DESC
---------------

-- WHAT COUNTRY HAVE THE HIGHEST COVID DEATHS --
SELECT Location, MAX(CAST(new_deaths as int)) AS HighestDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY HighestDeaths DESC

----------------
SELECT Continent, SUM(CAST(new_deaths as int)) AS HighestDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY Continent
ORDER BY HighestDeaths DESC
----------------
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
----------------


-- COUNTRY THAT HAVE THE HIGHEST POPULATION DEATHS (COVID CAUSES)
SELECT location, MAX(CAST(total_deaths as int)) AS HighestDeaths, population
, MAX(CAST(Total_Deaths AS INT)/Population)*100 AS PersenPopulationDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PersenPopulationDeaths DESC

-- LETS BREAK THINGS DOWN BY CONTINENT --
-- SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT --
SELECT continent, MAX(CAST(total_deaths as int)) AS HighestDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeaths DESC

-- GLOBAL NUMBERS --
SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2

-- VACTINATION --
-- TOTAL POPULATION VS VACCINATION --
-- TOTAL POPULASI YANG DI VAKSIN PER DAY --
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- HOW MANY PEOPLE IN EVERY COUNTRY ARE VACCINATED --
-- USING CTE/TEMP TABLE --

-- USE CTE --
WITH VaccinatedPeople (continent, location, date, population, New_Vaccinations, RollingPeopleVaccination) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccination/population)*100
FROM VaccinatedPeople

-- USE TEMP TABLE --
DROP TABLE IF EXISTS #PersenPopulationVaccinated 
CREATE TABLE #PersenPopulationVaccinated 
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccination numeric)

INSERT INTO #PersenPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccination/population)*100
FROM #PersenPopulationVaccinated

-- VIEW --
-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION --

CREATE VIEW PersenPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccination
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
