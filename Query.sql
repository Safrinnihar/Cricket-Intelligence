1. -- Create a table named ‘matches’ with appropriate data types for columns.
	
Create type yes_no as Enum ('Y','N');

Create table matches (
	Id int, 
	City varchar(20),
	Date date,
	Player_Of_Match varchar, 
	Venue varchar, 
	Neutral_Venue bytea,
	Team1 Varchar,
	Team2 Varchar, 
	Toss_Winner Varchar, 
	Toss_Decision varchar, 
	Winner Varchar, 
	Result varchar, 
	Result_Margin int, 
	Eliminator yes_no, 
	Method varchar, 
	Umpire1 varchar,
	Umpire2 varchar
);

SET datestyle = 'European, DMY';

select * from matches limit 4;

-- 2. Create a table named ‘deliveries’ with appropriate data types for columns.

Create table deliveries (
	Id int,
	inning int, 
	over int, 
	ball int, 
	batsman varchar, 
	non_striker varchar,
	bowler varchar, 
	batsman_runs int, 
	extra_runs int, 
	total_runs int, 
	is_wicket bytea, 
	dismissal_kind varchar, 
	player_dismissed varchar, 
	fielder varchar,
	extras_type varchar, 
	batting_team varchar, 
	bowling_team varchar
);

select * from deliveries limit 4;

-- 3. Import data to the table ‘matches’
-- 4. Import data to the table ‘deliveries’.

-- 5. Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball in ascending order.

select * from deliveries 
	order by 1,2,3,4 
	limit 20;

-- 6. Select the top 20 rows of the matches table.

select * from matches 
	limit 20;

--7. Fetch data of all the matches played on 2nd May 2013 from the matches table..

select * from matches where date = '2013-05-02';

--8. Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs.

select * from matches 
	where result = 'runs' and result_margin > 100;

--9. Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date.

select * from matches where eliminator = 'Y' order by date desc;

-- 10. Get the count of cities that have hosted an IPL match.

select count(distinct city) from matches;  --33

--11. Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional column ball_result containing values boundary, dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number)

create table deliveries_v02 as 
	(select *, case 
	when total_runs >=4 then 'boundary' 
	when total_runs = 0 then 'dot'
	else 'other'
	end as ball_result
	from deliveries
	);

select total_runs, ball_result from deliveries_v02 limit 50;

-- 12. Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table.

SELECT 
    COUNT(CASE WHEN ball_result = 'boundary' THEN 1 END) AS No_of_boundaries,
    COUNT(CASE WHEN ball_result = 'dot' THEN 1 END) AS No_of_dots
FROM deliveries_v02;

-- 13. Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order of the number of boundaries scored.

SELECT distinct batting_team as team_name, count(ball_result)as Boundaries_scored
	from deliveries_v02 where ball_result = 'boundary' group by team_name order by Boundaries_scored desc;

--14. Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of the total number of dot balls bowled.

SELECT distinct bowling_team as team_name, count(ball_result)as dots_bowled
	from deliveries_v02 where ball_result = 'dot' group by team_name order by dots_bowled desc;

--15. Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA

select count(dismissal_kind) as total_no_of_dismissals from deliveries_v02 where dismissal_kind not in ('NA');

--16. Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table

select bowler, sum(extra_runs) as Runs_conceded from deliveries group by bowler order by Runs_conceded desc limit 5; 

--17. Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column (named venue and match_date) of venue and date from table matches

create table deliveries_v03 as 
	(
	select a.*, b.venue as named_venue, b.date as match_date   
	from deliveries_v02 as a join matches as b on a.id = b.id);

select * from deliveries_v03 limit 200;

-- 18. Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.

select named_venue, sum(total_runs) as total_runs from deliveries_v03 group by named_venue order by total_runs desc;

--19. Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored.

select extract(year from match_date) as Year, sum(total_runs) as total_runs
	from deliveries_v03 where named_venue = 'Eden Gardens' group by Year order by total_runs desc;

-- 20. Get unique team1 names from the matches table, you will notice that there are two entries for Rising Pune Supergiant one with Rising Pune Supergiant and another one with Rising Pune Supergiants.  
  --Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. Now analyse these newly created columns.

select * from matches_corrected where team2 = 'Rising Pune Supergiants';

create table matches_corrected as select *, team1 as team1_corr, team2 as team2_corr from matches;

update matches_corrected set team1 = 'Rising Pune Supergiant' where team1 = 'Rising Pune Supergiants';

update matches_corrected set team2 = 'Rising Pune Supergiant' where team2 = 'Rising Pune Supergiants';

-- 21. Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated by ‘-’ (For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same as deliveries_v03)

select * from deliveries_v03 limit 5;

create table deliveries_v04 as select id || '-' || inning || '-' || over || '-' || ball as ball_id, * from deliveries_v03;

--22. Compare the total count of rows and total count of distinct ball_id in deliveries_v04;

select count(ball_id) as total_count_of_rows, count (distinct ball_id) as total_count_of_distinct_ball_id from deliveries_v04;

--23. Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. 

create table deliveries_v05 as select row_number() over (partition by ball_id) as r_num, * from deliveries_v04;

select * from deliveries_v05 limit 50;

--24. Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating.

select * from deliveries_v05 WHERE r_num=2;

--25. Use subqueries to fetch data of all the ball_id which are repeating.

SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2);





