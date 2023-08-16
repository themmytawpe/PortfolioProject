select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like 'nigeria'
where continent is not null
order by 1,2

--looking at total cases vs population
--shows percentage of population that got covid

select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
--where location like 'nigeria'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectedCount, MAX(total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
--where location like 'nigeria'
group by location, population
order by PopulationPercentage desc

--countries with the highest death count population

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like 'nigeria'
where continent is not null
group by location, population
order by TotalDeathCount desc
 
 --DATA BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like 'nigeria'
where continent is not null
group by continent
order by TotalDeathCount desc

 --global data

 select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
 from PortfolioProject..CovidDeaths$
 where continent is not null
 group by date
 order by 1,2

 --looking at total population vs vaccinations
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
 ,dea.date) as RollingPeopleVac
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
 ,dea.date) as RollingPeopleVac
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVac/population)*100
from popvsvac

--Temp Table

drop table if exist #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continet nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVac numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
 ,dea.date) as RollingPeopleVac
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVac/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later vizualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location
 ,dea.date) as RollingPeopleVac
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated