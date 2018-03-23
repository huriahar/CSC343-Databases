-- Schema for storing data about car rental services, which provide cars on rent
-- to customers for a period of time. Cars are kept at renatl stations which are
-- situated at fixed locations

DROP SCHEMA IF EXISTS carschema CASCADE;
CREATE SCHEMA carschema;

SET SEARCH_PATH to carschema;

-- Customer information
CREATE TABLE customer (
	id INT primary key,
	-- Full name of the customer
	name VARCHAR(50) NOT NULL UNIQUE,
	-- May not need this, but nice to have
	age INT NOT NULL check
		(age >=18 AND age <= 120),
	email VARCHAR(100) NOT NULL
);

CREATE TABLE car_model (
	id INT primary key,
	name VARCHAR(30) NOT NULL UNIQUE,
	vehicle_type VARCHAR(10) NOT NULL,
	model_num INT NOT NULL,
	capacity INT NOT NULL
);

CREATE TABLE rental_station (
	code INT primary key,
	name VARCHAR(50) NOT NULL UNIQUE,
	address VARCHAR(100) NOT NULL,
	area_code VARCHAR(10) NOT NULL,
	city VARCHAR(30) NOT NULL
);