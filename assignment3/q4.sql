SET SEARCH_PATH TO carschema;

DROP VIEW IF EXISTS thirtyOrYounger CASCADE;
DROP VIEW IF EXISTS cancelled_reservations CASCADE;

-- Find the frequency at which each car that was rented in 2017
CREATE VIEW thirtyOrYounger AS
SELECT email
FROM customer
WHERE age <= 30;

-- Find cancelled reservations in the past 18 months made by customers 30 or younger
CREATE VIEW cancelled_reservations AS
SELECT reservation.id AS id, customer_reservation.cust_email AS email
FROM reservation JOIN customer_reservation ON
    reservation.id = customer_reservation.reservation_id
    JOIN thirtyOrYounger ON thirtyOrYounger.email = customer_reservation.cust_email
WHERE reservation.from_date >= CURRENT_TIMESTAMP - INTERVAL '18 months'
        AND reservation.old_reservation IS NOT NULL;

-- Find customers who made at least 2 such cancellations
SELECT DISTINCT cr1.email
FROM cancelled_reservations cr1 JOIN cancelled_reservations cr2 ON cr1.id <> cr2.id
WHERE cr1.email = cr2.email
