-- DATA CLEANING

# Romove Duplicates 
# Data standardisation
# Handling Null or missing values
# Removing rows and columns


## create a duplicate table to ensure original data is intact 
select *
from layoffs;

create table Layoffs_new
like layoffs;

Insert into Layoffs_new
select *
from layoffs;

select * 
from layoffs_new;

## Handling Duplicates
 
 ## Add a row number to since there is no id number in the dataset
select *,
row_number() over(
Partition by company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as row_num
from layoffs_new;

with layoffs_cte as 
(
select *,
row_number() over(
Partition by company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as row_num
from layoffs_new
)
select *
from layoffs_cte
where row_num > 1;

## confirm that the query returns the actual duplicates
select * 
from layoffs_new
where company = 'casper';

# Create a new duplicate table to include the row number 
# since the delete function cannot work through CTE
# hence, we create a new table to drow the duplicate useing row_num column as reference 

show create table layoffs_new;
CREATE TABLE `layoffs_new2` (
   `company` text,
   `location` text,
   `industry` text,
   `total_laid_off` int DEFAULT NULL,
   `percentage_laid_off` text,
   `date` text,
   `stage` text,
   `country` text,
   `funds_raised_millions` int DEFAULT NULL,
   `row_num` int
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into layoffs_new2
select *,
row_number() over(
Partition by company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) as row_num
from layoffs_new;

select * 
from layoffs_new2
where row_num > 1;

# Ensure safemode is off to prevent delete and update restrictions
Delete
from layoffs_new2
where row_num > 1;

# confirm that the duplicates have been deleted
select * 
from layoffs_new2
where row_num > 1;


# Data Standardisation 
select * 
from layoffs_new2;

select company, trim(company)
from layoffs_new2;

update layoffs_new2
set company = trim(company);

select *
from layoffs_new2
where industry like "crypto%";

update layoffs_new2
set industry = "Crypto"
where industry like "crypto%";

select distinct industry
from layoffs_new2
ORDER BY 1;

select *
from layoffs_new2
where country like 'United States%';

select distinct country, trim(trailing "." from country)
from layoffs_new2
ORDER BY 1;

update layoffs_new2
set country = trim(trailing "." from country)
where country like 'United States%';

# standardise the date column to date format from text

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_new2;

update layoffs_new2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_new2
modify column `date` date;

# Handling Null or missing values

select *
from layoffs_new2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_new2
where industry is null
or industry = '';

# update all blank rows to NULL for standardisation 
update layoffs_new2
set industry = NULL
where industry = '';

select *
from layoffs_new2
where company = 'Airbnb';

select *
from layoffs_new2 n1
join layoffs_new2 n2
	on n1.company = n2.company
    and n1.location = n2.location
where n1.industry is null 
and n2.industry is not null;

UPDATE layoffs_new2 n1
join layoffs_new2 n2
	on n1.company = n2.company
    and n1.location = n2.location
set n1.industry = n2.industry
where n1.industry is null 
and n2.industry is not null; 

select *
from layoffs_new2
where company = 'Bally''s Interactive';

select *
from layoffs_new2;

# Removing rows and columns

select *
from layoffs_new2
where total_laid_off is null
and percentage_laid_off is null;

# All the rows without values for both total and percentage laid off will be dropped

DELETE 
from layoffs_new2
where total_laid_off is null
and percentage_laid_off is null;

ALTER table layoffs_new2
drop column row_num;

# confirm we have the completely cleaned dataset 
select * 
from layoffs_new2;


-- EXPLORATORY DATA ANALYSIS

select * 
from layoffs_new2;

select MAX(total_laid_off), max(percentage_laid_off)
from layoffs_new2;

select min(`date`), max(`date`)
from layoffs_new2;

select *
from layoffs_new2
where percentage_laid_off = 1
order by total_laid_off desc;

select company, sum(total_laid_off)
from layoffs_new2
GROUP BY company
order by 2 desc;

select country, sum(total_laid_off)
from layoffs_new2
GROUP BY country
order by 2 desc;

select industry, sum(total_laid_off)
from layoffs_new2
GROUP BY industry
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoffs_new2
GROUP BY year(`date`)
order by 1 desc;

SELECT YEAR(`date`) AS year, MONTH(`date`) AS month, 
SUM(total_laid_off) AS layoffs
FROM layoffs_new2
GROUP BY year, month
ORDER BY year, month;

select stage, sum(total_laid_off)
from layoffs_new2
GROUP BY stage
order by 2 desc;

SELECT substring(`date`,1,7) as Month, SUM(total_laid_off) AS layoffs
from layoffs_new2
where substring(`date`,1,7) is not null
GROUP BY substring(`date`,1,7)
ORDER BY 1 ASC;

# To know the rolling total for total_laid_off per month
With Rolling_total as (
SELECT substring(`date`,1,7) as Month, SUM(total_laid_off) AS Total_layoffs
from layoffs_new2
where substring(`date`,1,7) is not null
GROUP BY substring(`date`,1,7)
ORDER BY 1 ASC
)
select Month, Total_layoffs, sum(total_layoffs)
over (order by month) as Rolling
from rolling_total
;

# To determine the total_laid_off by each company per year
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS layoffs
FROM layoffs_new2
GROUP BY company, year
ORDER BY 3 DESC;

# To determine the ranking of the companies with highest layoffs partitioned by each year
with Yearly_layoff as 
(
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS layoffs
FROM layoffs_new2
GROUP BY company, year
ORDER BY 3 DESC
),
company_rankings as
(
select *, DENSE_RANK() over(PARTITION BY year ORDER BY layoffs desc) as Rankings
from yearly_layoff
where year is not null
)
select * 
from company_rankings
where rankings <= 5
;

# To determine the industries with the highest layoffs per year 

SELECT industry, YEAR(`date`) AS year, SUM(total_laid_off) AS layoffs
FROM layoffs_new2
GROUP BY industry, year
ORDER BY 3 DESC;

with Industry_yearly_layoff as 
(
SELECT industry, YEAR(`date`) AS year, SUM(total_laid_off) AS layoffs
FROM layoffs_new2
GROUP BY industry, year
ORDER BY 3 DESC
)
select *, DENSE_RANK() over(PARTITION BY year ORDER BY layoffs desc) as Rankings
from Industry_yearly_layoff
where year is not null;

select *
from layoffs_new2;

SELECT company, industry, YEAR(`date`) AS year, SUM(total_laid_off) AS layoffs
FROM layoffs_new2
GROUP BY company, industry, year
ORDER BY 4 DESC;

with company_industry_yearly_layoff as 
(
SELECT company, industry, YEAR(`date`) AS year, SUM(total_laid_off) AS layoffs
FROM layoffs_new2
GROUP BY company, industry, year
ORDER BY 4 DESC
),
Ranked_industries as
(
select *, DENSE_RANK() over(PARTITION BY industry, year ORDER BY layoffs desc) as Rankings
from company_industry_yearly_layoff
where year is not null
and industry is not null
)
select * 
from ranked_industries
where rankings = 1
order by 3;

