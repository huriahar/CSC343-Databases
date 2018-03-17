SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
partyId INT, 
partyFamily VARCHAR(50) 
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS pelection_winners CASCADE;
DROP VIEW IF EXISTS alliance_interm CASCADE;
DROP VIEW IF EXISTS winning_party_id CASCADE;
DROP VIEW IF EXISTS winning_party_alliances CASCADE;
DROP VIEW IF EXISTS election_win_party CASCADE;
DROP VIEW IF EXISTS eu_elections CASCADE;
DROP VIEW IF EXISTS eu_election_pairs CASCADE;
DROP VIEW IF EXISTS parties_before_first_ep CASCADE;
DROP VIEW IF EXISTS valid_parties CASCADE;
DROP VIEW IF EXISTS unique_date_range_counts CASCADE;
DROP VIEW IF EXISTS party_count CASCADE;
DROP VIEW IF EXISTS party_count_filtered CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.
create view pelection_winners as
    select election.country_id, election.id as election_id, cabinet.id as cabinet_id, cabinet_party.party_id
    from election join cabinet on election.id = cabinet.election_id
                  join cabinet_party on cabinet.id = cabinet_party.cabinet_id
    where cabinet_party.pm = true AND
          e_type = 'Parliamentary election';

create view alliance_interm as
    select e1.election_id, e1.id, e1.party_id as head_party_id, e2.party_id as alliance_party_id
    from election_result e1, election_result e2
    where (e1.election_id = e2.election_id) AND
          (e1.alliance_id is null) AND
          ((e1.id = e2.id) OR
           (e2.alliance_id = e1.id));

create view winning_party_id as
    select country_id, pw.election_id, cabinet_id, pw.party_id, id
    from pelection_winners pw, alliance_interm ai
    where pw.election_id = ai.election_id AND
          pw.party_id = ai.alliance_party_id;

create view winning_party_alliances as
    select country_id, wpi.election_id, cabinet_id, wpi.id, wpi.party_id as win_party_id, alliance_party_id
    from winning_party_id wpi, alliance_interm ai
    where wpi.election_id = ai.election_id AND
          wpi.id = ai.id;

-- All of the below parties have won presidential elections on the given e_date
-- (either independently or as part of an alliance)
create view election_win_party as
    select DISTINCT e_date, alliance_party_id as party_id
    from winning_party_alliances wpa, election e
    where wpa.election_id = e.id;

create view eu_elections as
    select e_date, id, previous_ep_election_id
    from election
    where e_type = 'European Parliament';

create view eu_election_pairs as
    select DISTINCT e1.e_date as e1_edate, e2.e_date as e2_edate
    from eu_elections e1, eu_elections e2
    where e1.previous_ep_election_id = e2.id OR
         (e1.previous_ep_election_id is null AND e2.previous_ep_election_id is null);

-- All the prties which have won elections before first EU date
create view parties_before_first_ep as
    select DISTINCT party_id
    from election_win_party ewp
    where e_date < 
           (select e1_edate
            from eu_election_pairs
            where e1_edate = e2_edate);

-- All parties whihc fall under given ranges
create view valid_parties as
    select e1_edate, e2_edate, party_id
    from election_win_party ewp, eu_election_pairs euep
    where e1_edate != e2_edate AND
          ewp.e_date >= euep.e2_edate AND
          ewp.e_date < euep.e1_edate
    group by e1_edate, e2_edate, party_id;

create view unique_date_range_counts as
    select e1_edate, e2_edate
    from valid_parties
    group by e1_edate, e2_edate;

create view party_count as
    select party_id, count(*)
    from valid_parties
    group by party_id;

create view party_count_filtered as
    select party_id
    from party_count
    where count = 
          (select count(*)
           from unique_date_range_counts);

create view result as
    select parties_before_first_ep.party_id
    from parties_before_first_ep left join party_count_filtered on parties_before_first_ep.party_id = party_count_filtered.party_id
    where case when (select count(*) from party_count_filtered) > 0 then party_count_filtered.party_id is not null else party_count_filtered.party_id is null end;

-- Find all common parties in all of the ranges
-- Find those parties whi ch exist in parties_before_first_ep and in common parties in step above

-- the answer to the query 
insert into q7 
    select party_family.party_id as partyID, family as partyFamily
    from result join party_family on result.party_id = party_family.party_id;
