--Select data that we will be using

Select *
FROM PortfolioProject..CovidDeaths
where continent is null
order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1, 2

-- Looking at total cases vs population
-- Shows percentage of the population with Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentWithCovid
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1, 2


-- Looking at Countries witht Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfCount, MAX((total_cases/population))*100 AS PercentInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
Group by Location, population
order by PercentInfected desc


-- Showing Country's with the highest death count

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Showing Continent's with the highest death count

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
--group by date
order by 1, 2


--Looking at Total Population vs Vaccinations
--CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
SELECT *, (RollingPeopleVac/Population)*100
From PopvsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) AS RollingPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

SELECT *, (RollingPeopleVac/Population)*100
From #PercentPopulationVaccinated	

-- Creating View to store data for later visualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) AS RollingPeopleVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3