SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY location, date;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying from Corona in your country
SELECT location, date, total_cases, total_deaths, 
ROUND((CAST(total_deaths AS decimal)/total_cases)*100, 7) AS "DeathPercentage"
FROM covid_deaths
WHERE location LIKE '%States'
ORDER BY location, date DESC;

-- Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid
SELECT location, date, total_cases, population, 
ROUND((CAST(total_cases AS decimal)/population)*100, 7) AS "InfectionPercentage"
FROM covid_deaths
WHERE location LIKE '%States'
ORDER BY location, date ASC;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, MAX(total_cases) AS "HighestInfectionCount", population, 
MAX(ROUND((CAST(total_cases AS decimal)/population)*100, 7)) AS "InfectionPercentage"
FROM covid_deaths
--WHERE location LIKE '%States'
GROUP BY location, population
ORDER BY "InfectionPercentage" DESC;

-- Showing Countries with Highest Death Count per Population
SELECT location,
MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(CAST(total_deaths AS INT)) IS NOT NULL
ORDER BY TotalDeathsCount DESC;

-- Showing Death Count per Continent
SELECT continent,
MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
HAVING MAX(CAST(total_deaths AS INT)) IS NOT NULL
ORDER BY TotalDeathsCount DESC;

-- Global Numbers
SELECT date,
SUM(new_cases) AS "TotalCases",
SUM(CAST(new_deaths AS INTEGER)) AS "TotalDeaths",
ROUND(SUM(CAST(new_deaths AS DECIMAL)) / SUM(new_cases) * 100, 7) AS "DeathPercentage"
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Total Global Numbers
SELECT SUM(new_cases) AS "TotalCases",
SUM(CAST(new_deaths AS INTEGER)) AS "TotalDeaths",
ROUND(SUM(CAST(new_deaths AS DECIMAL)) / SUM(new_cases) * 100, 7) AS "DeathPercentage"
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at Total Population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population,
cv.new_vaccinations
FROM covid_deaths cd
JOIN covid_vaccinations cv
   ON cd.location = cv.location
   AND cd.date = cv.date
-- Specific numbers for Canada; the day with most vaccinations   
WHERE cd.continent IS NOT NULL AND cd.location LIKE '%Canada' AND new_vaccinations IS NOT NULL
ORDER BY new_vaccinations DESC
LIMIT 5;

SELECT cd.continent, cd.location, cd.date, cd.population,
cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS "RollingPeopleVaccinated"
FROM covid_deaths cd
JOIN covid_vaccinations cv
   ON cd.location = cv.location
   AND cd.date = cv.date   
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
   SELECT cd.continent, cd.location, cd.date, cd.population,
   cv.new_vaccinations,
   SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS "RollingPeopleVaccinated"
   FROM covid_deaths cd
   JOIN covid_vaccinations cv
   ON cd.location = cv.location
   AND cd.date = cv.date   
WHERE cd.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

SELECT *
FROM PercentPopulationVaccinated;