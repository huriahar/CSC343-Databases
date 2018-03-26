SET SEARCH_PATH TO carschema;

DROP VIEW IF EXISTS most_reserved CASCADE;
DROP VIEW IF EXISTS most_reserved_tie CASCADE;

-- Find the frequency at which each car that was rented in 2017
-- Only consider completed reservations
-- Only consider reservations in Toronto
CREATE VIEW most_reserved AS
SELECT car_id AS id, count(*) AS freq, car.model_id AS model_id
FROM reservation JOIN car ON car.id = reservation.car_id
    JOIN rental_station ON rental_station.code = car.station_code
WHERE EXTRACT(year FROM from_date) = 2017
        AND EXTRACT(year FROM to_date) = 2017
        AND status = 'Completed'
        AND rental_station.city = 'Toronto'
GROUP BY car_id, car.model_id
ORDER BY freq DESC;
LIMIT 1;

-- Get the car model name
SELECT car_model.name, most_reserved_tie.freq
FROM car_model JOIN most_reserved_tie ON car_model.id = most_reserved_tie.model_id;
