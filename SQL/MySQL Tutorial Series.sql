-- SELECT STATEMENT
select * 
from Parks_and_Recreation.employee_demographics;

select first_name, last_name 
from employee_demographics;

select distinct gender 
from Parks_and_Recreation.employee_demographics;

-- WHERE CLAUSE
select * 
from parks_and_recreation.employee_salary 
where dept_id is null;

-- LIKE CLAUSE
select * 
from employee_demographics 
where birth_date 
like '1989%';

select * 
from employee_demographics 
where first_name 
like '%n%';

select * 
from employee_demographics 
where first_name 
like 'A__';

-- GROUP BY AND AGGREGATE FUNCTIONS
select gender, avg(age), max(age), min(age), count(first_name) 
from employee_demographics
group by gender;

select occupation, salary
from employee_salary
group by occupation, salary;

-- ORDER BY
select * from employee_demographics order by gender, age DESC;

-- HAVING
select gender, avg(age)
from employee_demographics 
group by gender 
having avg(age) > 40;

select occupation, avg(salary) 
from employee_salary
group by occupation; 

## to see which type of manager makes avg higher salary
select occupation, avg(salary)
from employee_salary
where occupation like '%manager%'
group by occupation
having avg(salary) > 75000; 

-- LIMIT
# specifies how many rows you want in you output
select *
from employee_demographics
limit 3;

# combine use with order by to get the 3 oldest ages
select *
from employee_demographics
order by age desc
limit 3;

# 2, 1: starts at position 2 and get the 1 row after
select *
from employee_demographics 
order by age desc 
limit 2, 1;

-- ALIASING
# setting aggregate function to a variable name, therefore instead of having to repeat avg(age) you can set it to a variable name. this will also change the column output name
select gender, avg(age) as avg_age 
from employee_demographics 
group by gender 
having avg_age > 40;

# or
select gender, avg(age) avg_age
from employee_demographics
group by gender
having avg_age > 40;

-- INNNER JOINS (you can use join or inner join)
# combine two tables or more if they have a common column
# both of these tables have the column employee_id 
select * 
from employee_demographics;

select * 
from employee_salary;

# selecting all the rows that have the same id in both tables
select *
from employee_demographics as dem
join employee_salary as sal
	on dem.employee_id = sal.employee_id;
    
select dem.employee_id, age, occupation
from employee_demographics as dem
join employee_salary as sal
	on dem.employee_id = sal.employee_id;

-- OUTER JOINS
# there is a left and right outer join (can use "left outer join" or "left join")
# takes everything from the employee demographics table (the left table) and tries to find a match in the right table (employee salary)
select *
from employee_demographics as dem
left outer join employee_salary as sal
	on dem.employee_id = sal.employee_id;
    
# takes everything from the employee salary table (the right table) and tries to find a match in the left table (employee dem)
# even if there is no match, it will populate all the rows from the right table (notice row 2 = null bc nothing is in the left table for this employee id)
select *
from employee_demographics as dem
right outer join employee_salary as sal
	on dem.employee_id = sal.employee_id;

-- SELF JOIN
# you tie a table to itself 
# example you are doing a secret santa for your company and want to assign ppl based off of employee id
select emp1.employee_id as emp_santa,
	emp1.first_name as first_name_santa,
	emp1.last_name as last_name_santa, 
	emp2.employee_id as emp_name,
	emp2.first_name as first_name_emp,
	emp2.last_name as last_name_emp
from employee_salary emp1
join employee_salary emp2
	on emp1.employee_id + 1 = emp2.employee_id ;

### joining multiple tables together
select dem.employee_id, 
	dem.first_name, 
    dem.last_name, 
    dem.age, dem.gender, 
    dem.birth_date, 
    sal.occupation, 
    sal.salary, 
    pd.department_name
from employee_demographics as dem
inner join employee_salary as sal
	on dem.employee_id = sal.employee_id
inner join parks_departments pd
	on sal.dept_id = pd.department_id;

# parks_departments is a reference table. it has a dept id column that is also in the salary table
select * 
from parks_departments;

-- UNIONS
# allows you to combine rows together from separate or the same table
# union all vs union distinct
select first_name, last_name
from employee_demographics 
union all
select first_name, last_name
from employee_salary;

select first_name, last_name
from employee_demographics 
union distinct
select first_name, last_name
from employee_salary;

select first_name, last_name, 'old man' as 'label'
from employee_demographics 
where age > 40 and gender = 'male'
union
select first_name, last_name, 'old lady' as 'label'
from employee_demographics 
where age > 40 and gender = 'female'
union
select first_name, last_name,  'highly paid employee' as label
from employee_salary
where salary > 70000
order by first_name, last_name;

-- STRING FUNCTIONS
### length
select length('skyfall');

select first_name, length(first_name)
from employee_demographics
order by 2;

### upper and lower
select first_name, upper(first_name)
from employee_demographics
order by 2;

select first_name, lower(first_name)
from employee_demographics
order by 2;

### trim
select trim('          sky            ');
select ltrim('          sky            ');
select rtrim('          sky            ');

#### substring starts from the indicated position and take n amount from the left
select first_name, 
	left(first_name,4), 
    right(first_name,4),
	substring(first_name,3,2), 
    birth_date, 
    substring(birth_date,6,2) as 'month'
from employee_demographics;

### replace
select first_name, 
	replace (first_name,'a','z') 
from employee_demographics;

### locate
select locate('x', 'Alexander');

select first_name, 
	locate('An',first_name) 
from employee_demographics;

### concat -- combine strings together
select first_name, 
	last_name, 
	concat(first_name,' ',last_name) as 'full name'
from employee_demographics;
 
select concat(first_name,' ',last_name) as 'full name'
 from employee_demographics;
 
-- CASE STATEMENTS
select first_name, last_name, age,
case
	when age <= 30 then 'Young'
    when age between 31 and 50 then 'old'
    when age >= 50 then 'super old'
end as age_bracket
from employee_demographics;

# example pay increase and bonus based on salary
-- < 50000 = 5% increase
-- > 50000 = 7% increase
-- finance = 10% bonus

select * from employee_salary;
select * from parks_departments;

select first_name, last_name, salary,
case
	when salary < 50000 then salary + (salary*0.05)
	when salary > 50000 then salary + (salary*0.07)
end as new_salary,
case
	when dept_id = 6  then salary *.10
end as bonus
from employee_salary;

-- SUBEQUERIES
select *
from employee_demographics
where employee_id in 
	(select employee_id
	from employee_salary
	where dept_id = 1);

select first_name,
	salary, 
	(select avg(salary) 
	from employee_salary)
from employee_salary;

select gender, 
	avg(age), 
    max(age), min(age), 
    count(age)
from employee_demographics
group by gender;

select avg(max_age)
from
	(select gender, 
		avg(age) as avg_age, 
		max(age) as max_age, 
		min(age) as min_age, 
		count(age) as count_age
	from employee_demographics group by gender) 
	as agg_table;

-- WINDOW FUNCTIONS
-- windows functions are really powerful and are somewhat like a group by - except they don't roll everything up into 1 row when grouping. 
-- windows functions allow us to look at a partition or a group, but they each keep their own unique rows in the output
-- we will also look at things like Row Numbers, rank, and dense rank

# look at a group in a unique row output
select dem.first_name,
	dem.last_name, 
    gender, 
    avg(salary) as avg_salary
from employee_demographics as dem
join employee_salary as sal
	on dem.employee_id = sal.employee_id
group by dem.first_name, dem.last_name, gender;

# over() looks at everything
# unlike group by, partition by gender keeps it on individual rows instead of one row for female, male
# avg salary is completely independent of other columns. ie you can add other columns and the avg salary calculation wont be affected
select dem.first_name,
	dem.last_name,
    gender,
    avg(salary) over(partition by gender)
from employee_demographics as dem
join employee_salary as sal
	on dem.employee_id = sal.employee_id;

# rolling total 
select dem.first_name, 
	dem.last_name, 
    gender, 
    salary,
	sum(salary) over(partition by gender order by dem.employee_id) as rolling_total
from employee_demographics as dem
join employee_salary as sal
	on dem.employee_id = sal.employee_id;
    
select dem.first_name, 
	dem.last_name, 
    gender, 
    salary,
	sum(salary) over(order by dem.employee_id) as rolling_total
from employee_demographics as dem
join employee_salary as sal
	on dem.employee_id = sal.employee_id;

### row_number will not have duplicates, simply just numbers the row
### rank encounters a duplicate you are ordering by, it would just duplicate the number and skip (ex. 5,5, 7, skipping 6)
### dense_rank does not skip a number (ex. 5, 5, 6)
select dem.employee_id,
	dem.first_name,
    dem.last_name, 
    gender, 
    salary,
	row_number() over(partition by gender order by salary desc) as row_num,
	rank() over(partition by gender order by salary desc) rank_num,
	dense_rank() over(partition by gender order by salary desc) dense_rank_num
from employee_demographics as dem
join employee_salary as sal
	on dem.employee_id = sal.employee_id;
    
-- CTE - common table expressions
with cte_example (gender, avg_sal, max_sal, min_sal, count_sal) as
	(
	select gender, avg(salary), max(salary), min(salary), count(salary)
	from employee_demographics dem
	join employee_salary sal
		on dem.employee_id = sal.employee_id
	group by gender)
select * 
from cte_example;

with cte_example as
	(
	select employee_id, gender, birth_date
	from employee_demographics
	where birth_date > '1985-01-01'
	),
cte_example2 as 
	(
	select employee_id, salary
	from employee_salary
	where salary > 50000
	)
select *
from cte_example as ex1
join cte_example2 as ex2
	on ex1.employee_id = ex2.employee_id
;

-- TEMPORARY TABLES
# tables that are only visible in the session that they are created in
create temporary table temp_table
(first_name varchar(50),
last_name varchar(50),
favourite_movie varchar(100)
);

select * from temp_table;

insert into temp_table
values('alex','freeberg','Lord of the RIngs: The Two Towers');

select * 
from employee_salary;

create temporary table salary_over_50k
select * 
from employee_salary
where salary >= 50000;

select * from salary_over_50k;


-- STORED PROCEDURES
# save your code and run it over again
select * from employee_salary
where salary >= 50000;

create procedure large_salaries()
select * from employee_salary
where salary >= 50000;

call large_salaries;

DROP PROCEDURE if exists large_salaries2;

# the delimeter can be anything ex. $$, /, &&
# by setting a delimeter, the semi-colons; no longer mark the end of a code 
delimiter $$
create procedure large_salaries2()
begin
	select * from employee_salary
	where salary >= 50000;
	select * from employee_salary
	where salary >= 10000;
end $$
delimiter ;

call large_salaries2();

delimiter $$
create procedure large_salaries3(huggymuffin int)
begin
	select salary from employee_salary
    where employee_id = huggymuffin;
end $$
delimiter ;

# then you will call the table and set the input paramater to a interger (huggymuffin = 1)
call large_salaries3(1);



-- TRIGGERS
# triggers take place automatically when an event takes place
# ex. when employee_salary table is updated, employee_demographics will be automatically updated
delimiter $$
create trigger employee_insert
	after insert on employee_salary
    for each row
begin
	insert into employee_demographics (employee_id, first_name, last_name)
    values (new.employee_id, new.first_name, new.last_name);
end $$
delimiter ;

insert into employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
values(13, 'Jean-Ralphio', 'Sapersteint', 'Entertainment 720 CEO', 1000000, NULL);

select * from employee_salary;
select * from employee_demographics;

### events
# takes place when scheduled, a scheduled automator 
# ex. retire people over the age of 60 and delete them from the table 
select * from employee_demographics; 

delimiter $$
create event delete_retirees
on schedule every 30 second
do
begin
	delete
    from employee_demographics
    where age >= 60;
end $$
delimiter $$

drop event delete_retirees;