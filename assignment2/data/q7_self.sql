-- Scenario: 1 EP election, 1 Parliamentary election before it. 1 party
-- expected result: 1 row

insert into country values (0, 'c1', 'c1', '01-01-1950', 'es1', 4);

insert into election values (0, 0, '01-01-2001', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', NULL, NULL, 'Parliamentary election');
insert into election values (1, 0, '01-01-2002', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', NULL, NULL, 'European Parliament');

insert into party values (0, 0, 'p1', 'p1', 'd1');

insert into party_family values (0, 'Nationalist');

insert into election_result values (0, 0, 0, NULL, 300, 10000000, 'd1');

insert into cabinet values (0, 0, '01-01-1950', 'n1', 'wiki', 'd1', 'c1', NULL, 0);

insert into cabinet_party values (0, 0, 0, true, 'd1');

-- results of query
--  partyid | partyfamily 
-- ---------+-------------
--        0 | Nationalist