-- EXPLORATORY DATA ANALYSIS

select * 
from layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

select max(total_laid_off),
	max(percentage_laid_off)
from layoffs_staging2;

select * 
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

# look at total layoffs per company
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc; 

# look at total layoffs per industry
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc; 

# look at total layoffs per country
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc; 

# look at when layoffs were captured in this dataset
select min(`date`), max(`date`)
from layoffs_staging2;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 asc; 

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc; 

# rolling sum of layoffs based off of month
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7)
group by `month`
order by 1 asc;

with rolling_total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7)
group by `month`
order by 1 asc
)
select `month`, total_off, sum(total_off)
over(order by `month`) as rolling_total
from rolling_total;

# look at how many layoffs for each company per year
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc; 

# check the top 5 compannies that had the most layoffs based on year
with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), 
company_year_rank as
(
select *,
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select * 
from company_year_rank
where ranking <= 5; 
