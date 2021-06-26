SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--I want to select data that I'll be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


--looking at the total cases vs total deaths
--It shows the likelihood of one dying in thier country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Niger%'
WHERE location = 'Nigeria'
AND continent is not null
order by 1,2

--looking at the total cases vs population
--This shows what percentage of population got covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Nigeria'
order by 1,2

--Looking at Countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
Group by population, location
order by PercentPopulationInfected desc

--Showing Countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location
order by TotalDeathCount desc

--Showing Continents with hihest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
order by 1,2


--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.LOCATION
, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2, 3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.LOCATION
, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime, 
Population numeric,
New_vaccinatins numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.LOCATION
, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY DEA.LOCATION
, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated