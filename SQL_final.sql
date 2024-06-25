SELECT * FROM rpc11.2014_result where pc_name="Aurangabad";
SELECT * FROM rpc11.2019_result;
-- Implementing changes --
SET SQL_SAFE_UPDATES = 0;
UPDATE 2014_result
SET state = "Telangana" 
where state="Andhra Pradesh";

UPDATE 2014_result
SET pc_name = "Guwahati" 
where pc_name="Gauhati";
UPDATE 2019_result
SET pc_name = "Guwahati" 
where pc_name="Gauhati";



-- Q:1 ; List top 5 / bottom 5 constituencies of 2014 and 2019 in terms of voter turnout ratio?  
-- top 5 2014
select pc_name,state, round((sum(total_votes)/max(total_electors))*100,2) as voter_turnout_ratio
	from 2014_result 
	group by pc_name,state
    order by voter_turnout_ratio
    desc limit 5;
-- top 5 2019 
select pc_name,state, round((sum(total_votes)/max(total_electors))*100,2) as voter_turnout_ratio
	from 2019_result 
	group by pc_name,state
    order by voter_turnout_ratio
    desc limit 5;
-- bottom 5 2014
select pc_name,state, round((sum(total_votes)/max(total_electors))*100,2) as voter_turnout_ratio
	from 2014_result 
	group by pc_name,state
    order by voter_turnout_ratio
    asc limit 5;
-- bottom 5 2019
select pc_name,state, round((sum(total_votes)/max(total_electors))*100,2) as voter_turnout_ratio
	from 2019_result 
	group by pc_name,state
    order by voter_turnout_ratio
    asc limit 5;
    
-- Q:2 List top 5 / bottom 5 states of 2014 and 2019 in terms of voter turnout ratio?
-- top 5 2014
select state, 
	round((sum(total_votes))/sum(total_available_votes)*100,2) as voter_turnout_ratio
    from (select state,pc_name,sum(total_votes) as total_votes,
				max(total_electors) as total_available_votes 
			from 2014_result 
			group by state,pc_name) as subquery
group by state
order by voter_turnout_ratio desc
limit 5;

-- top 5 2019
select state, 
	round((sum(total_votes))/sum(total_available_votes)*100,2) as voter_turnout_ratio
    from (select state,pc_name,sum(total_votes) as total_votes,
				max(total_electors) as total_available_votes 
			from 2019_result 
			group by state,pc_name) as subquery
group by state
order by voter_turnout_ratio desc
limit 5;

-- Bottom  5 2014
select state, 
	round((sum(total_votes))/sum(total_available_votes)*100,2) as voter_turnout_ratio
    from (select state,pc_name,sum(total_votes) as total_votes,
				max(total_electors) as total_available_votes 
			from 2014_result 
			group by state,pc_name) as subquery
group by state
order by voter_turnout_ratio 
limit 5;

-- Bottom  5 2019
select state, 
	round((sum(total_votes))/sum(total_available_votes)*100,2) as voter_turnout_ratio
    from (select state,pc_name,sum(total_votes) as total_votes,
				max(total_electors) as total_available_votes 
			from 2019_result 
			group by state,pc_name) as subquery
group by state
order by voter_turnout_ratio 
limit 5;

-- Q3: Which constituencies have elected the same party for two consecutive elections,
-- rank them by % of votes to that winning party in 2019.
with cte1 as (
(
    SELECT *
    FROM 2014_result AS ind
    WHERE party = 'IND'
    AND (state, pc_name, total_votes) IN (
        SELECT state, pc_name, MAX(total_votes)
        FROM 2014_result
        WHERE party = 'IND'
        GROUP BY state, pc_name
    )
)
UNION ALL
(
    SELECT *
    FROM 2014_result AS others
    WHERE party != 'IND'
)),
cte2 as 
((
    SELECT *
    FROM 2019_result AS ind
    WHERE party = 'IND'
    AND (state, pc_name, total_votes) IN (
        SELECT state, pc_name, MAX(total_votes)
        FROM 2019_result
        WHERE party = 'IND'
        GROUP BY state, pc_name
    )
)
UNION ALL
(
    SELECT *
    FROM 2019_result AS others
    WHERE party != 'IND'
))

select b.state,c.pc_name,b.party as 2014_winner,c.party as 2019_winner,
round((c.total_votes/c.total_electors)*100,2) as votes_2019_winner_ratio
from cte1 b 
join cte2 c 
on c.pc_name=b.pc_name and c.state=b.state
where 
b.party = (
        SELECT party
        FROM cte1
        WHERE state = b.state AND pc_name = b.pc_name
        ORDER BY total_votes DESC
        LIMIT 1) and 
b.party=c.party 
 AND c.party = (
        SELECT party
        FROM cte2
        WHERE state = c.state AND pc_name = c.pc_name
        ORDER BY total_votes DESC
        LIMIT 1)
order by votes_2019_winner_ratio desc;

-- Q4 -- 4.	Which constituencies have voted for different parties in two elections 
-- (list top 10 based on difference (201 9-2014) in winner vote percentage in two elections)

with cte1 as (
(
    SELECT *
    FROM 2014_result AS ind
    WHERE party = 'IND'
    AND (state, pc_name, total_votes) IN (
        SELECT state, pc_name, MAX(total_votes)
        FROM 2014_result
        WHERE party = 'IND'
        GROUP BY state, pc_name
    )
)
UNION ALL
(
    SELECT *
    FROM 2014_result AS others
    WHERE party != 'IND'
)),
cte2 as 
((
    SELECT *
    FROM 2019_result AS ind
    WHERE party = 'IND'
    AND (state, pc_name, total_votes) IN (
        SELECT state, pc_name, MAX(total_votes)
        FROM 2019_result
        WHERE party = 'IND'
        GROUP BY state, pc_name
    )
)
UNION ALL
(
    SELECT *
    FROM 2019_result AS others
    WHERE party != 'IND'
))
select b.state,c.pc_name,b.party as 2014_winner,c.party as 2019_winner,
round((b.total_votes/b.total_electors)*100,2) as 2014_ratio,
round((c.total_votes/c.total_electors)*100,2) as 2019_ratio,
abs(round((b.total_votes/b.total_electors)*100,2)-
round((c.total_votes/c.total_electors)*100,2) )as diff
from cte1 b 
join cte2 c 
on c.pc_name=b.pc_name and c.state=b.state
where 
b.party = (
        SELECT party
        FROM cte1
        WHERE state = b.state AND pc_name = b.pc_name
        ORDER BY total_votes DESC
        LIMIT 1) and 
b.party!=c.party 
 AND c.party = (
        SELECT party
        FROM cte2
        WHERE state = c.state AND pc_name = c.pc_name
        ORDER BY total_votes DESC
        LIMIT 1)
order by diff desc limit 10;

-- Q5 Top 5 candidates based on 
-- margin difference with runners in 2014 and 2019.
-- part1 top 5 2014 
with cte3 as (
select *,
row_number() over(partition by pc_name order by total_votes desc) as rnk
from 2014_result ),
cte4 as(
select state,pc_name,
max(Case when rnk=1 then total_votes end) as top1,
max(Case when rnk=2 then total_votes end) as top2
from cte3
where rnk<=2
group by state,pc_name)

select state,pc_name,
(select candidate from cte3 where pc_name=cte4.pc_name and rnk=1) as winner,
(select party from cte3 where pc_name=cte4.pc_name and rnk=1) as winning_party,
(select candidate from cte3 where pc_name=cte4.pc_name and rnk=2) as runner_up,
(select party from cte3 where pc_name=cte4.pc_name and rnk=2) as runner_up_party,
abs(top1-top2) as diff,top1,top2
from cte4 order by diff desc limit 5;

-- part1 top 5 2019
with cte5 as (
select *,
row_number() over(partition by pc_name order by total_votes desc) as rnk
from 2019_result ),
cte6 as(
select state,pc_name,
max(Case when rnk=1 then total_votes end) as top1,
max(Case when rnk=2 then total_votes end) as top2
from cte5
where rnk<=2
group by state,pc_name)

select state,pc_name,
(select candidate from cte5 where pc_name=cte6.pc_name and rnk=1) as winner,
(select party from cte5 where pc_name=cte6.pc_name and rnk=1) as winning_party,
(select candidate from cte5 where pc_name=cte6.pc_name and rnk=2) as runner_up,
(select party from cte5 where pc_name=cte6.pc_name and rnk=2) as runner_up_party,
abs(top1-top2) as diff,top1,top2
from cte6 order by diff desc limit 5;

-- Q6 6.% Split of votes of parties between 2014 vs 2019 at national level
-- part1 2014
select party,round((tv/(select sum(total_votes) from 2014_result))*100,2) as voting_share from 
(
select party,sum(total_votes) as tv from 2014_result group by party) cte
order by voting_share desc;

-- part2 2019
select party,round((tv/(select sum(total_votes) from 2019_result))*100,2) as voting_share from 
(
select party,sum(total_votes) as tv from 2019_result group by party) cte
order by voting_share desc;

-- Q7 7.	% Split of votes of parties between 2014 vs 2019 at state level.
-- 2014 
SELECT 
    2014_result.state,
    2014_result.party,
    ROUND(SUM(total_votes) / state_total_votes * 100, 2) AS voting_share_percentage
FROM 
    2014_result 
JOIN (
    SELECT 
        state,
        SUM(total_votes) AS state_total_votes
    FROM 
        2014_result
    GROUP BY 
        state
) AS state_votes ON 2014_result.state = state_votes.state
GROUP BY 
    state, party;
-- 2019 
SELECT 
    2019_result.state,
    2019_result.party,
    ROUND(SUM(total_votes) / state_total_votes * 100, 2) AS voting_share_percentage
FROM 
    2019_result 
JOIN (
    SELECT 
        state,
        SUM(total_votes) AS state_total_votes
    FROM 
        2019_result
    GROUP BY 
        state
) AS state_votes ON 2019_result.state = state_votes.state
GROUP BY 
    state, party;
    
-- Q8 : 8.	List top 5 constituencies for 
-- two major national parties where they have gained vote share in 2019 as compared to 2014.
-- finding top two parties 
select party,sum(total_votes) as total from 2014_result group by party order by total desc limit 2;
-- for BJP 
with cte as (
Select b.pc_name,b.total_votes as BJP_2014,c.total_votes as BJP_2019 from 2014_result b
join 2019_result c on b.pc_name=c.pc_name and b.total_votes<c.total_votes 
where b.party="BJP" and c.party="BJP")
select pc_name,BJP_2014,BJP_2019,round(((BJP_2019-BJP_2014)/(BJP_2014))*100,2) as votes_gain 
from cte order by votes_gain desc limit 5;

-- for INC 
with cte as (
Select b.pc_name,b.total_votes as INC_2014,c.total_votes as INC_2019 from 2014_result b
join 2019_result c on b.pc_name=c.pc_name and b.total_votes<c.total_votes 
where b.party="INC" and c.party="INC")
select pc_name,INC_2014,INC_2019,round(((INC_2019-INC_2014)/(INC_2014))*100,2) as votes_gain 
from cte order by votes_gain desc limit 5;

-- 9.List top 5 constituencies for two major national 
-- parties where they have lost vote share in 2019 as compared to 2014.
-- for BJP 
with cte as (
Select b.pc_name,b.total_votes as BJP_2014,c.total_votes as BJP_2019 from 2014_result b
join 2019_result c on b.pc_name=c.pc_name and b.total_votes>c.total_votes 
where b.party="BJP" and c.party="BJP")
select pc_name,BJP_2014,BJP_2019,round(((BJP_2014-BJP_2019)/(BJP_2014))*100,2) as votes_gain 
from cte order by votes_gain desc limit 5;

-- INC 
with cte as (
Select b.pc_name,b.total_votes as INC_2014,c.total_votes as INC_2019 from 2014_result b
join 2019_result c on b.pc_name=c.pc_name and b.total_votes>c.total_votes 
where b.party="INC" and c.party="INC")
select pc_name,INC_2014,INC_2019,round(((INC_2014-INC_2019)/(INC_2014))*100,2) as votes_gain 
from cte order by votes_gain desc limit 5;

-- Q10 10.	Which constituency has voted the most for NOTA?
-- 2014 
Select pc_name, total_votes from 2014_result where party="NOTA" order by total_votes desc limit 1; 
-- 2019 
Select pc_name, total_votes from 2019_result where party="NOTA" order by total_votes desc limit 1; 


-- Q11: 10.	Which constituency has voted the most for NOTA?Which constituencies have elected candidates whose 
-- party has less than 10% vote share at state level in 2019?

with cte_1 as (
SELECT 
    2019_result.state,
    2019_result.party,
    ROUND(SUM(total_votes) / state_total_votes * 100, 2) AS voting_share_percentage
FROM 
    2019_result 
JOIN (
    SELECT 
        state,
        SUM(total_votes) AS state_total_votes
    FROM 
        2019_result
    GROUP BY 
        state
) AS state_votes ON 2019_result.state = state_votes.state
GROUP BY 
    state, party
having voting_share_percentage <10),
cte_2 as (
SELECT 
    state,
    pc_name,
    party,
    total_votes
FROM 
    (
        SELECT 
            state,
            pc_name,
            party,
            total_votes,
            ROW_NUMBER() OVER (PARTITION BY pc_name ORDER BY total_votes DESC) AS rnk
        FROM 
            2019_result
    ) AS subquery
WHERE 
    rnk = 1)
select c.pc_name from cte_1 b join cte_2 c on b.state=c.state and b.party=c.party ;

-- EXTRA 
-- Q1 Is there a correlation between postal votes % and voter turnout %?
with cte as (select state,sum(distinct total_electors) as electors,sum(postal_votes) as post 
from 2014_result group by state)
select state,round((post/electors)*100,2) as postal_percentage,post 
from cte order by post desc, postal_percentage desc ;

