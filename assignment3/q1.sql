SET SEARCH_PATH TO carschema;

DROP VIEW IF EXISTS confirmed_ongoing_completed_res CASCADE;
DROP VIEW IF EXISTS cancelled_res_ids CASCADE;
DROP VIEW IF EXISTS cancelled_reservations CASCADE;

CREATE VIEW confirmed_ongoing_completed_res AS
SELECT cust_email, count(*) AS confirmed_ongoing_completed_num
FROM reservation JOIN customer_reservation ON reservation.id = customer_reservation.reservation_id
WHERE status = 'Confirmed' OR
      status = 'Ongoing' OR
      status = 'Completed'
GROUP BY cust_email;

-- Subtract all reservations which were rescheduled from all cancelled reservations
CREATE VIEW cancelled_res_ids AS
SELECT id
FROM reservation
WHERE status = 'Cancelled' AND
      id NOT IN
      (SELECT t1.id
       FROM reservation t1, reservation t2
       WHERE t1.status = 'Cancelled' AND
             t2.old_reservation = t1.id);

CREATE VIEW cancelled_reservations AS
SELECT cust_email, count(*) AS cancelled_num
FROM cancelled_res_ids JOIN customer_reservation ON cancelled_res_ids.id = customer_reservation.reservation_id
GROUP BY cust_email;

SELECT t1.cust_email, cancelled_num, confirmed_ongoing_completed_num,
    CASE WHEN confirmed_ongoing_completed_num = 0 THEN 0.0
         ELSE cancelled_num::float/confirmed_ongoing_completed_num END AS reservation_cancellation_ratio
FROM confirmed_ongoing_completed_res t1 JOIN cancelled_reservations t2 ON t1.cust_email = t2.cust_email
ORDER BY reservation_cancellation_ratio DESC, cust_email
LIMIT 2;
