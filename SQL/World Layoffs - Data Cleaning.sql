-- DATA CLEANING

SELECT * 
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns That are Unnecessary

# create a staging table so you can manipulate data without deleting anything in the main table
create table layoffs_staging
like layoffs;

select * 
from layoffs_staging;

insert layoffs_staging
select * 
from layoffs;

# identify duplicates
# if row_num is 2+ then there are duplicates for that row
select *, 
	row_number() over(
		partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

with duplicate_cte as
	(select *, 
		row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
	from layoffs_staging
	)
select * 
from duplicate_cte
where row_num > 1;

select *
from layoffs_staging
where company = 'Casper';

# create layoffs_staging2 table by right clicking layoffs_staging on the left panel > copy to clipboard > create statement > paste
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text, 
  `row_num` int # add this column manually
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

# insert a copy of the columns into layoffs_staging2
insert into layoffs_staging2
select *, 
	row_number() over(
	partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

# delete any rows that are duplicates
delete
from layoffs_staging2
where row_num > 1;

# check if everything is deleted
select *
from layoffs_staging2
where row_num > 1;

-- Standardizing data: find issues and delete it

# check for duplicate companies and clean up by ensuring all spaces are trimmed
select company, (trim(company))
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

# check for duplicate industries
# notice that there are three types of crypto industry inputs
select distinct industry
from layoffs_staging2
order by 1; 

select *
from layoffs_staging2
where industry like 'Crypto%'; 

# update all industry data to Crypto if it begins with Crypto...
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%'; 

select distinct location
from layoffs_staging2
order by 1; 

select distinct country
from layoffs_staging2
order by 1; 

# there are two entries of 'United States' one with a period. so we need to clean that up:
select *
from layoffs_staging2
where country like 'United States%'
order by 1; 

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1; 

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select `date`, 
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2; 
  
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y')
WHERE `date` <> 'None'
  AND `date` IS NOT NULL
  AND `date` <> '';

# convert invlaid entries ('None', '') into NULL
UPDATE layoffs_staging2
SET `date` = NULL
WHERE `date` = 'None' OR `date` = '';

# modify date type to date
alter table layoffs_staging2
modify column `date` date;

UPDATE layoffs_staging2
SET
    percentage_laid_off = NULL
WHERE 
    percentage_laid_off = 'None';

UPDATE layoffs_staging2
SET
    industry = NULL
WHERE 
    industry = '';
    
select *
from layoffs_staging2;

select *
from layoffs_staging2
where industry is null
or industry = '';

select * 
from layoffs_staging2
where company = 'Airbnb';

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null; 

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null; 

# these rows are not really relevant because you don't even have data in these two columns for them... make decision to delete or not
# we will delete these rows
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null; 

delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null; 

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;
