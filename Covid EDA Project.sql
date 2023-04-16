select location,date,total_cases,new_cases,total_deaths,
population 
from covid_deaths
order by 1,2

;

-- Looking at Total Cases vs Total Deaths
-- Shows the probability of dying if you catch covid in your country

select location,date,total_cases,total_deaths, 
((total_deaths/total_cases)*100) as death_perct
from covid_deaths
where location ilike '%united states%'
order by 1,2

;

-- Looking at Total Cases vs Population
-- Shows percentage of population that got Covid

select location,date,total_cases,population,
((total_cases/population)*100) as pct_population
from covid_deaths
where location ilike '%united states%'
order by 1,2

;

-- Countries with Hightest Infection Rate compared to Population

select location,population,MAX(total_cases) as HighestInfectionCount,

(MAX(total_cases/population)*100) as PercentPopulationInfected
from covid_deaths
where total_cases is not null
group by location,population
order by PercentPopulationInfected desc

;
-- Percent of Population Infected Per Day
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
where total_cases is not null
Group by Location, Population, date
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

select location,MAX(total_deaths) as TotalDeathCount,population,
((MAX(total_deaths)/population)*100) as PercentPopulationDead
from covid_deaths
where continent is not null
group by location, population
order by PercentPopulationDead desc

;

-- Continents with highest death count per population

select Continent,MAX(Total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by totaldeathcount desc

;

-- Global Numbers

select date,SUM(new_cases) as CasesPerDay,
SUM(new_deaths) as DeathsPerDay, 
ROUND((SUM(new_deaths)/SUM(new_cases)*100),3)
as DeathPercentage
from covid_deaths
where continent is not null and new_cases != 0
group by date
order by 1,2;


-- Total Death Count per Continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid_deaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International',
					 'High income','Upper middle income',
					 'Lower middle income','Low income')
Group by location
order by TotalDeathCount desc;



-- Total Death Percentage

select SUM(new_cases) as Total_Cases,
SUM(new_deaths) as Total_Deaths, 
ROUND((SUM(new_deaths)/SUM(new_cases)*100),2)
as DeathPercentage
from covid_deaths
where continent is not null and new_cases != 0
order by 1,2;

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, 
vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) 
OVER(Partition by dea.location Order By dea.location,dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid_deaths dea
join cvacc vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
order by 2,3
;

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, 
vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) 
OVER(Partition by dea.location Order By dea.location,dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid_deaths dea
join cvacc vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
select *, 
(RollingPeopleVaccinated/Population)*100 as Roll_Vac_vs_Pop
from PopvsVac;



-- TEMP TABLE

DROP table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
	Continent varchar(255),
	Location varchar(255),
	Date Date,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric	
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, 
vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) 
OVER(Partition by dea.location Order By dea.location,dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid_deaths dea
join cvacc vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
;

select *, 
(RollingPeopleVaccinated/Population)*100 as Roll_Vac_vs_Pop
from PercentPopulationVaccinated;



-- Creating a view to store for later visualizations


DROP table if exists PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, 
vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) 
OVER(Partition by dea.location Order By dea.location,dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from covid_deaths dea
join cvacc vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--Order by 2,3
;

Select * From PercentPopulationVaccinated
























