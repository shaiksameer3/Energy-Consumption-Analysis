# creating a database

create database energydb;
use energydb;

#creating tables and importing csv files
-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

select * from country;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;

-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

select country,value
as gdp from gdp_3
where year = ( select max(year)
from gdp_3
)
order by gdp desc
limit 5;

# 1. What is the total emission per country for the most recent year available?
select country, sum(emission) 
as total_emission
from emission_3
where year = ( select max(year) from emission_3)
group by country
order by total_emission desc;

# 2. Compare energy production and consumption by country and year.

select p.country,p.year,p.production,c.consumption from 
production as p
inner join consumption c
on p.country = c.country
order by p.production, c.consumption desc;

# 3. Which energy types contribute most to emissions across all countries?

select energy_type, sum(emission)
as total_emissions
from emission_3
group by energy_type
order by total_emissions desc;
 
#Trend Analysis Over Time
# 4. How have global emissions changed year over year?

select year, sum(emission) as total_emission,
sum(emission) - lag(sum(emission)) over (order by year) as Yoy_change
from emission_3
group by year
order by year;

#5. What is the trend in GDP for each country over the given years?

select country, year, sum(value) as gdp_value
from gdp_3
group by country, year
order by country, year desc;

#6. How has population growth affected total emissions in each country?

select p.countries,p.year, 
sum(e.emission) as total_emission,
sum(p.value) as total_values
from population as p
inner join emission_3 as e
on p.countries = e.country
group by p.countries, p.year
order by p.countries;

#7. Has energy consumption increased or decreased over the years for major economies?

select country,year, 
sum(consumption) as total_consumption
from consumption
where country in ('india','japan','Germany','China','United States')
group by country,year
order by country,year desc;

# 8. What is the average yearly change in emissions per capita for each country?

select country, year,per_capita_emission,
per_capita_emission
- lag(per_capita_emission) over (partition by country order by year)
as yearly_change
from emission_3
order by country,year;

#Ratio & Per Capita Analysis
#9. What is the emission-to-GDP ratio for each country by year?


select e.country, e.year, 
sum(e.emission) as total_emission,
sum(g.value) as total_value,
sum(e.emission) / sum(g.value) * 100 as emission_to_gdp
from emission_3 e
join gdp_3 as g
on e.country = g.country and
e.year = g.year
group by e.country,e.year
order by e.country,e.year;

# 10. What is the energy consumption per capita for each country over the last Years?
#total consumption / population

select c.country, c.year, 
sum(c.consumption) / sum(p.value) * 100
as energy_per_capita
from consumption c
join population p
on c.country = p.countries and 
c.year = p.year
group by c.country, c.year
order by energy_per_capita desc;


# 11. How does energy production per capita vary across countries?

select * from production;

select p.countries, 
sum(b.production) *1.0 / sum(p.value)
as production_per_capita
from production as b
join population as p
on p.countries = b.country
group by p.countries
order by production_per_capita desc;

# 12. Which countries have the highest energy consumption relative to GDP?

select c.country, 
sum(c.consumption) / sum(g.value) * 100
as consume_to_gdp
from consumption as c
join gdp_3 as g
on c.country = g.country
and c.year = g.year
group by c.country
order by consume_to_gdp desc;

# 13. What is the correlation between GDP growth and energy production growth?

select g.value, p.production
from gdp_3 as g
join production as p;


#14. What are the top 10 countries by population and how do their emissions compare?

select p.countries, 
sum(p.value) as total_population,
sum(e.emission) / sum(p.value) * 100 as emissions_per_capita
from population as p
join emission_3 as e
on p.countries = e.country
and p.year = e.year
group by p.countries
order by total_population desc
limit 10;

# 15. Which countries have improved (reduced) their per capita emissions the most over the last years?
select * from emission_3;

select e20.country, e20.per_capita_emission * 100
as old_per_capita,
e23.per_capita_emission * 100 as new_per_capita,
(e20.per_capita_emission - e23.per_capita_emission) * 100 as reduction
from emission_3 as e20
join emission_3 as e23
on e20.country = e23.country
where e20.year = 2020
and e23.year = 2023
order by reduction desc;	


# 16. What is the global share (%) of emissions by country?

select c.country,SUM(e3.emission) AS total_emission,
SUM(e3.emission) / (SELECT SUM(emission) FROM emission_3) * 100 AS emission_percentage
from emission_3 as e3
join country as c
on e3.country = c.country
group by c.country
order by emission_percentage desc;

# 17. What is the global average GDP, emission, and population by year?

select g.year,avg(g.value) as avg_gdp, 
avg(e.emission) as avg_emission,
avg(p.value) as avg_population 
from gdp_3 as g
join emission_3 as e
on g.country = e.country
and g.year = e.year
join population as p
on e.country = p.countries
and e.year = p.year
group by g.year;




