SET SEARCH_PATH TO carschema;

DROP VIEW IF EXISTS shared_reservations CASCADE;

-- Select all reservations which have more than 1 driver/customer
CREATE VIEW shared_reservations AS
SELECT reservation_id, count(*) AS num_drivers
FROM customer_reservation JOIN reservation ON customer_reservation.reservation_id = reservation.id
WHERE status <> 'Cancelled'
GROUP BY reservation_id
HAVING count(*) > 1
ORDER BY reservation_id;

SELECT cust_email, count(*) AS num_shared_reservations
FROM customer_reservation JOIN shared_reservations ON customer_reservation.reservation_id = shared_reservations.reservation_id
GROUP BY cust_email
ORDER BY num_shared_reservations DESC, cust_email
LIMIT 2;
