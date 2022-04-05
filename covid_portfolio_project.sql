
SELECT *
FROM PortfolioProject..covid_deaths
WHERE continent is not null





-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths 
WHERE continent is not null
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths (% died)
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM PortfolioProject..covid_deaths
WHERE location like '%states%'
ORDER BY 1, 2


-- Looking at Total Cases vs Population (% infected)
SELECT Location, date, total_cases, population, (total_cases / population)*100 AS infection_percentage
FROM PortfolioProject..covid_deaths
WHERE location like '%states%'
ORDER BY 1, 2


-- Looking at Countries with highest infection rate compared to population (% infected)
SELECT Location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases / population)*100) AS infection_percentage
FROM PortfolioProject..covid_deaths
GROUP BY population, location
ORDER BY 4 DESC

-- Creating a view for infection percentage
CREATE VIEW infection_percentage as
SELECT Location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases / population)*100) AS infection_percentage
FROM PortfolioProject..covid_deaths
GROUP BY population, location

-- Showing the countries with the highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as total_death_count
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

-- Total Deaths broken down by continent
SELECT location, MAX(cast(Total_deaths as int)) as total_death_count
FROM PortfolioProject..covid_deaths
WHERE continent is null AND location NOT like '%income%'
GROUP BY location
ORDER BY total_death_count DESC

-- Create View for total_death_count by contitent
CREATE VIEW total_continent_death_count as
SELECT location, MAX(cast(Total_deaths as int)) as total_death_count
FROM PortfolioProject..covid_deaths
WHERE continent is null AND location NOT like '%income%'
GROUP BY location

SELECT *
FROM total_continent_death_count

SELECT continent, MAX(cast(Total_deaths as int)) as total_death_count
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC


-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as global_death_percentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS rolling_total_vaccinations
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


-- Use CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS rolling_total_vaccinations
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
-- ORDER BY 2, 3
SELECT *
FROM PopvsVac



-- Use Temp Table
DROP Table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_total_vaccinations numeric
)


Insert into #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS rolling_total_vaccinations
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM #percent_population_vaccinated



-- Creating View to store data for later visualizations
Create View percent_population_vaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS rolling_total_vaccinations
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

