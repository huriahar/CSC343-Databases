-- scenario: one country, two elections, each won by the same party and prime minister
-- expected result: two elections, sequential party wins, one prime minister that served twice

insert into country values (0, 'c1', 'c1', '01-01-1950', 'es1', 4);

insert into election values (0, 0, '01-01-1950', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', NULL, NULL, 'Parliamentary election');
insert into election values (1, 0, '01-01-2001', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', 0, NULL, 'Parliamentary election');

insert into party values (0, 0, 'p1', 'p1', 'd1');

insert into	election_result values (0, 0, 0, NULL, 300, 12000000, 'd1');
insert into	election_result values (1, 1, 0, NULL, 300, 12000000, 'd1');

insert into cabinet values (0, 0, '01-01-1950', 'John Smith', 'wiki', 'd1', 'c1', NULL, 0);
insert into cabinet values (1, 0, '01-01-2001', 'John Smith II', 'wiki', 'd1', 'c1', 0, 1);

insert into cabinet_party values (0, 0, 0, TRUE, 'd1');
insert into cabinet_party values (1, 1, 0, TRUE, 'd1');

-- results of query
--  country | num_elections | num_repeat_party | num_repeat_pm 
-- ---------+---------------+------------------+---------------
--  c1      |             2 |                1 |             1