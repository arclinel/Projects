SELECT *
FROM covid_project..CovidDeaths
WHERE continent is not null

SELECT *
FROM covid_project..CovidVaccinations
WHERE continent is not null


-- Looking at Total cases VS Total Deaths, showing percentage likelyhood of death in Nigeria

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM covid_project..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

-- Looking at the Toal Cases VS the Population
-- Showing percentage Death of Population

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS DeathPercentage
FROM covid_project..CovidDeaths
--WHERE location like '%Nigeria%'
ORDER BY 1,2

-- Looking at country with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population) * 100 AS PercentagePopulationInfected
FROM covid_project..CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY location, population
ORDER BY location

-- Looking at country with highest death count

SELECT location, MAX(total_deaths) AS TotalDeathsCount
FROM covid_project..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathsCount DESC



-- BY Continent

-- Showing total deaths counts for each continent

SELECT continent, MAX(total_deaths) AS TotalDeathsCount
FROM covid_project..CovidDeaths
--WHERE location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(total_cases) TotalDailyCases, SUM(total_deaths) AS TotalDailyDeaths, (SUM(total_deaths)/SUM(total_cases)) * 100
FROM covid_project..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at population VS Vaccinations


SELECT cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations
, SUM(CAST(cvv.new_vaccinations as float)) 
OVER (PARTITION BY cvd.location ORDER BY cvd.location, cvd.date) as RollingPeopleVaccinated
FROM covid_project..CovidDeaths cvd
JOIN covid_project..CovidVaccinations cvv
	ON cvd.location = cvv.location
	and cvd.date = cvv.date
WHERE cvd.continent is not null
ORDER BY continent

-- Using CTE

WITH popvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations
, SUM(CAST(cvv.new_vaccinations as float)) 
OVER (PARTITION BY cvd.location ORDER BY cvd.location, cvd.date) as RollingPeopleVaccinated
FROM covid_project..CovidDeaths cvd
JOIN covid_project..CovidVaccinations cvv
	ON cvd.location = cvv.location
	and cvd.date = cvv.date
WHERE cvd.continent is not null
-- ORDER BY continent
)

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM popvsVac


-- Using Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations
, SUM(CAST(cvv.new_vaccinations as float)) 
OVER (PARTITION BY cvd.location ORDER BY cvd.location, cvd.date) as RollingPeopleVaccinated
FROM covid_project..CovidDeaths cvd
JOIN covid_project..CovidVaccinations cvv
	ON cvd.location = cvv.location
	and cvd.date = cvv.date
WHERE cvd.continent is not null


SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated



-- Creating view to store data later

CREATE VIEW PercentPopulationVaccinated AS
SELECT cvd.continent, cvd.location, cvd.date, cvd.population, cvv.new_vaccinations
, SUM(CAST(cvv.new_vaccinations as float)) 
OVER (PARTITION BY cvd.location ORDER BY cvd.location, cvd.date) as RollingPeopleVaccinated
FROM covid_project..CovidDeaths cvd
JOIN covid_project..CovidVaccinations cvv
	ON cvd.location = cvv.location
	and cvd.date = cvv.date
WHERE cvd.continent is not null
-- ORDER BY continent