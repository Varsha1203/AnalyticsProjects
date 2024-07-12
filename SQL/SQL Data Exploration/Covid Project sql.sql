/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select * from dbo.CovidDeaths 
where continent is not null
order by 3,4

--select * from dbo.CovidVaccinations order by 3,4

select location,date,total_cases,new_cases,total_deaths,population 
from dbo.CovidDeaths 
where continent is not null
order by 1,2


--Looking at total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 as Death_Percentage 
from dbo.CovidDeaths 
where continent is not null
order by 1,2

--Shows likelihood of dying if you contract covid By location
select location,date,total_cases,total_deaths, (total_deaths/total_cases)* 100 as Death_Percentage 
from dbo.CovidDeaths where location like '%states%'
and continent is not null
order by 1,2

--Looking at total cases vs population
--shows what percentage of population got covid
select location,date,population,total_cases, (total_cases/population)* 100 as Percentage_Population_Infected
from dbo.CovidDeaths where location like '%states%'
order by 1,2

--Looking at Countries with highest infection rate compared t0 population
select location,population,max(total_cases) as Highest_Infection_Count, max((total_cases/population))* 100 as Percentage_Population_Infected 
from dbo.CovidDeaths 
--where location like '%states%'
group by location,population
order by Percentage_Population_Infected desc

--Showing the countries with the highest death count per population
select location,max(cast(total_deaths as int)) as Total_Death_Count
from dbo.CovidDeaths 
--where location like '%states%'
where continent is not null
group by location,population
order by Total_Death_Count desc

select location,max(cast(total_deaths as int)) as Total_Death_Count
from dbo.CovidDeaths 
--where location like '%states%'
where continent is null
group by location
order by Total_Death_Count desc

--break things down by continent
select continent,max(cast(total_deaths as int)) as Total_Death_Count
from dbo.CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
order by Total_Death_Count desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

select * from dbo.CovidVaccinations

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--use CTE
with PopvsVac (continent, location, date, population ,new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac

select * from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--use temp table

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
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated