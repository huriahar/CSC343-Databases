SET SEARCH_PATH TO carschema;

DROP VIEW IF EXISTS reservation_freq CASCADE;
DROP VIEW IF EXISTS most_reserved CASCADE;
DROP VIEW IF EXISTS most_reserved_tie CASCADE;

-- Find the frequency at which each car that was rented in 2017
-- Only consider completed reservations
-- Only consider reservations in Toronto
CREATE VIEW reservation_freq AS
SELECT car.model_id AS model_id, count(*) AS freq
FROM reservation JOIN car ON car.id = reservation.car_id
    JOIN rental_station ON rental_station.code = car.station_code
WHERE EXTRACT(year FROM from_date) = 2017
        AND EXTRACT(year FROM to_date) = 2017
        AND status = 'Completed'
        AND rental_station.city = 'Toronto'
GROUP BY car.model_id;

CREATE VIEW most_reserved AS
SELECT rf1.model_id, rf1.freq
FROM reservation_freq rf1 JOIN reservation_freq rf2
    ON rf1.model_id > rf2.model_id
WHERE rf1.freq < rf2.freq;

CREATE VIEW most_reserved_tie AS
(SELECT * FROM reservation_freq) EXCEPT (SELECT * FROM most_reserved);

-- Get the car model name
SELECT car_model.name AS model_name
FROM car_model JOIN most_reserved_tie ON car_model.id = most_reserved_tie.model_id
ORDER BY car_model.name
-- According to A3 FAQ on piazza
LIMIT 1;
