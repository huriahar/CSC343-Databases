-- scenario: one country, four elections, each with a different number of parties in the coalition
-- expected result: one row with the only party position for each century

insert into country values (0, 'c1', 'c1', '01-01-1950', 'es1', 4);

insert into election values (0, 0, '01-01-1950', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', NULL, NULL, 'Parliamentary election');
insert into election values (1, 0, '01-01-2001', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', 0, NULL, 'Parliamentary election');
insert into election values (2, 0, '01-01-2005', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', 1, NULL, 'Parliamentary election');
insert into election values (3, 0, '01-01-2009', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', 2, NULL, 'Parliamentary election');

insert into party values (0, 0, 'p1', 'p1', 'd1');
insert into party values (1, 0, 'p2', 'p2', 'd2');
insert into party values (2, 0, 'p3', 'p3', 'd3');
insert into party values (3, 0, 'p4', 'p4', 'd4');
insert into party values (4, 0, 'p5', 'p5', 'd5');
insert into party values (5, 0, 'p6', 'p6', 'd6');

insert into	election_result values (0, 0, 0, NULL, 300, 12000000, 'd1');

insert into	election_result values (10, 1, 0, NULL, 300, 12000000, 'd1');
insert into	election_result values (11, 1, 1, 10, 300, 11000000, 'd1');

insert into	election_result values (20, 2, 0, NULL, 300, 12000000, 'd1');
insert into	election_result values (21, 2, 1, 20, 300, 11000000, 'd1');
insert into	election_result values (22, 2, 2, 20, 300, 10000000, 'd1');
insert into	election_result values (23, 2, 3, 20, 300, 9000000, 'd1');

insert into	election_result values (31, 3, 0, NULL, 300, 12000000, 'd1');
insert into	election_result values (32, 3, 1, 31, 300, 11000000, 'd1');
insert into	election_result values (33, 3, 2, 31, 300, 10000000, 'd1');
insert into	election_result values (34, 3, 3, 31, 300, 9000000, 'd1');
insert into	election_result values (35, 3, 4, 31, 300, 8000000, 'd1');
insert into	election_result values (36, 3, 5, 31, 300, 7000000, 'd1');

insert into	cabinet values (0, 0, '01-01-1950', 'n1', 'wiki', 'd1', 'c1', NULL, 0);
insert into	cabinet values (1, 0, '01-01-2001', 'n2', 'wiki', 'd2', 'c2', 0, 1);
insert into	cabinet values (2, 0, '01-01-2005', 'n3', 'wiki', 'd2', 'c2', 1, 2);
insert into	cabinet values (3, 0, '01-01-2009', 'n4', 'wiki', 'd2', 'c2', 2, 3);

insert into	cabinet_party values (0, 0, 0, true, 'd1');
insert into	cabinet_party values (1, 1, 0, true, 'd1');
insert into	cabinet_party values (2, 2, 0, true, 'd1');
insert into	cabinet_party values (3, 3, 0, true, 'd1');

-- results of query
--  country | electoral_system | single_party | two_to_three | four_to_five | six_or_more 
-- ---------+------------------+--------------+--------------+--------------+-------------
--  c1      | es1              |            1 |            1 |            1 |           1