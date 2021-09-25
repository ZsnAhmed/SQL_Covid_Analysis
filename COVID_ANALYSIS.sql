use Portfoli_project;

SELECT  * 
FROM Portfoli_project..death_data
where continent is not null 
order by 1,2;

SELECT  * 
FROM Portfoli_project..vaccination_data
where continent is not null 
order by 1,2;

-- checking the death_data again

SELECT  location,date,total_cases,total_deaths,population	
FROM Portfoli_project..death_data
where continent is not null 
order by 1,2;

-- Toal_death Vs total_cases

SELECT  location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent
FROM Portfoli_project..death_data
where continent is not null 
order by 1,2;


-- Checking what percentage of population got covid in india

SELECT  location,date,population,total_cases,(total_cases/population)*100 as InfectedPercent
FROM Portfoli_project..death_data
where continent is not null and location like '%india%'
order by 1,2; 

-- checking infected percent of all around the globe
SELECT  location,date,population,total_cases,(total_cases/population)*100 as InfectedPercent
FROM Portfoli_project..death_data
where continent is not null
order by 1,2; 

-- Looking at Countries having higer infection rate compared to population 

SELECT  location,population,max(total_cases) as highestinfectionCount,max((total_cases/population))*100 as InfectedPercent
FROM Portfoli_project..death_data
where continent is not null 
group by location, population 
order by 4 desc; 

--Looking at the countries with highest death count per population 

SELECT  location, max(cast (total_deaths as int)) as TotalDeathCount
FROM Portfoli_project..death_data
where continent is not null 
group by location  
order by 2 desc;

-- breaking thing down with continents 
-- Showing the continents with the highest death  count per population

SELECT  continent, max(cast (total_deaths as int)) as TotalDeathCount
FROM Portfoli_project..death_data
where continent is not  null 
group by continent 
order by 2 desc;

-- Global Numbers 


SELECT sum(new_cases) as total_case , sum(cast(new_deaths as int)) as total_death,
sum(cast(new_deaths as int))/ sum (New_cases)* 100 as deathPercent
from Portfoli_project..death_data
where continent is not null
order by 1,2;


-- Checking total Population vsVaccination
--SELECT * 
--FROM Portfoli_project..Death_data AS d
--JOIN Portfoli_project..vaccination_data AS v
--ON d.LOCATION = v.LOCATION	
--AND d.DATE = v.DATE;

--SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
--FROM Portfoli_project..Death_data AS d
--JOIN Portfoli_project..vaccination_data AS v
--ON d.LOCATION = v.LOCATION	
--AND d.DATE = v.DATE
--where d.continent is not null
--order by 2,3;

SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as cumsumofpeoplevacc
--,(cumsumofpeoplevacc/d.population)* 100
FROM Portfoli_project..Death_data AS d
JOIN Portfoli_project..vaccination_data AS v
ON d.LOCATION = v.LOCATION	
AND d.DATE = v.DATE
where d.continent is not null
order by 2,3;


--Using CTE

With Pop_vs_Vacc (Continent, Locations,Date,Population,new_vaccinations,cumsumofpeoplevacc)
as(
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as cumsumofpeoplevacc
--,(cumsumofpeoplevacc/d.population)* 100
FROM Portfoli_project..Death_data AS d
JOIN Portfoli_project..vaccination_data AS v
ON d.LOCATION = v.LOCATION	
AND d.DATE = v.DATE
where d.continent is not null)
--order by 2,3
SELECT * , (cumsumofpeoplevacc/Population)* 100 
FROM Pop_vs_Vacc



--Using temp table 


DROP table if exists #Percentpopulationvaccinated
create table #Percentpopulationvaccinated (
Continent varchar(200),
Location varchar(100),
Date datetime,
Population Numeric,
New_vaccinations Numeric,
cumsumofpeoplevacc Numeric)


INSERT INTO #Percentpopulationvaccinated
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as cumsumofpeoplevacc
--,(cumsumofpeoplevacc/d.population)* 100
FROM Portfoli_project..Death_data AS d
JOIN Portfoli_project..vaccination_data AS v
ON d.LOCATION = v.LOCATION	
AND d.DATE = v.DATE
where d.continent is not null
--order by 2,3

SELECT * , (cumsumofpeoplevacc/Population)* 100 
FROM #Percentpopulationvaccinated


-- Creating views to store data for visualizations

Create View Percentpopulationvaccinated as
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as cumsumofpeoplevacc
--,(cumsumofpeoplevacc/d.population)* 100
FROM Portfoli_project..Death_data AS d
JOIN Portfoli_project..vaccination_data AS v
ON d.LOCATION = v.LOCATION	
AND d.DATE = v.DATE
where d.continent is not null
--order by 2,3

--Checking view


SELECT * 
From Percentpopulationvaccinated;



