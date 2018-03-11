-- scenario: one country, two elections, not election_cycle years apart
-- expected result: one on cycle and one off cycle election

insert into country values (0, 'c1', 'c1', '01-01-1950', 'es1', 4);

insert into election values (0, 0, '01-01-1950', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', NULL, NULL, 'Parliamentary election');
insert into election values (1, 0, '01-01-1953', 'wiki', 338, 18000000, 14000000, 13000000, 'desc', 0, NULL, 'Parliamentary election');

-- results of query
--  country | num_dissolutions | most_recent_dissolution | num_on_cycle | most_recent_on_cycle 
-- ---------+------------------+-------------------------+--------------+----------------------
--  c1      |                1 | 1953-01-01              |            1 | 1950-01-01
