SELECT *
FROM PortfolioProject..CoronaDeaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CoronaDeaths
ORDER BY 1, 2

-- Shows likelyhood of dying if you contract covid in your country (Serbia)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageOfDeath
FROM PortfolioProject..CoronaDeaths
WHERE location = 'Serbia' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total cases VS population. Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentageOfDisease
FROM PortfolioProject..CoronaDeaths
WHERE location = 'Serbia' AND continent IS NOT NULL
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CoronaDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC

-- Showing the countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CoronaDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population

SELECT continent, MAX(total_cases) AS TotalDeathCount
FROM PortfolioProject..CoronaDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_cases) AS TotalDeathCount
FROM PortfolioProject..CoronaDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(cast(new_cases AS INT)) AS NewCases, SUM(CAST(new_deaths AS INT)) AS NewDeaths, ISNULL(SUM(new_deaths) / NULLIF(SUM(new_cases),0),0)*100 AS TotalPercentage
FROM PortfolioProject..CoronaDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--SELECT date, SUM(new_cases) AS TotalCases
--FROM PortfolioProject..CoronaDeaths
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2

SELECT date, SUM(cast(total_cases AS INT)) AS TotalCases, SUM(CAST(total_deaths AS INT)) AS TotalDeaths, ISNULL(SUM(total_deaths) / NULLIF(SUM(total_cases),0),0)*100 AS TotalPercentage
FROM PortfolioProject..CoronaDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- TOTAL PERCENTAGE OF DEATHS GLOBALY
SELECT SUM(total_cases) AS TotalCases, SUM(total_deaths) AS TotalDeaths, ISNULL(SUM(total_deaths) / NULLIF(SUM(total_cases),0),0)*100 AS TotalPercentage
FROM PortfolioProject..CoronaDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


ALTER TABLE PortfolioProject..CoronaDeaths
ALTER COLUMN total_deaths float;

--DROP TABLE PortfolioProject..CoronaDeaths

--SELECT JobTitle, MAX(Salary) 
--FROM [SQL Introduction]..EmployeeSalary
--GROUP BY JobTitle


-- to change data type: CAST(value AS INT) OR CONVERT(INT, value)

SELECT *
FROM PortfolioProject..CovidVaccinations

-- JOIN TABLES (coronaDeaths and coronaVaxxination)
-- Looking at Total Population VS People that are vaccinated

SELECT deaths.date, deaths.location AS Country, deaths.population AS PopulationOfCountry, vacc.new_vaccinations AS Vaccinated,
SUM(CONVERT(FLOAT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)	AS SumOfNewVaccinations	-- because we partition by location, it's like we group that data by location and we want to do sum for every location
FROM PortfolioProject..CoronaDeaths AS deaths
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
--WHERE deaths.location = 'Serbia'
ORDER BY 2, 1

-- Da bih mogla da koristim SumOfNewVaccinations i dodjem do procenta vakcinisanih moram da napravim CTE/Temp table

--CTE
WITH PopVsVacc (date, location, population, new_vaccinations, SumOfNewVaccinations)
AS
(
SELECT deaths.date, deaths.location AS Country, deaths.population AS PopulationOfCountry, vacc.new_vaccinations AS Vaccinated,
SUM(CONVERT(FLOAT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)	AS SumOfNewVaccinations	-- because we partition by location, it's like we group that data by location and we want to do sum for every location
FROM PortfolioProject..CoronaDeaths AS deaths
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL AND deaths.location = 'Serbia'
--WHERE deaths.location = 'Serbia'
--ORDER BY 2, 1
)

--TEMP TABLE
DROP TABLE IF EXISTS #Temp_PopVsVacc
CREATE TABLE #Temp_PopVsVacc (
	date DATETIME,
	location NVARCHAR(255),
	population NUMERIC,
	new_vaccinations NUMERIC,
	SumOfNewVaccinations NUMERIC
)

INSERT INTO #Temp_PopVsVacc
SELECT deaths.date, deaths.location AS Country, deaths.population AS PopulationOfCountry, vacc.new_vaccinations AS Vaccinated,
SUM(CONVERT(FLOAT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)	AS SumOfNewVaccinations	-- because we partition by location, it's like we group that data by location and we want to do sum for every location
FROM PortfolioProject..CoronaDeaths AS deaths
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL AND deaths.location = 'Serbia'

SELECT * , (SumOfNewVaccinations/population)*100 AS PercentageOfVaccinated
FROM #Temp_PopVsVacc


-- CREATING VIEW TO STORE DATA FOR VIZUALIZATION
CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.date, deaths.location AS Country, deaths.population AS PopulationOfCountry, vacc.new_vaccinations AS Vaccinated,
SUM(CONVERT(FLOAT, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date)	AS SumOfNewVaccinations	-- because we partition by location, it's like we group that data by location and we want to do sum for every location
FROM PortfolioProject..CoronaDeaths AS deaths
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL 

SELECT * 
FROM PercentPopulationVaccinated