SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
country VARCHAR(50), 
num_dissolutions INT,
most_recent_dissolution DATE, 
num_on_cycle INT,
most_recent_on_cycle DATE
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS election_country_dates CASCADE;
DROP VIEW IF EXISTS election_pairs CASCADE;
DROP VIEW IF EXISTS election_years_diff CASCADE;
DROP VIEW IF EXISTS off_cycle_elections CASCADE;
DROP VIEW IF EXISTS on_cycle_elections CASCADE;
DROP VIEW IF EXISTS dissolutions CASCADE;

-- Define views for your intermediate steps here.
create view election_country_dates as
    select election.country_id, election_cycle, election.id as election_id, e_date, previous_parliament_election_id
    from election join country on election.country_id = country.id
    where e_type = 'Parliamentary election';

create view election_pairs as
    select e1.country_id, e1.election_cycle, e1.e_date as e1date, e2.e_date as e2date, e1.election_id as e1electionid, e2.election_id as e2electionid
    from election_country_dates e1, election_country_dates e2
    where e1.country_id = e2.country_id AND
          ((e1.previous_parliament_election_id = e2.election_id) OR
           ((e1.previous_parliament_election_id is null) AND
            (e2.previous_parliament_election_id is null)));

create view election_years_diff as
    select country_id, election_cycle, e1date, e2date, e1electionid, e2electionid, date_part('year', e1date::date) - date_part('year', e2date::date) as yeardiff
    from election_pairs;

-- Count the number of off-cycle elections
create view off_cycle_elections as
    select country_id, count(*) as num_dissolutions, max(e1date) as most_recent_dissolution
    from election_years_diff
    where (yeardiff != election_cycle) AND
          (e1electionid != e2electionid)
    group by country_id;

create view on_cycle_elections as
    select country_id, count(*) as num_on_cycle, max(e1date) as most_recent_on_cycle
    from election_years_diff
    where (yeardiff = election_cycle) OR
          (e1electionid = e2electionid)
    group by country_id;

create view dissolutions as
    select off_cycle_elections.country_id, 
    case when num_dissolutions is null then 0 else num_dissolutions end as num_dissolutions, most_recent_dissolution,
    case when num_on_cycle is null then 0 else num_on_cycle end as num_on_cycle, most_recent_on_cycle
    from off_cycle_elections full join on_cycle_elections on off_cycle_elections.country_id = on_cycle_elections.country_id;

create view add_country_name as
    select country_id, name as country, num_dissolutions, most_recent_dissolution, num_on_cycle, most_recent_on_cycle
    from dissolutions join country on dissolutions.country_id = country.id;


-- the answer to the query 
insert into q3 
    select country, num_dissolutions, most_recent_dissolution, num_on_cycle, most_recent_on_cycle
    from add_country_name;