
Select *
From PortfolioProject1..CovidDeaths$
Where continent is not null
Order by 3,4





-- Total cases vs Total deaths
--Shows Likelihood of Dying if you contract Covid in your country
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject1..CovidDeaths$
Where location Like '%state%'
Order by 1,2

-- looking for total cases vs total population
-- Shows What percentage of population got covid
Select location,date,population,total_cases, (total_cases/population)*100 as Infectedpercentage
From PortfolioProject1..CovidDeaths$
--Where location Like '%state%'
Order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location,population,MAX(total_cases)as HighestInfectioncount, MAX((total_cases/population))*100 as Infectedpercentage
From PortfolioProject1..CovidDeaths$
--Where location Like '%state%'
Group by location, population
Order by Infectedpercentage Desc

-- Showing highest death count per population

Select location,population,MAX(cast(total_deaths as int))as Totaldeathcount
From PortfolioProject1..CovidDeaths$
--Where location Like '%state%'
Where continent is not null
Group by location, population
Order by Totaldeathcount Desc



Select location,population,MAX(cast(total_deaths as int))as Highestdeathcount, MAX((total_deaths/population))*100 as Deathpercentage
From PortfolioProject1..CovidDeaths$
--Where location Like '%state%'
Where continent is not null
Group by location, population
Order by Deathpercentage Desc


-- Showing continents with highest death count per population

Select location,MAX(cast(total_deaths as int))as Totaldeathcount
From PortfolioProject1..CovidDeaths$
--Where location Like '%state%'
Where continent is  null
Group by location
Order by Totaldeathcount Desc

-- Global Numbers

Select SUM(new_cases)as totalcases, SUM (cast(new_deaths as int)) as totaldeaths, SUM (cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage  --,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject1..CovidDeaths$
Where continent is not null
--Group by date
--Where location Like '%state%'
Order by 1,2


-- Vaccinations table
Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as rolling_people_vaccinated
from PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE
With PopsVsVAc (Continent, Location, Date, Population,new_vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) 
 as rolling_people_vaccinated
from PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select * , (RollingpeopleVaccinated/Population)*100
From PopsVsVAc


--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) 
 as rolling_people_vaccinated
from PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
Select * , (RollingpeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data later for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) 
 as rolling_people_vaccinated
from PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * From PercentPopulationVaccinated