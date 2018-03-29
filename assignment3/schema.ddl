-- Schema for storing data about car rental services, which provide cars on rent
-- to customers for a period of time. Cars are kept at renatl stations which are
-- situated at fixed locations

-- What constraints from the domain could not be enforced?
-- 1) Customer can change a reservation only once - can be enforced by doing
--    a self-join of reservation and ensuring that the previous reservation id of 
--    at least on of then is NULL - requires triggers
-- 2) Ensure that same customer does not make two reservations for overlapping dates - requires triggers
-- 3) Update and deletes on tables - requires triggers
-- 4) Make sure that each non-cancelled reservation in reservation table is associated 
--    with at least one customer email

DROP SCHEMA IF EXISTS carschema CASCADE;
CREATE SCHEMA carschema;

SET SEARCH_PATH to carschema;

-- The schema follows closely to the data given in Car-data.txt

-- Customer information
CREATE TABLE customer (
    -- Full name of the customer
    name VARCHAR(50) NOT NULL UNIQUE,
    -- May not need the check, but nice to have
    age INT NOT NULL check (age >=18),
    email VARCHAR(100) PRIMARY KEY
);

-- Information about the modelof the car
CREATE TABLE car_model (
    id INT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    -- Not restricted to {'SUV', 'Luxury', 'Economy', 'Mini Van', 'Sports'}
    -- as don't know the othe possible options for this field
    vehicle_type VARCHAR(10) NOT NULL,
    model_num INT NOT NULL,
    capacity INT NOT NULL check (capacity >= 0)
);

-- Identifying rental station with unique ID and name
-- Also contains the address
CREATE TABLE rental_station (
    code INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    address VARCHAR(100) NOT NULL,
    area_code VARCHAR(10) NOT NULL,
    city VARCHAR(30) NOT NULL
);

-- Identifies cars associated with each rental station
CREATE TABLE car (
    id INT PRIMARY KEY,
    licence_plate VARCHAR(10) NOT NULL UNIQUE,
    station_code INT NOT NULL REFERENCES rental_station(code),
    model_id INT NOT NULL REFERENCES car_model(id)
);

CREATE TYPE reservation_status AS ENUM (
    'Completed', 'Cancelled', 'Confirmed', 'Ongoing');

-- Reservations associated with each car and for the duration specified
-- Can have only 1 previous reservation - not enforced
CREATE TABLE reservation (
    id INT PRIMARY KEY,
    from_date TIMESTAMP NOT NULL,
    -- Check to date is higher than from date
    to_date TIMESTAMP NOT NULL check (to_date > from_date),
    car_id INT NOT NULL REFERENCES car(id),
    old_reservation INT REFERENCES reservation(id),
    status reservation_status NOT NULL
);

-- Associate each reservation with one or more customer emails
CREATE TABLE customer_reservation (
    cust_email VARCHAR(100) NOT NULL REFERENCES customer(email),
    reservation_id INT NOT NULL REFERENCES reservation(id)
);
