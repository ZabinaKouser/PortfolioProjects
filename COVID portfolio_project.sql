select * from CovidDeaths
where continent is not null
order by cast(date as date)

select location,date,total_cases,new_cases,total_deaths, population from CovidDeaths

-- looking at toltal cases vs total deaths percentage
-- shows likelihood of dying if you contrct covid in your country
select location,date,total_cases,total_deaths, (cast(total_deaths as float)/ nullif(cast(total_cases as float), 0)*100 )as ['Deathpercentage']
from CovidDeaths
where location like 'India'
and continent is not null

--looking at total cases vs population

select location,date,total_cases,population, (cast(total_cases as float)/ nullif(cast(population as float), 0)*100 )as ['percentageofPoplation Effected']
from CovidDeaths
where continent is not null

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as[HighestinfectionCount], max((cast(total_cases as float)/ nullif(cast(population as float), 0)*100 ))as [percenatgePopulationInfected]
from CovidDeaths
where continent is not null and continent<> ''
group by location, population
order by percenatgePopulationInfected desc

-- show countries with the highest death count rate per population
select location, population, max(total_deaths) as[TotalDeathCount], max((cast(total_deaths as float)/ nullif(cast(population as float), 0)*100 ))as [percentdeathpopulation]
from CovidDeaths
where continent is not null and continent<> ''
group by location, population
order by percentdeathpopulation desc

-- show countries with highest death count 
select location, max(cast(total_deaths as int)) as[TotalDeathCount]
from CovidDeaths
where continent is not null and continent<> ''
group by location
order by TotalDeathCount desc

-- show by continent
select continent, max(cast(total_deaths as int)) as[TotalDeathCount]
from CovidDeaths
where continent is not null and continent<> ''
group by continent
order by TotalDeathCount desc

-- global numbers

select date, SUM(cast(new_cases as float)) as[total_cases], SUM(cast(new_deaths as float)) as [Total_deaths], 
SUM(cast(new_deaths as float))/ nullif(SUM(cast(new_cases as float)),0) *100  as [DeathPercentage]
from CovidDeaths
where continent is not null and continent <> ''
group by date
order by cast(date as date), 2

select date, sum(cast(new_cases as int))
from CovidDeaths
group by date 
order by cast(date as date)

-- total cases and deaths occured accross the world due to covid
select SUM(cast(new_cases as float)) as[total_cases], SUM(cast(new_deaths as float)) as [Total_deaths], 
SUM(cast(new_deaths as float))/ nullif(SUM(cast(new_cases as float)),0) *100  as [DeathPercentage]
from CovidDeaths
where continent is not null and continent<> ''
order by 2

-- join covid death and vaccination table

select * 
from CovidDeaths [dea]
join CovidVaccinations [vac]
on dea.location=vac.location
and dea.date= vac.date

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths [dea]
join CovidVaccinations [vac]
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null and dea.continent <> ''
order by 2,3

---rolling people vaccinated in each location eceryday

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, cast(dea.date as date) ) as[rollingpeopleVaccinated]
from CovidDeaths [dea]
join CovidVaccinations [vac]
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null and dea.continent <> ''
order by 2, cast(dea.date as date)

-- using cte 

with cte(continent, location, date, population,new_vaccinations, rollingpeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date ) as[rollingpeopleVaccinated]
from CovidDeaths [dea]
join CovidVaccinations [vac]
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null and dea.continent <> ''
)

select *, (rollingpeopleVaccinated/nullif(population,0))*100
from cte

--- creating a view to store data for later visulaizations

create view rollingpeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, cast(dea.date as date) ) as[rollingpeopleVaccinated]
from CovidDeaths [dea]
join CovidVaccinations [vac]
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null and dea.continent <> ''

select * from rollingpeopleVaccinated

