-- Tableau Queries

-- 1. Death Percentage

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(convert(float, new_deaths))/SUM(new_cases)*100 as DeathPercentage
From coviddeaths
where continent is not NULL
order by 1, 2

-- 2. Total Death Count

Select location, SUM(new_deaths) as TotalDeathCount
From coviddeaths
Where continent is NULL
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location 
order by TotalDeathCount desc

-- 3. Percent of Population Infected by Location

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((convert(float, total_cases)/population))*100 as PercentPopulationInfected
From coviddeaths
Group by Location, Population 
Order by PercentPopulationInfected desc

-- 4. Percent of Population Infected by Location and Date

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((convert(float, total_cases)/population))*100 as PercentPopulationInfected
From coviddeaths
Group by Location, Population, date 
Order by PercentPopulationInfected desc
