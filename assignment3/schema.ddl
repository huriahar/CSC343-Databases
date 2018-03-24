-- Schema for storing data about car rental services, which provide cars on rent
-- to customers for a period of time. Cars are kept at renatl stations which are
-- situated at fixed locations

DROP SCHEMA IF EXISTS carschema CASCADE;
CREATE SCHEMA carschema;

SET SEARCH_PATH to carschema;

-- Customer information
CREATE TABLE customer (
    -- Full name of the customer
    name VARCHAR(50) NOT NULL UNIQUE,
    -- May not need the check, but nice to have
    age INT NOT NULL check (age >=18),
    email VARCHAR(100) PRIMARY KEY
);

CREATE TABLE car_model (
    id INT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    vehicle_type VARCHAR(10) NOT NULL,
    model_num INT NOT NULL,
    capacity INT NOT NULL check (capacity >= 0)
);

CREATE TABLE rental_station (
    code INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    address VARCHAR(100) NOT NULL,
    area_code VARCHAR(10) NOT NULL,
    city VARCHAR(30) NOT NULL
);

CREATE TABLE car (
    id INT PRIMARY KEY,
    licence_plate VARCHAR(10) NOT NULL UNIQUE,
    station_code INT NOT NULL REFERENCES rental_station(code),
    model_id INT NOT NULL REFERENCES car_model(id)
);

CREATE TYPE reservation_status AS ENUM (
    'Completed', 'Cancelled', 'Confirmed', 'Ongoing');

-- Ensuring that the same customer does not make two reservations
-- on overlapping time periods requires triggers - not implemented
CREATE TABLE reservation (
    id INT PRIMARY KEY,
    from_date TIMESTAMP NOT NULL,
    -- Check to date is higher than from date
    to_date TIMESTAMP NOT NULL check (to_date > from_date),
    car_id INT NOT NULL REFERENCES car(id),
    old_reservation INT REFERENCES reservation(id),
    status reservation_status NOT NULL
);

CREATE TABLE customer_reservation (
    cust_email VARCHAR(100) NOT NULL REFERENCES customer(email),
    reservation_id INT NOT NULL REFERENCES reservation(id)
);
