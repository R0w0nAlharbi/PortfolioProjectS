select * 
from  PortfolioProject..CovidDeaths$
order by 3,4


--select * 
--from  PortfolioProject..CovidVaccinations$
--order by 3,4

------get the neccassery data------------
 select location, date, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths$
 order by 1,2

 --------look into the total deaths vs the total cases--------
 
 select location, date, total_cases, total_deaths, population,(total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 order by 1,2

 ------look into specefied country's deaths---------------
 ------shows the likliehood of dying if you contract covid in your country--------
select location,date,population,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%Saudi Arabia%'
order by 1,2 

------shows what percentage of population got covid--------
select location,date,population,total_cases,(total_cases/population)*100 as covidpercentage
from PortfolioProject..CovidDeaths$
where location like '%Saudi Arabia%'
order by 1,2 

------shownig  countries with highest infection rate compared to population------
select location,population,MAX(total_cases)as HighestInfectionCount
, MAX((total_cases/population))*100 as PercentPopulatonInfected
from PortfolioProject..CovidDeaths$
group by location,population
order by PercentPopulatonInfected desc

------shownig  countries with highest death rate compared to population------
Select location,population,MAX(cast( total_deaths as bigint)) as TotaltDeathCount 
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location,population
Order by  TotaltDeathCount desc

----LET'S BREAKE THINGS BY CONTINENT------
------shownig  continent with highest death count per population -----------
Select location,MAX(cast( total_deaths as bigint)) as TotaltDeathCount 
From PortfolioProject..CovidDeaths$
where continent is  null
Group by location
Order by  TotaltDeathCount desc


----------Global Numbers--------
Select date ,SUM(new_cases) AS sumnewcases,SUM(CAST (new_deaths as int))as sumnewdeaths 
,SUM(CAST (new_deaths as int))/SUM(new_cases)*100 as percntageofdeath
From PortfolioProject..CovidDeaths$ 
where continent is not null
group by date
order by 1,2 

------------now let's join the two tables-------------
SELECT *
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac 
  On dea.location=vac.location
 and dea.date=vac.date

--------looking at vacenations vs population ----------------
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac 
  On dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
order by 2,3

--------looking at vacenations vs population ----------------
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location order by dea.location,dea.date)
as RollingPeoplevac
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac 
  On dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
order by 2,3




---------looking how many pepole got vaccinated---------
---------using CTE---------------
 with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeoplevac)
 as 
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location order by dea.location,dea.date)
as RollingPeoplevac
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac 
  On dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
 )
 select * ,(RollingPeoplevac/population)*100
 from PopvsVac
 order by 2,3


 -------TEMP TABLE---------
 DROP table if exists #percentpepoplevaccinated
 create table #percentpepoplevaccinated
 (
 continent varchar(255),
 location varchar(255),
 date datetime ,
 population numeric,
 new_vaccinations numeric,
 RollingPeoplevac numeric

 )
 Insert into #percentpepoplevaccinated
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION BY dea.location order by dea.location,dea.date)
as RollingPeoplevac
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac 
  On dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null


 select * ,(RollingPeoplevac/population)*100 as percentagerolledpeople
 from #percentpepoplevaccinated
 order by 2,3
----------------------------------------------
--------------create view---------------------
Create view firs_tview as
Select continent,location,date,population
FROM PortfolioProject..CovidDeaths$
where continent is not null;

select *
from firs_tview
----------------------------------------------