SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
electionId INT, 
countryName VARCHAR(50),
winningParty VARCHAR(100),
closeRunnerUp VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS pelection_winners CASCADE;
DROP VIEW IF EXISTS alliance_interm CASCADE;
DROP VIEW IF EXISTS alliance_interm_votes CASCADE;
DROP VIEW IF EXISTS alliance_interm_sum CASCADE;
DROP VIEW IF EXISTS pwinner_votes CASCADE;
DROP VIEW IF EXISTS all_parties CASCADE;
DROP VIEW IF EXISTS vote_pairs CASCADE;

-- Define views for your intermediate steps here.
create view pelection_winners as
    select election.country_id, election.id as election_id, cabinet.id as cabinet_id, cabinet_party.party_id
    from election join cabinet on election.id = cabinet.election_id
                  join cabinet_party on cabinet.id = cabinet_party.cabinet_id
    where cabinet_party.pm = true AND
          e_type = 'Parliamentary election';

-- Created an intermediate view where for each election id, all entries with same id are in alliance with each other
-- These are all the alliances
create view alliance_interm as
    select e1.election_id, e1.id, e1.party_id as head_party_id, e2.party_id as alliance_party_id
    from election_result e1, election_result e2
    where (e1.election_id = e2.election_id) AND
          (e1.alliance_id is null) AND
          ((e1.id = e2.id) OR
           (e2.alliance_id = e1.id));

-- Get the votes of each of the parties in the alliance
create view alliance_interm_votes as
    select a.election_id, a.id, head_party_id, alliance_party_id, votes
    from alliance_interm a, election_result e
    where a.election_id = e.election_id AND
          a.alliance_party_id = e.party_id;

-- Sum up votes of alliances
-- Sum of all alliances' votes for each election_id
create view alliance_interm_sum as
    select election_id, id, head_party_id, sum(votes) as alliance_votes
    from alliance_interm_votes
    group by election_id, id, head_party_id;

-- Get the total votes of the winning party (sum of all alliance if winning party is part of an alliance)
create view pwinner_votes as
    select country_id, pw.election_id, cabinet_id, pw.party_id, avotes.id as alliance_id, alliance_votes
    from pelection_winners pw, alliance_interm_votes avotes, alliance_interm_sum asum
    where pw.election_id = avotes.election_id AND
          avotes.election_id = asum.election_id AND
          asum.election_id = pw.election_id AND
          pw.party_id = avotes.alliance_party_id AND
          avotes.id = asum.id;

-- For each "winner", look at the max votes excluding winning party and all parties of its alliance
create view vote_pairs as
    select country_id, pw.election_id, cabinet_id, pw.party_id as win_party_id, asum.head_party_id as lose_party_id,
    pw.alliance_votes as winvotes, asum.alliance_votes as losevotes
    from pwinner_votes pw, alliance_interm_sum asum
    where pw.election_id = asum.election_id AND
          pw.alliance_id != asum.id;

create view vote_pairs_diff as
    select country_id, election_id, cabinet_id, win_party_id, lose_party_id,
    winvotes, losevotes, ((CAST(winvotes - losevotes AS FLOAT))/(CAST(winvotes AS FLOAT)))*100.0 as percentageDiff
    from vote_pairs;

-- Drop all with percentageDiff < 10
create view vote_pairs_filtered as
    select *
    from vote_pairs_diff
    where percentageDiff > 0 AND percentageDiff < 10;

create view runner_up as
    select DISTINCT country_id, election_id, win_party_id, lose_party_id, percentageDiff
    from vote_pairs_filtered v1
    where percentageDiff = 
        (select min(percentageDiff)
         from vote_pairs_filtered v2
         where v1.country_id = v2.country_id AND
               v1.election_id = v2.election_id);

create view add_win_country as
    select runner_up.election_id as electionID, country.name as countryName, party.name as winningParty, lose_party_id
    from runner_up join country on runner_up.country_id = country.id
                   join party on runner_up.win_party_id = party.id;

create view result as
    select electionID, countryName, winningParty, party.name as closeRunnerUp
    from add_win_country join party on add_win_country.lose_party_id = party.id;

-- the answer to the query 
insert into q5 
    select * from result;
