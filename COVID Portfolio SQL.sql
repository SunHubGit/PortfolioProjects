/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * From covidporject.coviddeaths
order by 3, 4;

Select * From covidporject.covidvaccinations
order by 3, 4;

-- Select *
-- From covidporoject.covidvaccinations
-- order by 3,4;

--Select Data that we are going to using

Select location, date, total_cases, total_deaths, population
From covidporject.coviddeaths
order by 1, 2;

-- Looking ar Total cases vs Total Deaths
-- Shows likelihood of dying if you conract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covidporject.coviddeaths
Where location like '%states%'
and continent is not null
order by 1, 2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From covidporject.coviddeaths
Where location like '%states%'
order by 1, 2;

-- Looking at Countries with Highest Infection Rate to Population

Select location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From covidporject.coviddeaths
-- Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count oer Population

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From covidporject.coviddeaths
-- Where location like '%states%'
Group by location
order by TotalDeathCount desc;

-- Let's Break Things Down by Continent

Select continent, MAX(cast(total_cases as int)) as TotalDeathCount
From covidporject.coviddeaths
-- Where location like '%states%'
Where location is null
Group by continent
order by TotalDeathCount desc;

-- Showing continent with The Highest Death Count Per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From covidporject.coviddeaths
-- Where location like '%states%'
Where location is not null
Group by continent
order by TotalDeathCount desc;

-- Global Numbers

Select date, SUM(new_cases), as total_cases, SUM(cast(new_deaths as int)), as total_deaths, SUM(cast(new_deaths as int))/ SUM(New_cases)*100 AS DeathPercentage
From covidporject.coviddeaths
-- where location like '%states%'
Where location is not null
-- Group by date
Group by 1, 2;

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccionations,
SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date)
From covidporject.coviddeaths dea
Join covidporject.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
Order by 2, 3;

-- USE CTE

With PopvsVac (Continent, Date, Population, New_Vaccinations, RollingPeopleVaccinted)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccionations,
-- SUM(Convert(int,vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.Date)
From covidporject.coviddeaths dea
Join covidporject.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
-- Order by 2, 3;
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
 , SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From covidporject.coviddeaths dea
 Join covidporject.covidvaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    Where dea.continent is not null
    -- order by 2,3,


-- Creating View to store data for later visualizations

Create View #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
 , SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From covidporject.coviddeaths dea
 Join covidporject.covidvaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    Where dea.continent is not null
    -- order by 2,3,











