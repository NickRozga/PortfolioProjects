--Global covid data from https://ourworldindata.org/covid-deaths as of September 26th 2021

Select *
From PortfolioProject..coviddeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..covidvaccinations
Order by 3,4

--Simplified

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
Order by 1,2




-- Looking at total cases vs total deaths in the US
-- Shows likelihood of dying if you contract covid in the US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..coviddeaths
Where location like '%states%'
Order by 1,2




-- Looking at total cases vs population in the US
-- Shows what percentage of population got covid in the US

Select Location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
From PortfolioProject..coviddeaths
Where location like '%states%'
Order by 1,2




-- Looking at total cases vs total deaths in your country
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..coviddeaths
Order by 1,2




-- Looking at total cases vs population in the world
-- Shows what percentage of population got covid in the world

Select Location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
From PortfolioProject..coviddeaths
Order by 1,2




-- Looking at countries with highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 AS InfectionPercentage
From PortfolioProject..coviddeaths
Group by location, population
Order by InfectionPercentage desc




-- Showing countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc




-- Total deaths broken down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc




-- Global cases, deaths, and death percentage

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..coviddeaths
Where continent is not null
Group by date
Order by 1,2



-- Global death percentage overall

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..coviddeaths
Where continent is not null
--Group by date
Order by 1,2




--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac




-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated
From #PercentPopulationVaccinated




-- Creating view to store data for later visualizations

Create View GlobalCasesvsDeathsvsDeathPercentage
as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..coviddeaths

