SET SEARCH_PATH TO carschema;

DROP VIEW IF EXISTS confirmed_ongoing_completed_res CASCADE;
DROP VIEW IF EXISTS cancelled_res CASCADE;

CREATE VIEW confirmed_ongoing_completed_res AS
SELECT cust_email, count(*) AS confirmed_ongoing_completed_num
FROM reservation JOIN customer_reservation ON reservation.id = customer_reservation.reservation_id
WHERE status = 'Confirmed' OR
	  status = 'Ongoing' OR
	  status = 'Completed'
GROUP BY cust_email;

CREATE VIEW cancelled_res AS
SELECT cust_email, count(*) AS cancelled_num
FROM reservation JOIN customer_reservation ON reservation.id = customer_reservation.reservation_id
WHERE status = 'Cancelled'
GROUP BY cust_email;

SELECT t1.cust_email, 
	CASE WHEN confirmed_ongoing_completed_num = 0 then 0.0 else cancelled_num::float/confirmed_ongoing_completed_num END AS reservation_cancellation_ratio
FROM confirmed_ongoing_completed_res t1 JOIN cancelled_res t2 ON t1.cust_email = t2.cust_email
ORDER BY reservation_cancellation_ratio DESC, cust_email
LIMIT 2;
