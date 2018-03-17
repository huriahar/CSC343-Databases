SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
country VARCHAR(50),
num_elections INT,
num_repeat_party INT,
num_repeat_pm INT
);

TRUNCATE q4;

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS pelection_number CASCADE;
DROP VIEW IF EXISTS pelection_winners CASCADE;
DROP VIEW IF EXISTS pelection_winners_distinct CASCADE;
DROP VIEW IF EXISTS pelection_pm CASCADE;
DROP VIEW IF EXISTS pm_count CASCADE;
DROP VIEW IF EXISTS repeat_pm CASCADE;
DROP VIEW IF EXISTS pelection_winners_pairs CASCADE;
DROP VIEW IF EXISTS incumbent_pairs CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.

create view pelection_number as
    select country_id, name as country, count(*) as num_elections
    from election join country on election.country_id = country.id
    where e_type = 'Parliamentary election'
    group by country_id, name;

create view pelection_winners as
    select election.country_id, election.id as election_id, e_date, cabinet.id as cabinet_id, cabinet_party.party_id, previous_parliament_election_id
    from election join cabinet on election.id = cabinet.election_id
                  join cabinet_party on cabinet.id = cabinet_party.cabinet_id
    where cabinet_party.pm = true AND
          e_type = 'Parliamentary election';

create view pelection_winners_distinct as
    select DISTINCT country_id, e_date, election_id, party_id, previous_parliament_election_id
    from pelection_winners;

create view pelection_pm as
    select p.country_id, e_date, p.election_id, p.cabinet_id, party_id, c.name as orig_name,
           regexp_replace(c.name::text, '([A-Za-z]*?)[ IV]+$', '\1') as name
    from pelection_winners p, cabinet c
    where p.country_id = c.country_id AND
          p.cabinet_id = c.id AND
          p.election_id = c.election_id;

create view pm_count as
    select country_id, name, count(*) - 1 as pm_repeat_times
    from pelection_pm
    group by country_id, name;

create view repeat_pm as
    select country_id, count(*) as num_repeat_pm
    from pm_count
    where pm_repeat_times > 0
    group by country_id;

create view pelection_winners_pairs as
    select p1.country_id, p1.e_date as p1edate, p2.e_date as p2edate, 
           p1.election_id as p1election_id, p2.election_id as p2election_id, p1.party_id as p1partyid, p2.party_id as p2party_id
    from pelection_winners_distinct p1, pelection_winners_distinct p2
    where p1.country_id = p2.country_id AND
          (p1.previous_parliament_election_id = p2.election_id);

create view incumbent_pairs as
    select country_id, count(*) as num_repeat_party
    from pelection_winners_pairs
    where p1partyid = p2party_id
    group by country_id;

create view result as
    select pelection_number.country_id, country, num_elections, num_repeat_party, num_repeat_pm
    from pelection_number join incumbent_pairs on pelection_number.country_id = incumbent_pairs.country_id
                          join repeat_pm on incumbent_pairs.country_id = repeat_pm.country_id;

-- the answer to the query 
INSERT INTO q4
    select country, num_elections, num_repeat_party, num_repeat_pm
    from result;

