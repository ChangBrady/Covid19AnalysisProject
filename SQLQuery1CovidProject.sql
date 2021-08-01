--Select location, date, total_cases, new_cases, total_deaths, population
--From CovidProject..CovidDeaths
--order by 1,2 

--Death percentage
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
--From CovidProject..CovidDeaths
--where location like '%indonesia%'
--order by 1,2 

--total cases vs population
--Select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
--From CovidProject..CovidDeaths
--where location like '%indonesia%'
--order by 1,2 desc

Select location, population, max(total_cases) as HighestInfectedCount, max((total_cases/population)*100) as HighestPercentInfected
From CovidProject..CovidDeaths
--where location like '%indonesia%'
group by location, population
order by HighestPercentInfected desc

Select location, max(cast(total_deaths as int)) as HighestDeathsCount
From CovidProject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by location
order by 2 desc

Select continent, max(cast(total_deaths as int)) as HighestDeathsCount
From CovidProject..CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by 2 desc 

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%indonesia%'  
--order by 2,3 desc
)
Select *, (RollingPeopleVaccinated/population)*100 as percentvac 
From popvsvac
order by 2,3 desc


--TEMP TABLE

DROP Table if exists PercentPeopleVaccinated
Create Table PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%indonesia%'  
-- order by 2,3 desc

Select *, (RollingPeopleVaccinated/population)*100 as percentvac 
From PercentPeopleVaccinated

-- Creating View to store data for later visualizations
Create View PercentPeoplesVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%indonesia%'  
-- order by 2,3 desc
