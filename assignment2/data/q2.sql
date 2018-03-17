SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
country VARCHAR(50),
electoral_system VARCHAR(100),
single_party INT,
two_to_three INT,
four_to_five INT,
six_or_more INT
);

TRUNCATE q2;

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS pelection_winners CASCADE;
DROP VIEW IF EXISTS alliance_interm CASCADE;
DROP VIEW IF EXISTS alliance_counts CASCADE;
DROP VIEW IF EXISTS alliances CASCADE;
DROP VIEW IF EXISTS pwinner_alliances CASCADE;
DROP VIEW IF EXISTS all_countries CASCADE;
DROP VIEW IF EXISTS single_party_alliances CASCADE;
DROP VIEW IF EXISTS two_to_three_party_alliances CASCADE;
DROP VIEW IF EXISTS four_to_five_party_alliances CASCADE;
DROP VIEW IF EXISTS six_or_more_party_alliances CASCADE;
DROP VIEW IF EXISTS joined_alliance_counts CASCADE;

-- Define views for your intermediate steps here.
create view pelection_winners as
    select election.country_id, election.id as election_id, cabinet.id as cabinet_id, cabinet_party.party_id
    from election join cabinet on election.id = cabinet.election_id
                  join cabinet_party on cabinet.id = cabinet_party.cabinet_id
    where cabinet_party.pm = true AND
          e_type = 'Parliamentary election';

-- Created an intermediate view where for each election id, all entries with same id are in alliance with each other
create view alliance_interm as
    select e1.election_id, e1.id, e1.party_id as head_party_id, e2.party_id
    from election_result e1, election_result e2
    where (e1.election_id = e2.election_id) AND
          (e1.alliance_id is null) AND
          ((e1.id = e2.id) OR
           (e2.alliance_id = e1.id));

create view alliance_counts as
    select election_id, id, count(*)
    from alliance_interm
    group by election_id, id;

create view alliances as
    select alliance_interm.election_id, alliance_interm.id, party_id, count
    from alliance_interm, alliance_counts
    where alliance_interm.election_id = alliance_counts.election_id AND
          alliance_interm.id = alliance_counts.id;

-- Look at alliance counts of only those parties which are in pelection_winners
create view pwinner_alliances as
    select country_id, pelection_winners.election_id, cabinet_id, pelection_winners.party_id, count
    from pelection_winners, alliances
    where pelection_winners.election_id = alliances.election_id AND
          pelection_winners.party_id = alliances.party_id;

create view all_countries as
    select country_id, name as country, electoral_system
    from pwinner_alliances join country on pwinner_alliances.country_id = country.id
    group by country_id, name, electoral_system;

create view single_party_alliances as
    select country_id, count(*) as single_party
    from pwinner_alliances
    where count = 1
    group by country_id;

create view two_to_three_party_alliances as
    select country_id, count(*) as two_to_three
    from pwinner_alliances
    where count = 2 OR
          count = 3
    group by country_id;

create view four_to_five_party_alliances as
    select country_id, count(*) as four_to_five
    from pwinner_alliances
    where count = 4 OR
          count = 5
    group by country_id;

create view six_or_more_party_alliances as
    select country_id, count(*) as six_or_more
    from pwinner_alliances
    where count >= 6
    group by country_id;

create view joined_alliance_counts as
    select all_countries.country_id, country, electoral_system,
    case when single_party is null then 0 else single_party end as single_party,
    case when two_to_three is null then 0 else two_to_three end as two_to_three,
    case when four_to_five is null then 0 else four_to_five end as four_to_five,
    case when six_or_more is null then 0 else six_or_more end as six_or_more
    -- case when six_or_more is null then 0 else six_or_more end
    from all_countries left join single_party_alliances on all_countries.country_id = single_party_alliances.country_id
                       left join two_to_three_party_alliances on single_party_alliances.country_id = two_to_three_party_alliances.country_id
                       left join four_to_five_party_alliances on two_to_three_party_alliances.country_id = four_to_five_party_alliances.country_id
                       left join six_or_more_party_alliances on four_to_five_party_alliances.country_id = six_or_more_party_alliances.country_id;


-- the answer to the query 
insert into q2 
    select country, electoral_system, single_party, two_to_three, four_to_five, six_or_more
    from joined_alliance_counts;