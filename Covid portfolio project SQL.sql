

SELECT *
FROM portfolioproject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


--SELECT *
--FROM portfolioproject..CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..CovidDeaths
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
WHERE location = 'Lebanon'
and continent is not null 
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
-- shows what percentage of population got covid

SELECT location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM portfolioproject..CovidDeaths
WHERE location = 'Lebanon'
and continent is not null 
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolioproject..CovidDeaths
--where location = 'Lebanon'
WHERE continent is not null 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
--where location = 'Lebanon'
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count  per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
--where location = 'Lebanon'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
--WHERE location = 'Lebanon'
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portfolioproject..CovidDeaths
--WHERE location = 'Lebanon'
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


-- WITH CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT *
, (RollingPeopleVaccinated/population)* 100
FROM PopvsVac


-- TEMP TABLE 

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *
, (RollingPeopleVaccinated/population)* 100
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM( CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated