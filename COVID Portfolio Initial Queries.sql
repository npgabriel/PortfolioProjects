Select * 
from coviddeaths 
order by 1, 2

Select location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
order by 1, 2

-- Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From coviddeaths
where location like '%states%'
order by 1, 2

-- Total Cases vs Population
-- Percentage of populaton that got covid
Select location, date, population, total_cases, (cast(total_cases as float)/population)*100 as PercentPopulationInfected
From coviddeaths
where location like '%states%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/population))*100
    as PercentPopulationInfected 
From coviddeaths
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population
Select location, MAX(total_deaths) as TotalDeathCount
From coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Breakdown by continent
Select continent, MAX(total_deaths) as TotalDeathCount
From coviddeaths
Where continent is not NULL
Group by continent
order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
From coviddeaths
where continent is not NULL
order by 1, 2

-- Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(convert(bigint, vax.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vax
    on dea.location = vax.location
    and dea.date = vax.date
where dea.continent is not NULL
order by 2, 3

-- Use CTE
With popvsvax (continent, location, date, population, new_vaccinations, RollingPeopleVaccnated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(convert(bigint, vax.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vax
    on dea.location = vax.location
    and dea.date = vax.date
where dea.continent is not NULL
)
select *, (convert(float, RollingPeopleVaccnated)/population)*100
from popvsvax

-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(convert(bigint, vax.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vax
    on dea.location = vax.location
    and dea.date = vax.date
where dea.continent is not NULL

select *, (convert(float, RollingPeopleVaccinated)/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(convert(bigint, vax.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
  as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vax
    on dea.location = vax.location
    and dea.date = vax.date
where dea.continent is not NULL