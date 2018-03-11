-- scenario: one country with one parliamentary election per century and no coalitions
-- expected result: one row with the only party position for each century

TRUNCATE country, election, party, party_position, election_result, cabinet, cabinet_party CASCADE;

insert into country values (0, 'c1', 'c1', '01-01-1950', 'es1', 4);

insert into election values (0, 0, '01-01-1950', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', NULL, NULL, 'Parliamentary election');
insert into election values (1, 0, '01-01-2001', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', 0, NULL, 'Parliamentary election');

insert into party values (0, 0, 'p1', 'p1', 'd1');
insert into party values (1, 0, 'p2', 'p2', 'd2');
insert into party values (2, 0, 'p3', 'p3', 'd3');
insert into party_position values (0, 5, 5, 5);
insert into party_position values (1, 7, 7, 7);
insert into party_position values (2, 10, 10, 10);

insert into	election_result values (0, 0, 0, NULL, 300, 12000000, 'd1');
--insert into	election_result values (1, 1, 0, NULL, 300, 12000000, 'd1');
insert into	election_result values (1, 0, 1, 0, 300, 12000000, 'd1');
insert into	election_result values (2, 0, 2, NULL, 300, 12000000, 'd1');
insert into	election_result values (3, 1, 1, NULL, 300, 12000000, 'd1');

insert into	cabinet values (0, 0, '01-01-1950', 'n1', 'wiki', 'd1', 'c1', NULL, 0);
insert into	cabinet values (1, 0, '01-01-1960', 'n2', 'wiki', 'd2', 'c2', 0, 0);
insert into	cabinet values (2, 0, '01-01-2001', 'n3', 'wiki', 'd3', 'c3', 1, 1);
-- insert into	cabinet values (1, 0, '01-01-2001', 'n2', 'wiki', 'd2', 'c2', 0, 1);

insert into	cabinet_party values (0, 0, 0, true, 'd1');
--insert into	cabinet_party values (1, 1, 0, true, 'd1');
insert into	cabinet_party values (1, 0, 1, false, 'd1');
insert into	cabinet_party values (2, 1, 2, true, 'd1');
insert into	cabinet_party values (3, 2, 1, true, 'd1');

-- results of query
--  century | country | left_right | state_market | liberty_authority 
-- ---------+---------+------------+--------------+-------------------
--  20      | c1      |          5 |            5 |                 5
--  21      | c1      |          5 |            5 |                 5