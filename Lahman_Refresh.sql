-- Question 1
-- 1. What range of years for baseball games played does the provided database cover? 
SELECT MAX(yearid),MIN(yearid)
FROM batting;

--Question 2
--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT 	p.height,
		a.teamid,
		a.g_all,
		p.namegiven,
		p.namefirst,
		P.namelast,
		t.name
FROM people AS p
INNER JOIN appearances AS a
USING(playerid)
INNER JOIN teams AS t
USING(teamid)
WHERE p.height IS NOT NULL
GROUP BY p.namefirst, p.namelast,a.teamid,a.teamid,p.namegiven,a.g_all,t.name,p.height
ORDER BY p.height
LIMIT 1;

--Question 3
--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT p.namefirst,
		p.namelast,
		SUM(s1.salary::numeric::money) AS total_salary
FROM schools AS s
INNER JOIN collegeplaying AS c
USING (schoolid)
INNER JOIN people AS p
USING(playerid)
INNER JOIN salaries AS s1
USING(playerid)
WHERE s.schoolname ILIKE '%vanderbilt%'
GROUP BY p.namelast,
		p.namefirst
ORDER BY SUM(s1.salary) DESC;

--Question 4
--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT SUM(po),
	CASE WHEN pos = 'OF' THEN 'Outfield'
		 WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'Infield'
		 WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
		 ELSE 'Missing' END AS Position
FROM fielding
WHERE yearid = 2016
GROUP BY Position
ORDER BY SUM(po) DESC;

--Question 5
--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT ROUND((SUM(so)/SUM(g)::NUMERIC),2),
		ROUND((SUM(hr)/SUM(g)::NUMERIC),2),
		SUM(so),
	   CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	   		WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
				END AS decade
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade DESC;

--Question 6
--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
SELECT 	p.namefirst,
		p.namelast,
		b.sb,
		b.cs,
		ROUND(SUM(sb)::NUMERIC *100/((SUM(sb)::NUMERIC)+SUM(cs)::NUMERIC),2) AS stolen_percent
FROM batting AS b
INNER JOIN people AS p
USING(playerid)
WHERE (sb+cs) >= 20
	AND yearid = 2016
GROUP BY playerid, p.namefirst, p.namelast, b.sb, b.cs
ORDER BY stolen_percent DESC;


--Question 7
--Part 1
--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
WITH lowest_ws AS (SELECT   name,
				   			yearid,
				   			wswin,
				   			w,
				   			divid
					FROM teams
					WHERE yearid BETWEEN 1970 AND 2016
				   		AND wswin ILIKE '%y%'
				  		AND w IN (SELECT MIN(w)
								 FROM teams
								 WHERE wswin ILIKE '%y%'))
SELECT  h.name,
		h.yearid,
		h.w,
		h.wswin,
		l.name,
		l.yearid,
		l.w,
		l.wswin
FROM teams AS h
INNER JOIN lowest_ws AS l
USING(divid)
WHERE h.yearid BETWEEN 1970 AND 2016
	AND h.wswin ILIKE '%n%'
	AND h.w IN (SELECT MAX(w)
			 FROM teams
			 WHERE wswin ILIKE '%n%');
			 
-- Alternative Way to Solve Part 1

(SELECT name,
		yearid,
		w,
		wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
		AND wswin ILIKE '%n%'
		AND w IN (SELECT MAX(w)
				  FROM teams
				  WHERE wswin ILIKE '%n%'))
UNION
(SELECT name,
		yearid,
		w,
		wswin
FROM teams
WHERE 	yearid BETWEEN 1970 AND 2016
		AND wswin ILIKE '%y%'
		AND w IN (SELECT MIN(w)
				  FROM teams
				  WHERE yearid BETWEEN 1970 AND 2016
				  		AND wswin ILIKE '%y%'))

-- Part 2		 
--Then redo your query, excluding the problem year. 
(SELECT 	name,
		yearid,
		w,
		wswin
FROM teams
WHERE (yearid BETWEEN 1970 AND 1980
		OR yearid BETWEEN 1982 AND 2016)
		AND wswin ILIKE '%n%'
		AND w IN (SELECT MAX(w)
				  FROM teams
				  WHERE wswin ILIKE '%n%'))
UNION
(SELECT 	name,
		yearid,
		w,
		wswin
FROM teams
WHERE (yearid BETWEEN 1970 AND 1980
		OR yearid BETWEEN 1982 AND 2016)
		AND wswin ILIKE '%y%'
		AND w IN (SELECT MIN(w)
				  FROM teams
				  WHERE (yearid BETWEEN 1970 AND 1980
							OR yearid BETWEEN 1982 AND 2016)
				  		AND wswin ILIKE '%y%'))
--Part 3
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
WITH max AS(SELECT 	w,
					yearid,
					wswin,
					teamid,
					name, 
					MAX(w)OVER(PARTITION BY yearid) AS max_wins
			FROM teams),
year AS (SELECT t.yearid,
		 		m.w
		FROM teams AS t
		INNER JOIN max AS m
		 ON m.yearid = t.yearid
		WHERE t.w = m.max_wins)
SELECT 	ROUND((COUNT(DISTINCT(m.max_wins))::NUMERIC/COUNT(DISTINCT(t.yearid)))*100,3)::NUMERIC AS percent_max_wins_wswin
FROM teams AS t
INNER JOIN max AS m
ON t.yearid = m.yearid
	AND t.teamid = m.teamid
INNER JOIN year AS y
ON t.yearid = y.yearid
WHERE t.wswin ILIKE '%y%'
	AND (t.yearid BETWEEN 1970 AND 1980
	   OR t.yearid BETWEEN 1982 AND 2016);
	   
--Question 8
--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. 
--Question 8
--Part 1
SELECT t.name,
		p.park_name,
		h.attendance/h.games AS average_attendance
FROM homegames AS h
INNER JOIN parks AS p
USING(park)
INNER JOIN teams AS t
USING(attendance)
WHERE year = '2016'
	AND games >='10'
ORDER BY average_attendance DESC
LIMIT 5;
--Highest Average Attendance 2016
--Part 2
--Repeat for the lowest 5 average attendance.
SELECT t.name,
		p.park_name,
		h.attendance/h.games AS average_attendance
FROM homegames AS h
INNER JOIN parks AS p
USING(park)
INNER JOIN teams AS t
USING(attendance)
WHERE year = '2016'
	AND games >='10'
ORDER BY average_attendance
LIMIT 5;
--Lowest Average Attendance 2016	

--Question 9
SELECT p.namefirst, p.namelast, a.yearid, t.name
FROM managers AS m
INNER JOIN people AS p
USING (playerid)
INNER JOIN awardsmanagers AS a
ON m.playerid=a.playerid
	AND m.yearid=a.yearid
INNER JOIN teams AS t
ON m.yearid=t.yearid
	AND m.teamid=t.teamid
WHERE a.playerid IN (SELECT playerid
				  FROM awardsmanagers
				  WHERE awardid = 'TSN Manager of the Year'
				  		AND lgid = 'NL')
	AND a.playerid IN (SELECT playerid
				  FROM awardsmanagers
				  WHERE awardid = 'TSN Manager of the Year'
				  		AND lgid = 'AL')	
GROUP BY a.yearid ,p.namefirst, p.namelast,t.name;

--Question 10
--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
WITH hr_2016 AS (SELECT 	p.playerid,
				 			p.namelast,
				 			p.namefirst,
				 			MAX(hr) AS total_hr_2016
				FROM batting AS b
				INNER JOIN people AS p
				ON b.playerid=p.playerid
				WHERE b.yearid = '2016'
					AND (date(p.finalgame)-date(p.debut))/365 >=10
					AND hr >1
				GROUP BY p.playerid),
career_hr AS (SELECT MAX(hr) AS max_hr,
	 		 playerid
			 FROM batting
			 GROUP BY playerid)
SELECT 	h1.total_hr_2016,
		h1.namefirst,
		h1.namelast
FROM hr_2016 AS h1
INNER JOIN career_hr AS h2
USING(playerid)
WHERE (total_hr_2016-max_hr) =0;