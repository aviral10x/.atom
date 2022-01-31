/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From Project..CovidDeaths
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project..CovidDeaths
Where location like '%india%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From Project..CovidDeaths
Where location like '%india%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From Project..CovidDeaths
Group by Location, population
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths D
Join Project..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths D
Join Project..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths D
Join Project..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
--where D.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths D
Join Project..CovidVaccinations V
	On D.location = D.location
	and D.date = D.date
where D.continent is not null 

