Select*
From PortifolioProject..CovidDeaths$
Where continent is NOT null
order by 3,4



Select*
From PortifolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortifolioProject..CovidDeaths$
Where continent is NOT null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortifolioProject..CovidDeaths$
where location like '%kenya%'
and continent is NOT null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location,date,total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
From PortifolioProject..CovidDeaths$
where location like '%kenya%'
and continent is NOT null
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location,max(total_cases) as HighestInfectionCount,population,max((total_cases/population))*100 as PercentagePopulationInfected
From PortifolioProject..CovidDeaths$
Where continent is NOT null
--where location like '%kenya%'
Group by location,population
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count per Population

Select location,max(Cast(total_deaths as INT)) as TotalDeathCount
From PortifolioProject..CovidDeaths$
Where continent is NOT null
--where location like '%kenya%'
Group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent,max(Cast(total_deaths as INT)) as TotalDeathCount
From PortifolioProject..CovidDeaths$
Where continent is NOT null
--where location like '%kenya%'
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as  total_cases,SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
From PortifolioProject..CovidDeaths$
--where location like '%kenya%'
where continent is NOT null
--Group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortifolioProject..CovidDeaths$ dea
Join PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortifolioProject..CovidDeaths$ dea
Join PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortifolioProject..CovidDeaths$ dea
Join PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortifolioProject..CovidDeaths$ dea
Join PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

