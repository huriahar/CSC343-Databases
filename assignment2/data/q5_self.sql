-- Scenario: 1 parliamentary election, 2 parties with vote diff < 10 %. 
-- expected result: one rows with 

TRUNCATE country, election, party, election_result, cabinet, cabinet_party CASCADE;

insert into country values (0, 'c1', 'c1', '01-01-1950', 'es1', 4);

insert into election values (0, 0, '01-01-1950', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', NULL, NULL, 'Parliamentary election');
insert into election values (1, 0, '01-01-1970', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', 0, NULL, 'Parliamentary election');

insert into party values (0, 0, 'p1', 'p1', 'd1');
insert into party values (1, 0, 'p2', 'p2', 'd2');
insert into party values (2, 0, 'p3', 'p3', 'd2');
insert into party values (3, 0, 'p4', 'p4', 'd2');

insert into election_result values (0, 0, 0, NULL, 300, 70, 'd1');
insert into election_result values (1, 0, 1, 0, 300, 30, 'd1');
insert into election_result values (2, 0, 2, NULL, 300, 95, 'd1');
insert into election_result values (3, 0, 3, NULl, 300, 90, 'd1');
insert into election_result values (4, 1, 0, NULL, 500, 500, 'd1');
insert into election_result values (5, 1, 1, NULL, 400, 400, 'd1');
insert into election_result values (6, 1, 2, 5, 80, 80, 'd1');
insert into election_result values (7, 1, 3, NULL, 470, 470, 'd1');

insert into cabinet values (0, 0, '01-01-1950', 'n1', 'wiki', 'd1', 'c1', NULL, 0);
insert into cabinet values (1, 0, '01-01-1960', 'n2', 'wiki', 'd1', 'c1', 0, 0);
insert into cabinet values (2, 0, '01-01-1970', 'n3', 'wiki', 'd1', 'c1', 1, 1);

insert into cabinet_party values (0, 0, 0, true, 'd1');
insert into cabinet_party values (1, 0, 1, false, 'd1');
insert into cabinet_party values (2, 1, 2, true, 'd1');
insert into cabinet_party values (3, 2, 0, true, 'd1');

-- results of query
--  electionid | countryname | winningparty | closerunnerup 
-- ------------+-------------+--------------+---------------
--           0 | c1          | p1           | p3
--           1 | c1          | p1           | p2
