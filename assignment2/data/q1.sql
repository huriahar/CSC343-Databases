SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
century VARCHAR(2),
country VARCHAR(50), 
left_right REAL, 
state_market REAL, 
liberty_authority REAL
);

TRUNCATE q1;

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS election_winners CASCADE;
DROP VIEW IF EXISTS pelections2021 CASCADE;
DROP VIEW IF EXISTS pelection_winners2021 CASCADE;
DROP VIEW IF EXISTS alliance_interm CASCADE;
DROP VIEW IF EXISTS alliance_interm_positions CASCADE;
DROP VIEW IF EXISTS alliance_interm_avg CASCADE;
DROP VIEW IF EXISTS winning_alliance_positions CASCADE;
DROP VIEW IF EXISTS add_country_name CASCADE;
DROP VIEW IF EXISTS result CASCADE;


-- Define views for your intermediate steps here.
-- Get all election_winners
create view election_winners as
    select election.id as election_id, cabinet.id as cabinet_id, cabinet_party.party_id
    from election join cabinet on election.id = cabinet.election_id
                  join cabinet_party on cabinet.id = cabinet_party.cabinet_id
    where cabinet_party.pm = true;

-- Election ID, century and country ID of all parliamentary elections held in 20th/21st century
create view pelections2021 as
    select id, extract(CENTURY from election.e_date) as century, country_id
    from election
    where (e_type = 'Parliamentary election') AND
          ((select extract(CENTURY from election.e_date) = 20) OR
           (select extract(CENTURY from election.e_date) = 21));

-- Join the above two views
create view pelection_winners2021 as
    select century, country_id, election_id, cabinet_id, party_id
    from election_winners join pelections2021 on election_winners.election_id = pelections2021.id;

-- Created an intermediate view where for each election id, all entries with same id are in alliance with each other
-- These are all the alliances
create view alliance_interm as
    select e1.election_id, e1.id, e2.party_id
    from election_result e1, election_result e2
    where (e1.election_id = e2.election_id) AND
          (e1.alliance_id is null) AND
          ((e1.id = e2.id) OR
           (e2.alliance_id = e1.id));

-- Get the positions of each of the parties in the alliance
create view alliance_interm_positions as
    select election_id, id, alliance_interm.party_id, left_right, state_market, liberty_authority
    from alliance_interm join party_position on alliance_interm.party_id = party_position.party_id;

-- Get the avg for each alliance
create view alliance_interm_avg as
    select election_id, id, avg(left_right) as lr, avg(state_market) as sm, avg(liberty_authority) as la
    from alliance_interm_positions
    group by election_id, id;

create view winning_alliance_positions as
    select pw.election_id, pw.cabinet_id, lr, sm, la
    from pelection_winners2021 pw, alliance_interm_avg aavg, alliance_interm_positions apos
    where pw.election_id = aavg.election_id AND
          aavg.election_id = apos.election_id AND
          apos.election_id = pw.election_id AND
          pw.party_id = apos.party_id AND
          apos.id = aavg.id;

create view pelection_winner_avg as
    select century, country_id, pw.election_id, pw.cabinet_id, lr, sm, la
    from pelection_winners2021 pw, winning_alliance_positions wap
    where pw.election_id = wap.election_id AND
          pw.cabinet_id = wap.cabinet_id;

create view add_country_name as
    select century, pelection_winner_avg.country_id, name as country, election_id, cabinet_id, lr, sm, la
    from pelection_winner_avg join country on pelection_winner_avg.country_id = country.id;

create view result as
    select century, country, avg(lr) as left_right, avg(sm) as state_market, avg(la) as liberty_authority
    from add_country_name
    group by century, country;

-- the answer to the query 
insert into q1 
    select *
    from result;