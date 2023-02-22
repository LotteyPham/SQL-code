-- Q1:
/*Generate the following two result sets:

Query an alphabetically ordered list of all names in OCCUPATIONS, immediately followed by the first letter of each profession as a parenthetical (i.e.: enclosed in parentheses). For example: AnActorName(A), ADoctorName(D), AProfessorName(P), and ASingerName(S).
Query the number of ocurrences of each occupation in OCCUPATIONS. Sort the occurrences in ascending order, and output them in the following format:

There are a total of [occupation_count] [occupation]s.
where [occupation_count] is the number of occurrences of an occupation in OCCUPATIONS and [occupation] is the lowercase occupation name. If more than one Occupation has the same [occupation_count], they should be ordered alphabetically.

Note: There will be at least two entries in the table for each type of occupation.*/


select concat (name,'(',left(occupation,1),')') as name
from OCCUPATIONS 
order by name
select concat ('There are a total of ',count (occupation),' ',lower(occupation),'s.') as Total
from OCCUPATIONS
group by occupation
order by total


--Q2:
/*
Consider P1(a,b) and P2(c,d) to be two points on a 2D plane.

 a happens to equal the minimum value in Northern Latitude (LAT_N in STATION).
b happens to equal the minimum value in Western Longitude (LONG_W in STATION).
c happens to equal the maximum value in Northern Latitude (LAT_N in STATION).
d happens to equal the maximum value in Western Longitude (LONG_W in STATION).
Query the Manhattan Distance between points P1 and P2 and round it to a scale of 4 decimal places.
*/
SELECT CAST((MAX(Lat_N) - MIN(Lat_N) + MAX(Long_W) - MIN(Long_W)) AS DECIMAL(12, 4))
FROM Station

--Q3: 
/*
Consider P1(a,c) and P2(b,d) to be two points on a 2D plane where (a,b) are the respective minimum and maximum values of Northern Latitude (LAT_N) and (c,d) are the respective minimum and maximum values of Western Longitude (LONG_W) in STATION.

Query the Euclidean Distance between points P1 and P2 and format your answer to display 4 decimal digits.
*/
SELECT
    CAST(SQRT (
       POWER((MAX(LAT_N)-MIN(LAT_N)),2) +
       POWER((MAX(LONG_W)-MIN(LONG_W)),2))AS DECIMAL(20,4))
FROM STATION

--Q4:
/*
You are given a table, BST, containing two columns: N and P, where N represents the value of a node in Binary Tree, and P is the parent of N.
Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of the following for each node:

Root: If node is root node.
Leaf: If node is leaf node.
Inner: If node is neither root nor leaf node.
*/
SELECT
	N,
	CASE WHEN P IS NULL THEN 'Root'
		 WHEN N IN (SELECT DISTINCT P FROM BST) THEN 'Inner'
		 ELSE 'Leaf'
	END
FROM BST
ORDER BY N

--Q5:
/*
Amber's conglomerate corporation just acquired some new companies. Each of the companies follows this hierarchy: Founder -> Lead Manager ->senior Manager -> manager -> employee

Given the table schemas below, write a query to print the company_code, founder name, total number of lead managers, total number of senior managers, total number of managers, and total number of employees. Order your output by ascending company_code.

Note:

The tables may contain duplicate records.
The company_code is string, so the sorting should not be numeric. For example, if the company_codes are C_1, C_2, and C_10, then the ascending company_codes will be C_1, C_10, and C_2.
*/
select  c.company_code, 
        c.founder, 
        count(distinct lm.lead_manager_code), 
        count(distinct sm.senior_manager_code), 
        count(distinct m.manager_code), 
        count(distinct e.employee_code)

from Company c, Lead_Manager lm, Senior_Manager sm, Manager m, Employee e
where c.company_code = lm.company_code
    and lm.lead_manager_code = sm.lead_manager_code
    and sm.senior_manager_code = m.senior_manager_code
    and m.manager_code = e.manager_code
group by c.company_code, c.founder
order by c.company_code

--Q6: 
/*
A median is defined as a number separating the higher half of a data set from the lower half. Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to 4 decimal places.
*/
select 
    cast(lat_n as decimal(10,4)) 
from
    (select lat_n, row_number() over (order by lat_n desc) as rnum1 
     from station
    ) t1
where rnum1 = 
        (select 
            case 
                when max(rnum)%2=0 then max(rnum)/2
                else (max(rnum)+1)/2 
            end 
        from 
            (select row_number() over (order by lat_n desc) as rnum 
             from station
            ) t
        )
--Q7:
/*
You are given two tables: Students and Grades. Students contains three columns ID, Name and Marks
Ketty gives Eve a task to generate a report containing three columns: Name, Grade and Mark. Ketty doesn't want the NAMES of those students who received a grade lower than 8. The report must be in descending order by grade -- i.e. higher grades are entered first. If there is more than one student with the same grade (8-10) assigned to them, order those particular students by their name alphabetically. Finally, if the grade is lower than 8, use "NULL" as their name and list them by their grades in descending order. If there is more than one student with the same grade (1-7) assigned to them, order those particular students by their marks in ascending order.
Note:
Print "NULL"  as the name if the grade is less than 8.
*/
SELECT IIF(GRADE < 8, NULL, NAME),
        GRADE,
        MARKS
FROM Students JOIN Grades
ON MARKS >= MIN_MARK AND MARKS <= MAX_MARK
ORDER BY GRADE DESC, NAME, MARKS

--Q8:
/*
Julia just finished conducting a coding contest, and she needs your help assembling the leaderboard! Write a query to print the respective hacker_id and name of hackers who achieved full scores for more than one challenge. Order your output in descending order by the total number of challenges in which the hacker earned a full score. If more than one hacker received full scores in same number of challenges, then sort them by ascending hacker_id.
*/

SELECT H.hacker_id, H.name
FROM Submissions S
 INNER JOIN  Challenges C  ON C.challenge_id = S.challenge_id
 INNER JOIN Difficulty D ON C.difficulty_level = D.difficulty_level and D.score = S.score
 INNER JOIN Hackers H ON H.hacker_id= S.hacker_id
GROUP BY H.hacker_id, H.name
HAVING COUNT(H.hacker_id) > 1
ORDER BY COUNT(H.hacker_id) DESC, H.hacker_id

--Q9:
/*
Harry Potter and his friends are at Ollivander's with Ron, finally replacing Charlie's old broken wand.

Hermione decides the best way to choose is by determining the minimum number of gold galleons needed to buy each non-evil wand of high power and age. Write a query to print the id, age, coins_needed, and power of the wands that Ron's interested in, sorted in order of descending power. If more than one wand has same power, sort the result in order of descending age.
*/
SELECT id, age, coins_needed, power
FROM 
(
    SELECT W.id, WP.age, W.coins_needed, W.power,
    ROW_NUMBER() OVER 
        (
            PARTITION BY W.code,W.power  
            ORDER BY W.coins_needed, W.power DESC
        ) AS RowNumber
    FROM Wands W WITH (NOLOCK)
    INNER JOIN Wands_Property WP WITH (NOLOCK) ON W.code = WP.code
    WHERE WP.is_evil = 0
)
AS Wand_Data
WHERE RowNumber = 1
ORDER BY power DESC, age DESC
--Q10:
/*
Julia asked her students to create some coding challenges. Write a query to print the hacker_id, name, and the total number of challenges created by each student. Sort your results by the total number of challenges in descending order. If more than one student created the same number of challenges, then sort the result by hacker_id. If more than one student created the same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.
*/
WITH A AS (
    SELECT C.hacker_id, H.name, Count (challenge_id) as Num_Of_Challenge
    FROM Challenges C
    LEFT JOIN Hackers H ON H.hacker_id = C.hacker_id
    GROUP BY C.hacker_id, H.name)
SELECT hacker_id,
       name,
       Num_Of_Challenge
FROM A
WHERE Num_Of_Challenge = (select max (Num_Of_Challenge) from A)
      or Num_Of_Challenge in (  select Num_Of_Challenge from A
                                GROUP BY Num_Of_Challenge
                                HAVING count(Num_Of_Challenge)=1 )
ORDER BY Num_Of_Challenge DESC, hacker_id

--Q11:
/*
You did such a great job helping Julia with her last coding contest challenge that she wants you to work on this one, too!

The total score of a hacker is the sum of their maximum scores for all of the challenges. Write a query to print the hacker_id, name, and total score of the hackers ordered by the descending score. If more than one hacker achieved the same total score, then sort the result by ascending hacker_id. Exclude all hackers with a total score of 0 from your result.
*/

WITH A AS (
    SELECT hacker_id, max(score) as max_score 
    FROM Submissions 
    GROUP BY hacker_id, challenge_id
    )

SELECT A.hacker_id, H.name, SUM(max_score) AS total_score
FROM Hackers H
LEFT JOIN A ON H.hacker_id = A.hacker_id
GROUP BY a.hacker_id, H.name
HAVING SUM(max_score) > 0
ORDER BY total_score DESC, hacker_id
