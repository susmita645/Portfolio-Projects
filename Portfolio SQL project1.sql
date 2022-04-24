select *
from [Project Covid]..['Pro Covid vaccine$'] 

select *
from [Project Covid]..[worldometer_coronavirus_daily_d$] 
order by 1,2


--select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from [Project Covid]..['Pro Covid vaccine$'] 
order by 1,2

--New cases Vs Total Cases
select location,date, total_cases, new_cases,(new_cases/total_cases)*100
as IncreasePercentage
from [Project Covid]..['Pro Covid vaccine$']
where location= 'Aruba'
order by increasepercentage desc

--Total cases Vs Population
-- shows what percentage of population got covid
select location,date, total_cases, population,(total_cases/population)*100
as ContractionPercentage
from [Project Covid]..['Pro Covid vaccine$']
where location= 'denmark'
order by Contractionpercentage desc

-- countries with highest infaction rate compared to population
select location,population, MAX( total_cases) as highestinfaction, max((total_cases/population))*100
as ContractionPercentage
from [Project Covid]..['Pro Covid vaccine$']
--where location= 'denmark'
group by  location,population
order by highestinfaction desc

--show countries with highest death counts per population
select location, MAX(CAST( total_deaths as int)) as TotalDeath
from [Project Covid]..['Pro Covid vaccine$']
where continent is not null
group by  location
order by TotalDeath desc

--joining the table
select *
from [Project Covid]..worldometer_coronavirus_daily_d$ rep
join [Project Covid]..['Pro Covid vaccine$'] vac
on rep.Location = vac.location
and rep.date = vac.date

--total Population Vs. Vaccinations
select rep.location , rep.date , vac.population , vac.new_vaccinations
from [Project Covid]..worldometer_coronavirus_daily_d$ rep
join [Project Covid]..['Pro Covid vaccine$'] vac
on rep.Location = vac.location
and rep.date = vac.date
where rep.location is not null
order by 1,2

--Using Windows Function
select rep.location , rep.date , vac.population , vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
over (partition by rep.location order by rep.date) vacsum  
from [Project Covid]..worldometer_coronavirus_daily_d$ rep
join [Project Covid]..['Pro Covid vaccine$'] vac
on rep.Location = vac.location
and rep.date = vac.date
where rep.location is not null
order by 1,2

--Temp Table
drop table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric
)
Insert into #percentpopulationvaccinated
select rep.location , rep.date , vac.population , vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
over (partition by rep.location order by rep.date)as vacsum  
from [Project Covid]..worldometer_coronavirus_daily_d$ rep
join [Project Covid]..['Pro Covid vaccine$'] vac
on rep.Location = vac.location
and rep.date = vac.date
where rep.location is not null
order by 1,2

--creating view to store data for later visualisations
create view Covid_view as 
select rep.location , rep.date , vac.population , vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
over (partition by rep.location order by rep.date)as vacsum  
from [Project Covid]..worldometer_coronavirus_daily_d$ rep
join [Project Covid]..['Pro Covid vaccine$'] vac
on rep.Location = vac.location
and rep.date = vac.date
where rep.location is not null


