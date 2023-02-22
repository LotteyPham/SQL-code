--Q1:
/*
You are given a table, Projects, containing three columns: Task_ID, Start_Date and End_Date. 
It is guaranteed that the difference between the End_Date and the Start_Date is equal to 1 day for each row in the table.
If the End_Date of the tasks are consecutive, then they are part of the same project. 
Samantha is interested in finding the total number of different projects completed.

Write a query to output the start and end dates of projects listed by the number of days 
it took to complete the project in ascending order. If there is more than one project that have the same number of completion days, 
then order by the start date of the project.
*/
WITH
T1 as (
SELECT start_date, ROW_NUMBER() OVER(ORDER BY start_date) AS rn 
FROM projects 
WHERE start_date NOT IN(SELECT end_date FROM projects)
),

T2 as (
SELECT end_date, ROW_NUMBER() OVER(ORDER BY end_date) AS rn 
FROM projects 
WHERE end_date NOT IN(SELECT start_date FROM projects)
)

SELECT T1.start_date, T2.end_date
FROM T1 INNER JOIN T2 ON T1.rn = T2.rn 
ORDER BY DATEDIFF(DAY,T2.end_date,T1.start_date) DESC, T1.start_date

--Q2:
/*
Two pairs (X1, Y1) and (X2, Y2) are said to be symmetric pairs if X1 = Y2 and X2 = Y1.

Write a query to output all such symmetric pairs in ascending order by the value of X. List the rows such that X1 ≤ Y1.
*/
select distinct x,y 
from Functions f1 
where
	(x=y and x IN (select x from Functions group by x,y having count(*)>1)) 
	OR
	x<y and f1.x IN (select f2.y from Functions f2 where f2.x = f1.y)
ORDER BY x

--Q3:
/*
Samantha interviews many candidates from different colleges using coding challenges and contests.
Write a query to print the contest_id, hacker_id, name, and the sums of total_submissions, 
total_accepted_submissions, total_views, and total_unique_views for each contest sorted by contest_id. 
Exclude the contest from the result if all four sums are 0.

Note: A specific contest can be used to screen candidates at more than one college, but each college only holds 1 screening contest.
*/
with G as (
    select  
        V.challenge_id,
        0 as total_submissions,
        0 as total_accepted_submissions,
        total_views,
        total_unique_views
    from View_Stats V
    union all
    select  
        S.challenge_id,
        total_submissions,
        total_accepted_submissions,
        0 as total_views,
        0 as total_unique_views
    from Submission_Stats S  
  )
select  c.contest_id, 
        c.hacker_id, 
        c.name,  
        sum(total_submissions) as total_submissions,
        sum(total_accepted_submissions) as total_accepted_submissions,
        sum(total_views) as total_views,
        sum(total_unique_views) as total_unique_views     
from Contests c
inner join Colleges co on co.contest_id = c.contest_id
inner join Challenges ch on ch.college_id = co.college_id
inner join G on G.challenge_id =ch.challenge_id
where  (total_submissions
        + total_accepted_submissions 
        + total_views
        + total_unique_views )>0
group by c.contest_id, c.hacker_id, c.name
order by c.contest_id

--Q4:
/*
Julia conducted a 15 days of learning SQL contest. The start date of the contest was March 01, 2016 and the end date was March 15, 2016.

Write a query to print total number of unique hackers who made at least 1  submission each day (starting on the first day of the contest), 
and find the hacker_id and name of the hacker who made maximum number of submissions each day. 
If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. The query should print this information 
for each day of the contest, sorted by the date.
*/

with a as (
  select distinct hacker_id, submission_date from submissions
), b as (
  select hacker_id, submission_date, row_number() over (partition by hacker_id order by submission_date ) cc
    from a    
 ) , c as (
  select * from b
  where day(submission_date) = cc 
) , p1 as (
select c.submission_date, count(*) cc 
    from c
  group by c.submission_date
), d as (
  select s.hacker_id, s.submission_date, count(*) num_sub
  from submissions s 
  group by s.hacker_id, s.submission_date
), p2 as (
  select distinct submission_date, first_value(hacker_id) over (partition by submission_date order by num_sub desc, hacker_id) fv
  from d)

  select p1.submission_date, cc, fv, name
  from p1
  join p2 on p1.submission_date=p2.submission_date
  join hackers h on h.hacker_id=p2.fv

  --Q5: Draw The Triangle 1

DECLARE @VAR INT 
SELECT @VAR = 20 
WHILE @VAR > 0 
BEGIN PRINT REPLICATE("* ", @VAR) 
SET @VAR = @VAR - 1 
END

  --Q6: Draw The Triangle 2
DECLARE @VAR INT 

SELECT @VAR = 1
WHILE @VAR <= 20 
BEGIN PRINT REPLICATE("* ", @VAR) 
SET @VAR = @VAR + 1 
END

-- Q6:
/*
Write a query to print all prime numbers less than or equal to 1000. 
Print your result on a single line, and use the ampersand (&) character as your separator (instead of a space).
*/
declare @result1 nvarchar(4000) = '2'

declare @n int = 1000

declare @i decimal(10,5) = 3

declare @boundary int
declare @isPrime int
declare @loop int

while @i < @n
begin
    select @boundary = cast(Sqrt(@i) as int)
    set @loop = 3
    set @isprime = 1

    if @i = 1 begin set @isprime = 0 end
    if @i = 2 begin set @isprime = 1 end
    if @i % 2 = 0 begin set @isprime = 0 end

    while @loop <= @boundary and @isprime = 1
    begin
        if @i % @loop = 0 begin set @isprime = 0 end
        set @loop = @loop + 2
    end

    if @isprime = 1
    begin
        set @result1 = @result1 + '&' + cast(cast(@i as int) as nvarchar(10))
    end

    set @i = @i + 1
end

select @result1