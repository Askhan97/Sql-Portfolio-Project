select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2
-- looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location='Pakistan'
order by 1,2

-- looking at total cases vs population
-- Shows what percentage of population got covid
select location, date, population, total_cases,  (total_cases/population)*100 as percentpopulationinfected
from covid_deaths
where location='Pakistan'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfectioncount,  max((total_cases/population))*100 as percentpopulationinfected
from covid_deaths
group by location, population
order by percentpopulationinfected desc 

--Showing countries with the highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from covid_deaths
where continent is not null
group by location
order by totaldeathcount desc


-- Let's break things down by continent

-- Showing Continents with thw the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from covid_deaths
where continent is not null
group by continent
order by totaldeathcount desc

--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid_deaths
where continent is not null
--group by date
order by 1,2;


--Looking at Total population vs vaccination
--USE CTE 
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac

-- creating views to store data for visualization

create view percentagepeoplevaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null