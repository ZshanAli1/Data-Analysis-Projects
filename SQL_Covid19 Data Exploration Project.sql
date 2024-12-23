use portfolioproject;
--select * from CovidDeaths order by 3,4;
--select * from CovidVaccinations order by 3,4;

-- 1. Countrywise day by day death percentage by total cases
Select 
	location,
	date,
	total_cases,
	total_deaths,
	cast(ceiling((total_deaths/total_cases)*100) as varchar) + '%' as Death_Percentage_by_totalCases
from CovidDeaths order by 1,2;

-- 2. Countrywise day by day cases percentage by population
Select 
	location,
	date,
	total_cases,
	population, 
	cast(floor((total_cases/population)*100) as varchar) + '%' as Cases_Percentage_by_population
from CovidDeaths order by 1,2;

-- 3. Countrywise grouped up cases percentage by Country's max population

select 
	location,
	max(date) as date,
	max(total_cases) as total_cases,
	max(population) as population,
	cast(max(floor((total_cases/population)*100)) as varchar) + '%' as max_cases_percent_by_country
from CovidDeaths 
--where location like '%p___%'
group by location 
order by max(floor((total_cases/population)*100)) DESC;


-- 4. infection rate by country grouped up
select 
	location,
	population,
	max(total_cases) as max_case_by_country,
	(max(total_cases)/population)*100 as infection_rate
from CovidDeaths
group by location,population
order by infection_rate desc;

-- 5. Highest death count per population

select 
	location,
	population,
	max(cast(total_deaths as int)) as max_deaths_by_country,
	(max(cast(total_deaths as int))/population)*100 as death_rate
from CovidDeaths
where continent is not null
group by location,population
order by max_deaths_by_country desc;

-- 6. Continentwise deaths
select 
	location,
	max(cast(total_deaths as int)) as total_deaths_by_country
from CovidDeaths
where continent is null and location in ('North America','South America','Asia','Europe','Africa')
group by location;

-- Total number of cases reported globally date by date
select 
	--date,
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage_date_by_date
from CovidDeaths
where continent is not null
--group by date
order by 1;


select 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,				-- Location partitioned roll until different date for that location
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date) as "Rolling People Vaccinated"
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2,3;

-- we can not use aggregated column's alias in the same query to generate another column
-- for this we use CTE

with Population_Vs_Vaccination(continent,location,date,population,new_vaccinations,"Rolling People Vaccinated")
as
(
select 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,				-- Location partitioned roll until different date for that location
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date) as "Rolling People Vaccinated"
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
select *,"Rolling People Vaccinated"/population*100
from Population_Vs_Vaccination
order by 2,3;


-- Temporary Table
drop table if exists #Population_vs_Vaccinated
create table #Population_vs_Vaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
"Rolling People Vaccinated" numeric
)

insert into #Population_vs_Vaccinated
select 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,				-- Location partitioned roll until different date for that location
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date) as "Rolling People Vaccinated"
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

select *, "Rolling People Vaccinated"/population*100
from #Population_vs_Vaccinated
order by 2,3;

create view Population_vs_Vaccinated as
select 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,				-- Location partitioned roll until different date for that location
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date) as "Rolling People Vaccinated"
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null