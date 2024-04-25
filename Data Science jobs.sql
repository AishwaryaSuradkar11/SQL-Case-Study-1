use salaries;




/* Q1 - You're a Compensation analyst employed by a multinational corporation. 
Your Assignment is to Pinpoint Countries who give work fully remotely, for the title 'managers’ 
Paying salaries Exceeding $90,000 USD. */

select * from salaries;

select distinct(company_location)
from salaries 
where job_title like  "%Manager%" and salary_in_usd >= 90000 and remote_ratio = 100;

/* AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ 
clients IN large tech firms. you're tasked WITH Identifying top 5 Country Having greatest count of 
large (company size) number of companies. */

select * from salaries;

select company_location, count(company_location) as cnt
from salaries where company_size = 'L' and  experience_level = 'EN'
group by company_location
order by cnt desc
limit 5;

/* Q3 - Picture yourself AS a data scientist Working for a workforce management platform. 
Your objective is to calculate the percentage of employees. Who enjoy fully remote roles WITH 
salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions 
IN today's job market. */

select * from salaries;

set @total_count = (select count(*) from salaries where remote_ratio= 100 and salary_in_usd > 100000) ; 
set @total_remote = (select count(*) from salaries where  salary_in_usd > 100000);
set @Percent = round(((select @total_count)/(select @total_remote))*100,2);
select @Percent as "% people work remotely";


/* Q4 - Imagine you're a data analyst Working for a global recruitment agency. 
Your Task is to identify the Locations where entry-level average salaries exceed the average salary 
for that job title IN market for entry level, helping your agency guide candidates towards lucrative 
opportunities. */

select * from salaries;

select t.job_title,m.company_location,avg_salary,avg_country from
(
select job_title, avg(salary_in_usd) as avg_salary
from salaries where experience_level = 'EN'
group by job_title
)t
inner join
(
select company_location, job_title, avg(salary_in_usd) as avg_country
from salaries where experience_level = 'EN'
group by job_title, company_location
)m
on t.job_title = m.job_title where avg_country>avg_salary;

/* Q5 - You've been hired by a big HR Consultancy to look at how much people get paid IN different 
Countries. Your job is to Find out for each job title which. Country pays the maximum average salary. 
This helps you to place your candidates IN those countries. */

 select * from salaries;
 
 select * from
 (
 select *, dense_rank() over ( partition by job_title order by avg_salary desc) as 'rank1' from
(
select company_location, job_title, avg(salary_in_usd) as avg_salary from salaries
group by company_location, job_title
)t
)m where rank1 = 1;


/* Q6 - AS a data-driven Business consultant, you've been hired by a multinational corporation to 
analyze salary trends across different company Locations. Your goal is to Pinpoint Locations WHERE
the average salary Has consistently Increased over the Past few years (Countries WHERE data is 
available for 3 years Only(present year and past two years) providing Insights into Locations 
experiencing Sustained salary growth. */

select * from salaries where company_location in
(
select company_location from
(
select company_location, count(distinct work_year) as count, avg(salary_in_usd) 
from salaries
where work_year >= year(current_date())-2
group by company_location 
having count = 3
)m
)

/* Q7 -  Picture yourself AS a workforce strategist employed by a global HR tech startup. 
Your Mission is to Determine the percentage of fully remote work for each experience level IN 
2021 and compare it WITH the corresponding figures for 2024, Highlighting any significant Increases 
or decreases IN remote work Adoption over the years. */

select * from salaries;

select * from
(
select * , ((total_2021/total_remote)*100) as remote_2021 from
(
select a.experience_level, total_remote, total_2021 from 
(select experience_level,count(*) as total_2021 from salaries where remote_ratio= 100 and work_year in (2021)
group by experience_level
)a
inner join
(select experience_level,count(*) as total_remote from salaries where work_year in (2021)
group by experience_level)b
on a.experience_level = b.experience_level)c
)m
inner join 
(
select *, ((total_2024/total_remote)*100) as remote_2024 from 
(select c.experience_level, total_remote, total_2024 from 
(select experience_level,count(*) as total_2024 from salaries where remote_ratio= 100 and work_year in (2024)
group by experience_level
)c
inner join
(select experience_level,count(*) as total_remote from salaries where work_year in (2024)
group by experience_level)d
on c.experience_level = d.experience_level)e
)n
on m.experience_level = n.experience_level;

/* Q8 - AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary 
trends over time. Your objective is to calculate the average salary increase percentage for each 
experience level and job title between the years 2023 and 2024, helping the company stay competitive 
IN the talent market.  */

WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  



SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL 




/* Q9 - You're a database administrator tasked with role-based access control for a company's employee 
database. Your goal is to implement a security measure where employees in different experience level 
(e.g. Entry Level, Senior level etc.) can only access details relevant to their respective experience 
level, ensuring data confidentiality and minimizing the risk of unauthorized access. */


CREATE USER 'Entry_level'@'%' IDENTIFIED BY 'EN';
CREATE USER 'Junior_Mid_level'@'%' IDENTIFIED BY ' MI '; 
CREATE USER 'Intermediate_Senior_level'@'%' IDENTIFIED BY 'SE';
CREATE USER 'Expert Executive-level '@'%' IDENTIFIED BY 'EX ';


CREATE VIEW entry_level AS
SELECT * FROM salaries where experience_level='EN'

GRANT SELECT ON campusx.entry_level TO 'Entry_level'@'%'

UPDATE view entry_level set WORK_YEAR = 2025 WHERE EMPLOYNMENT_TYPE='FT'
