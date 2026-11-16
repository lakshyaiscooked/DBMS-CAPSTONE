-- ============================================================================
-- FLIGHT RESERVATION MANAGEMENT SYSTEM
-- ---------------------------------------------------------------------
-- SECTION 1: DATABASE CREATION
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS FlightReservationDB;
CREATE DATABASE FlightReservationDB
    CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE FlightReservationDB;

-- ---------------------------------------------------------------------
-- SECTION 2: TABLE CREATION (dependency order)
-- ---------------------------------------------------------------------
CREATE TABLE Airports (
    airport_id    INT          NOT NULL AUTO_INCREMENT,
    airport_code  CHAR(3)      NOT NULL,
    airport_name  VARCHAR(100) NOT NULL,
    city          VARCHAR(50)  NOT NULL,
    country       VARCHAR(50)  NOT NULL,
    PRIMARY KEY (airport_id),
    UNIQUE KEY uk_airport_code (airport_code)
) ENGINE=InnoDB;

CREATE TABLE Routes (
    route_id               INT NOT NULL AUTO_INCREMENT,
    source_airport_id      INT NOT NULL,
    destination_airport_id INT NOT NULL,
    distance_km            INT NOT NULL,
    PRIMARY KEY (route_id),
    UNIQUE KEY uk_route_pair (source_airport_id, destination_airport_id),
    CONSTRAINT fk_routes_source FOREIGN KEY (source_airport_id)
        REFERENCES Airports (airport_id),
    CONSTRAINT fk_routes_destination FOREIGN KEY (destination_airport_id)
        REFERENCES Airports (airport_id),
    CONSTRAINT chk_routes_different CHECK (source_airport_id <> destination_airport_id),
    CONSTRAINT chk_routes_distance  CHECK (distance_km > 0)
) ENGINE=InnoDB;

CREATE TABLE Aircraft (
    aircraft_id     INT          NOT NULL AUTO_INCREMENT,
    aircraft_model  VARCHAR(100) NOT NULL,
    registration_no VARCHAR(20)  NOT NULL,
    seat_capacity   INT          NOT NULL,
    PRIMARY KEY (aircraft_id),
    UNIQUE KEY uk_registration (registration_no),
    CONSTRAINT chk_aircraft_capacity CHECK (seat_capacity > 0)
) ENGINE=InnoDB;

CREATE TABLE Flights (
    flight_id          INT         NOT NULL AUTO_INCREMENT,
    flight_number      VARCHAR(10) NOT NULL,
    route_id           INT         NOT NULL,
    aircraft_id        INT         NOT NULL,
    departure_datetime DATETIME    NOT NULL,
    arrival_datetime   DATETIME    NOT NULL,
    flight_status ENUM('Scheduled','Delayed','Cancelled','Completed')
                NOT NULL DEFAULT 'Scheduled',
    PRIMARY KEY (flight_id),
    CONSTRAINT fk_flights_route    FOREIGN KEY (route_id)    REFERENCES Routes (route_id),
    CONSTRAINT fk_flights_aircraft FOREIGN KEY (aircraft_id) REFERENCES Aircraft (aircraft_id),
    CONSTRAINT chk_flights_times   CHECK (arrival_datetime > departure_datetime)
) ENGINE=InnoDB;

CREATE TABLE Passengers (
    passenger_id   INT          NOT NULL AUTO_INCREMENT,
    passenger_name VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL,
    phone          VARCHAR(15)  NULL,
    loyalty_tier ENUM('Bronze','Silver','Gold','Platinum') NOT NULL DEFAULT 'Bronze',
    PRIMARY KEY (passenger_id),
    UNIQUE KEY uk_passenger_email (email)
) ENGINE=InnoDB;

CREATE TABLE Bookings (
    booking_id        INT          NOT NULL AUTO_INCREMENT,
    passenger_id      INT          NOT NULL,
    flight_id         INT          NOT NULL,
    seat_no           VARCHAR(5)   NULL,
    booking_timestamp DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    booking_status ENUM('Confirmed','Waitlisted','Cancelled','Offloaded')
                    NOT NULL DEFAULT 'Confirmed',
    fare_class ENUM('Economy','Premium Economy','Business','First') NOT NULL,
    fare_amount       DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (booking_id),
    UNIQUE KEY uk_flight_seat (flight_id, seat_no),
    CONSTRAINT fk_bookings_passenger FOREIGN KEY (passenger_id) REFERENCES Passengers (passenger_id),
    CONSTRAINT fk_bookings_flight    FOREIGN KEY (flight_id)    REFERENCES Flights (flight_id),
    CONSTRAINT chk_bookings_fare CHECK (fare_amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE Payments (
    payment_id     INT           NOT NULL AUTO_INCREMENT,
    booking_id     INT           NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_date   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('Pending','Paid','Refunded','Failed') NOT NULL DEFAULT 'Pending',
    payment_method ENUM('UPI','Card','Net Banking','Cash') NOT NULL,
    PRIMARY KEY (payment_id),
    KEY idx_payments_booking (booking_id),          -- NOT unique: one-to-many
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES Bookings (booking_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- SECTION 3: SAMPLE DATA (explicit IDs keep references readable)
-- ---------------------------------------------------------------------
INSERT INTO Airports (
    airport_id,
    airport_code,
    airport_name,
    city,
    country
)
VALUES
    (1, 'DEL', 'Indira Gandhi International Airport', 'Delhi', 'India'),
    (2, 'BOM', 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'India'),
    (3, 'BLR', 'Kempegowda International Airport', 'Bengaluru', 'India'),
    (4, 'HYD', 'Rajiv Gandhi International Airport', 'Hyderabad', 'India'),
    (5, 'MAA', 'Chennai International Airport', 'Chennai', 'India');

INSERT INTO Routes (
    route_id,
    source_airport_id,
    destination_airport_id,
    distance_km
)
VALUES
    (1, 1, 2, 1148),  -- DEL -> BOM
    (2, 1, 3, 1740),  -- DEL -> BLR
    (3, 2, 3, 842),  -- BOM -> BLR
    (4, 1, 4, 1253),  -- DEL -> HYD
    (5, 3, 5, 290); -- BLR -> MAA

INSERT INTO Aircraft (
    aircraft_id,
    aircraft_model,
    registration_no,
    seat_capacity
)
VALUES
    (1, 'Airbus A320', 'VT-DM001', 3),  -- demonstration capacity only
    (2, 'Boeing 737', 'VT-DM002', 5),  -- demonstration capacity only
    (3, 'Airbus A321', 'VT-DM003', 4); -- demonstration capacity only

INSERT INTO Flights (
    flight_id,
    flight_number,
    route_id,
    aircraft_id,
    departure_datetime,
    arrival_datetime,
    flight_status
)
VALUES
    (1, 'AI101', 1, 1, '2026-12-05 06:00:00', '2026-12-05 08:10:00', 'Scheduled'),
    (2, 'AI202', 2, 2, '2026-12-05 09:30:00', '2026-12-05 12:15:00', 'Scheduled'),
    (3, 'AI303', 3, 3, '2026-12-06 14:00:00', '2026-12-06 16:00:00', 'Scheduled'),
    (4, 'AI404', 4, 1, '2026-12-07 07:00:00', '2026-12-07 09:20:00', 'Delayed'),
    (5, 'AI505', 5, 2, '2026-12-08 18:00:00', '2026-12-08 19:00:00', 'Scheduled');

INSERT INTO Passengers (
    passenger_id,
    passenger_name,
    email,
    phone,
    loyalty_tier
)
VALUES
    (1, 'Aarav Sharma', 'aarav.sharma@example.com', '9000000001', 'Platinum'),
    (2, 'Priya Nair', 'priya.nair@example.com', '9000000002', 'Gold'),
    (3, 'Rohan Mehta', 'rohan.mehta@example.com', '9000000003', 'Silver'),
    (4, 'Ananya Iyer', 'ananya.iyer@example.com', '9000000004', 'Bronze'),
    (5, 'Vikram Singh', 'vikram.singh@example.com', '9000000005', 'Gold'),
    (6, 'Sneha Reddy', 'sneha.reddy@example.com', NULL, 'Silver'),
    (7, 'Karan Malhotra', 'karan.malhotra@example.com', '9000000007', 'Bronze'),
    (8, 'Meera Kapoor', 'meera.kapoor@example.com', '9000000008', 'Platinum');

-- Flight 1 (capacity 3): 3 confirmed + 3 waitlisted.  Flight 2 (capacity 5): 2 confirmed + 1 cancelled.
INSERT INTO Bookings (
    booking_id,
    passenger_id,
    flight_id,
    seat_no,
    booking_timestamp,
    booking_status,
    fare_class,
    fare_amount
)
VALUES
    (1, 1, 1, '1A', '2026-11-20 09:15:00', 'Confirmed', 'Business', 8500.00),
    (2, 3, 1, '1B', '2026-11-20 14:30:00', 'Confirmed', 'Economy', 4200.00),
    (3, 4, 1, '1C', '2026-11-21 10:05:00', 'Confirmed', 'Economy', 4200.00),
    (4, 5, 1, NULL, '2026-11-22 11:00:00', 'Waitlisted', 'Premium Economy', 5600.00),
    (5, 2, 1, NULL, '2026-11-22 16:45:00', 'Waitlisted', 'Business', 8500.00),
    (6, 7, 1, NULL, '2026-11-23 08:20:00', 'Waitlisted', 'Economy', 4200.00),
    (7, 2, 2, '2A', '2026-11-21 12:00:00', 'Confirmed', 'Business', 11000.00),
    (8, 6, 2, '2B', '2026-11-22 09:30:00', 'Confirmed', 'Economy', 6500.00),
    (9, 8, 2, '2C', '2026-11-22 13:10:00', 'Cancelled', 'First', 14000.00),  -- seat 2C still held by UNIQUE key
    (10, 3, 3, '3A', '2026-11-23 10:00:00', 'Confirmed', 'Economy', 3800.00),
    (11, 1, 4, '4A', '2026-11-24 15:30:00', 'Confirmed', 'First', 12500.00),
    (12, 5, 4, '4B', '2026-11-25 09:00:00', 'Confirmed', 'Premium Economy', 7400.00);

INSERT INTO Payments (
    payment_id,
    booking_id,
    payment_amount,
    payment_date,
    payment_status,
    payment_method
)
VALUES
    (1, 1, 8500.00, '2026-11-20 09:20:00', 'Paid', 'Card'),
    (2, 2, 4200.00, '2026-11-20 14:35:00', 'Paid', 'UPI'),
    (3, 3, 4200.00, '2026-11-21 10:10:00', 'Paid', 'UPI'),
    (4, 4, 5600.00, '2026-11-22 11:05:00', 'Pending', 'Net Banking'),
    (5, 5, 8500.00, '2026-11-22 16:50:00', 'Pending', 'Card'),
    (6, 6, 4200.00, '2026-11-23 08:25:00', 'Pending', 'UPI'),
    (7, 7, 11000.00, '2026-11-21 12:05:00', 'Paid', 'Card'),
    (8, 8, 6500.00, '2026-11-22 09:35:00', 'Paid', 'Net Banking'),
    (9, 9, 14000.00, '2026-11-22 13:15:00', 'Refunded', 'Card'),
    (10, 10, 3800.00, '2026-11-23 10:05:00', 'Paid', 'UPI'),
    (11, 11, 12500.00, '2026-11-24 15:35:00', 'Paid', 'Card'),
    (12, 12, 7400.00, '2026-11-25 09:05:00', 'Paid', 'Cash');

-- ---------------------------------------------------------------------
-- SECTION 4: BASIC QUERIES
-- ---------------------------------------------------------------------
-- 4.1 Display all flights
SELECT f.flight_id, f.flight_number, a1.airport_code AS source, a2.airport_code AS destination,
        f.departure_datetime, f.arrival_datetime, f.flight_status
FROM Flights f
JOIN Routes r    ON r.route_id = f.route_id
JOIN Airports a1 ON a1.airport_id = r.source_airport_id
JOIN Airports a2 ON a2.airport_id = r.destination_airport_id
ORDER BY f.departure_datetime;

-- 4.2 Search flights between cities on a date
SELECT f.flight_number, a1.city AS from_city, a2.city AS to_city, f.departure_datetime, f.flight_status
FROM Flights f
JOIN Routes r    ON r.route_id = f.route_id
JOIN Airports a1 ON a1.airport_id = r.source_airport_id
JOIN Airports a2 ON a2.airport_id = r.destination_airport_id
WHERE a1.city = 'Delhi' AND a2.city = 'Mumbai'
    AND f.departure_datetime >= '2026-12-05 00:00:00'
    AND f.departure_datetime <  '2026-12-06 00:00:00';

-- 4.3 Passenger booking history
SELECT p.passenger_name, b.booking_id, f.flight_number, b.seat_no, b.fare_class,
        b.booking_status, b.booking_timestamp
FROM Passengers p
JOIN Bookings b ON b.passenger_id = p.passenger_id
JOIN Flights f  ON f.flight_id = b.flight_id
WHERE p.passenger_id = 2
ORDER BY b.booking_timestamp;

-- 4.4 Seat availability (only Confirmed bookings occupy seats)
SELECT f.flight_number, ac.seat_capacity,
        COUNT(b.booking_id) AS confirmed_seats,
        ac.seat_capacity - COUNT(b.booking_id) AS seats_available
FROM Flights f
JOIN Aircraft ac ON ac.aircraft_id = f.aircraft_id
LEFT JOIN Bookings b ON b.flight_id = f.flight_id AND b.booking_status = 'Confirmed'
GROUP BY f.flight_id, f.flight_number, ac.seat_capacity
ORDER BY f.flight_id;

-- 4.5 Waitlisted passengers
SELECT p.passenger_name, p.loyalty_tier, f.flight_number, b.fare_class, b.booking_timestamp
FROM Bookings b
JOIN Passengers p ON p.passenger_id = b.passenger_id
JOIN Flights f    ON f.flight_id = b.flight_id
WHERE b.booking_status = 'Waitlisted'
ORDER BY f.flight_number, b.booking_timestamp;

-- 4.6 Total revenue (net of refunds: only 'Paid' payments counted)
SELECT SUM(payment_amount) AS total_revenue_paid
FROM Payments WHERE payment_status = 'Paid';

SELECT payment_status, COUNT(*) AS payment_count, SUM(payment_amount) AS amount
FROM Payments GROUP BY payment_status ORDER BY payment_status;

-- ---------------------------------------------------------------------
-- SECTION 5: JOIN OPERATIONS
-- ---------------------------------------------------------------------
-- 5.1 INNER JOIN: airport/route relationships
SELECT r.route_id, s.airport_code AS source_code, s.city AS source_city,
        d.airport_code AS dest_code, d.city AS dest_city, r.distance_km
FROM Routes r
INNER JOIN Airports s ON s.airport_id = r.source_airport_id
INNER JOIN Airports d ON d.airport_id = r.destination_airport_id
ORDER BY r.route_id;

-- 5.2 LEFT JOIN: every passenger, including those with no booking history on a flight
SELECT p.passenger_name, COUNT(b.booking_id) AS total_bookings
FROM Passengers p
LEFT JOIN Bookings b ON b.passenger_id = p.passenger_id
GROUP BY p.passenger_id, p.passenger_name
ORDER BY total_bookings DESC, p.passenger_name;

-- 5.3 LEFT JOIN: flights that currently have no bookings (AI505 expected)
SELECT f.flight_number
FROM Flights f
LEFT JOIN Bookings b ON b.flight_id = f.flight_id
WHERE b.booking_id IS NULL;

-- 5.4 Multiple-table JOIN: passenger + booking + flight + route + airports + payment
SELECT p.passenger_name, f.flight_number, s.airport_code AS src, d.airport_code AS dst,
        b.seat_no, b.booking_status, pay.payment_status, pay.payment_method
FROM Bookings b
JOIN Passengers p ON p.passenger_id = b.passenger_id
JOIN Flights f    ON f.flight_id = b.flight_id
JOIN Routes r     ON r.route_id = f.route_id
JOIN Airports s   ON s.airport_id = r.source_airport_id
JOIN Airports d   ON d.airport_id = r.destination_airport_id
LEFT JOIN Payments pay ON pay.booking_id = b.booking_id
ORDER BY b.booking_id;

-- ---------------------------------------------------------------------
-- SECTION 6: BOOKING MANAGEMENT EXAMPLES (inside a transaction, rolled back)
-- ---------------------------------------------------------------------
START TRANSACTION;
    -- create a booking (flight 3 still has free seats, so Confirmed is allowed)
    INSERT INTO Bookings (passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount)
    VALUES (6, 3, '3B', 'Confirmed', 'Economy', 3800.00);
    SET @new_booking = LAST_INSERT_ID();
    -- process payment
    INSERT INTO Payments (booking_id, payment_amount, payment_status, payment_method)
    VALUES (@new_booking, 3800.00, 'Paid', 'UPI');
    -- assign / change seat
    UPDATE Bookings SET seat_no = '3C' WHERE booking_id = @new_booking;
    -- cancel and release seat, mark payment refunded
    UPDATE Bookings SET booking_status = 'Cancelled', seat_no = NULL WHERE booking_id = @new_booking;
    UPDATE Payments
        SET payment_status = 'Refunded'
        WHERE booking_id = @new_booking
        AND payment_status = 'Paid';
    SELECT booking_id, seat_no, booking_status FROM Bookings WHERE booking_id = @new_booking;
ROLLBACK;   -- demonstration only: leaves the sample dataset unchanged

-- ---------------------------------------------------------------------
-- SECTION 7: SQL VIEWS
-- ---------------------------------------------------------------------
-- VIEW 1: flight occupancy (aggregate, not updatable)
CREATE OR REPLACE VIEW v_flight_occupancy AS
SELECT f.flight_number,
        ac.seat_capacity                                        AS total_seats,
        COUNT(b.booking_id)                                     AS seats_booked,
        ac.seat_capacity - COUNT(b.booking_id)                  AS seats_available,
        ROUND(COUNT(b.booking_id) * 100.0 / ac.seat_capacity,2) AS occupancy_percentage
FROM Flights f
JOIN Aircraft ac ON ac.aircraft_id = f.aircraft_id
LEFT JOIN Bookings b ON b.flight_id = f.flight_id AND b.booking_status = 'Confirmed'
GROUP BY f.flight_id, f.flight_number, ac.seat_capacity;

-- VIEW 2: waitlisted / offloaded passengers, highest priority first
CREATE OR REPLACE VIEW v_waitlisted_overbooked AS
SELECT p.passenger_name, f.flight_number, p.loyalty_tier, b.fare_class,
        b.booking_status, b.booking_timestamp
FROM Bookings b
JOIN Passengers p ON p.passenger_id = b.passenger_id
JOIN Flights f    ON f.flight_id = b.flight_id
WHERE b.booking_status IN ('Waitlisted','Offloaded')
ORDER BY FIELD(p.loyalty_tier,'Platinum','Gold','Silver','Bronze'),
        FIELD(b.fare_class,'First','Business','Premium Economy','Economy'),
        b.booking_timestamp;

-- VIEW 3: single-table updatable view with WITH CHECK OPTION
CREATE OR REPLACE VIEW v_confirmed_bookings AS
SELECT booking_id, passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount
FROM Bookings
WHERE booking_status = 'Confirmed'
WITH CHECK OPTION;

SELECT * FROM v_flight_occupancy ORDER BY flight_number;
SELECT * FROM v_waitlisted_overbooked;

-- ---------------------------------------------------------------------
-- SECTION 8: WINDOW FUNCTIONS
-- ---------------------------------------------------------------------
-- 8.1 ROW_NUMBER(): upgrade / offloading order per flight (waitlist queue)
SELECT f.flight_number, p.passenger_name, p.loyalty_tier, b.fare_class, b.booking_status,
        ROW_NUMBER() OVER (
            PARTITION BY b.flight_id
            ORDER BY FIELD(p.loyalty_tier,'Platinum','Gold','Silver','Bronze'),
                    FIELD(b.fare_class,'First','Business','Premium Economy','Economy'),
                    b.booking_timestamp) AS queue_position
FROM Bookings b
JOIN Passengers p ON p.passenger_id = b.passenger_id
JOIN Flights f    ON f.flight_id = b.flight_id
WHERE b.booking_status = 'Waitlisted'
ORDER BY f.flight_number, queue_position;

-- 8.2 RANK(): rank all active (Confirmed/Waitlisted) bookings by tier then fare class (ties share a rank)
SELECT p.passenger_name, f.flight_number, p.loyalty_tier, b.fare_class,
        RANK() OVER (
            ORDER BY FIELD(p.loyalty_tier,'Platinum','Gold','Silver','Bronze'),
                    FIELD(b.fare_class,'First','Business','Premium Economy','Economy')) AS priority_rank
FROM Bookings b
JOIN Passengers p ON p.passenger_id = b.passenger_id
JOIN Flights f    ON f.flight_id = b.flight_id
WHERE b.booking_status IN ('Confirmed','Waitlisted')
ORDER BY priority_rank, f.flight_number, p.passenger_name;

-- 8.3 PARTITION BY: separate ranking within each flight
SELECT f.flight_number, p.passenger_name, p.loyalty_tier, b.fare_class, b.booking_status,
        RANK() OVER (
            PARTITION BY b.flight_id
            ORDER BY FIELD(p.loyalty_tier,'Platinum','Gold','Silver','Bronze'),
                    FIELD(b.fare_class,'First','Business','Premium Economy','Economy')) AS rank_in_flight
FROM Bookings b
JOIN Passengers p ON p.passenger_id = b.passenger_id
JOIN Flights f    ON f.flight_id = b.flight_id
WHERE b.booking_status IN ('Confirmed','Waitlisted')
ORDER BY f.flight_number, rank_in_flight, p.passenger_name;

-- 8.4 SUM() OVER(): running daily revenue per route (Paid payments only)
WITH daily AS (
    SELECT f.route_id, DATE(pay.payment_date) AS pay_day, SUM(pay.payment_amount) AS daily_revenue
    FROM Payments pay
    JOIN Bookings b ON b.booking_id = pay.booking_id
    JOIN Flights f  ON f.flight_id = b.flight_id
    WHERE pay.payment_status = 'Paid'
    GROUP BY f.route_id, DATE(pay.payment_date)
)
SELECT route_id, pay_day, daily_revenue,
        SUM(daily_revenue) OVER (PARTITION BY route_id ORDER BY pay_day
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue
FROM daily
ORDER BY route_id, pay_day;

-- 8.5 LAG(): compare daily booking totals with the previous day
WITH daily AS (
    SELECT DATE(booking_timestamp) AS booking_day, COUNT(*) AS bookings_made
    FROM Bookings GROUP BY DATE(booking_timestamp)
)
SELECT booking_day, bookings_made,
        LAG(bookings_made) OVER (ORDER BY booking_day) AS previous_day,
        bookings_made - LAG(bookings_made) OVER (ORDER BY booking_day) AS change_vs_previous
FROM daily ORDER BY booking_day;

-- ---------------------------------------------------------------------
-- SECTION 9: OVERBOOKING MANAGEMENT QUERIES
-- ---------------------------------------------------------------------
-- 9.1 Capacity position per flight
SELECT f.flight_number, ac.seat_capacity,
        SUM(b.booking_status='Confirmed')  AS confirmed,
        SUM(b.booking_status='Waitlisted') AS waitlisted
FROM Flights f
JOIN Aircraft ac ON ac.aircraft_id = f.aircraft_id
LEFT JOIN Bookings b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number, ac.seat_capacity
ORDER BY f.flight_id;

-- 9.2 Offloading candidates: lowest-priority CONFIRMED passengers first
--     (only relevant if confirmed > capacity, e.g. after an aircraft swap)
SELECT f.flight_number, p.passenger_name, p.loyalty_tier, b.fare_class,
        ROW_NUMBER() OVER (
            PARTITION BY b.flight_id
            ORDER BY FIELD(p.loyalty_tier,'Bronze','Silver','Gold','Platinum'),
                    FIELD(b.fare_class,'Economy','Premium Economy','Business','First'),
                    b.booking_timestamp DESC) AS offload_order
FROM Bookings b
JOIN Passengers p ON p.passenger_id = b.passenger_id
JOIN Flights f    ON f.flight_id = b.flight_id
WHERE b.booking_status = 'Confirmed'
ORDER BY f.flight_number, offload_order;

-- ---------------------------------------------------------------------
-- SECTION 10: COMPOSITE INDEXING AND EXPLAIN
-- (Flights(route_id, departure_datetime) and the Bookings lookup index
--  are created here, AFTER the "before" EXPLAIN output is captured.)
-- ---------------------------------------------------------------------
-- A. Flight search. Routes already has UNIQUE (source_airport_id, destination_airport_id).
EXPLAIN SELECT f.flight_number, f.departure_datetime
FROM Routes r JOIN Flights f ON f.route_id = r.route_id
WHERE r.source_airport_id = 1 AND r.destination_airport_id = 2
AND f.departure_datetime >= '2026-12-05 00:00:00' AND f.departure_datetime < '2026-12-06 00:00:00';

CREATE INDEX idx_flights_route_departure
    ON Flights (route_id, departure_datetime);

EXPLAIN SELECT f.flight_number, f.departure_datetime
FROM Routes r JOIN Flights f ON f.route_id = r.route_id
WHERE r.source_airport_id = 1 AND r.destination_airport_id = 2
AND f.departure_datetime >= '2026-12-05 00:00:00' AND f.departure_datetime < '2026-12-06 00:00:00';

-- B. Booking lookup.
EXPLAIN SELECT * FROM Bookings
WHERE flight_id = 1 AND seat_no = '1A' AND booking_status = 'Confirmed';

CREATE INDEX idx_bookings_flight_seat_status
    ON Bookings (flight_id, seat_no, booking_status);

EXPLAIN SELECT * FROM Bookings
WHERE flight_id = 1 AND seat_no = '1A' AND booking_status = 'Confirmed';

-- Leftmost-prefix limitation: this composite index is not designed for a search
-- that omits its leading flight_id column.
EXPLAIN SELECT * FROM Bookings WHERE booking_status = 'Confirmed' AND seat_no = '1A';

SHOW INDEX FROM Bookings;
SHOW INDEX FROM Flights;

-- ---------------------------------------------------------------------
-- SECTION 11: TRIGGERS
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_bookings_before_insert
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE v_capacity INT;
    DECLARE v_confirmed INT;
    DECLARE v_fstatus VARCHAR(20);

    SELECT ac.seat_capacity, f.flight_status
    INTO v_capacity, v_fstatus
    FROM Flights f
    JOIN Aircraft ac ON ac.aircraft_id = f.aircraft_id
    WHERE f.flight_id = NEW.flight_id;

    IF NEW.booking_status IN ('Confirmed', 'Waitlisted')
    AND v_fstatus IN ('Cancelled', 'Completed') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Flight is cancelled or completed: booking rejected';
    END IF;

    IF NEW.booking_status = 'Confirmed' THEN
        IF NEW.seat_no IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A Confirmed booking must have a seat number';
        END IF;

        SELECT COUNT(*) INTO v_confirmed
        FROM Bookings
        WHERE flight_id = NEW.flight_id AND booking_status = 'Confirmed';

        IF v_confirmed >= v_capacity THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Flight is full: insert as Waitlisted instead';
        END IF;
    END IF;

    IF NEW.booking_status = 'Waitlisted' AND NEW.seat_no IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A Waitlisted booking cannot hold a seat';
    END IF;
END$$

CREATE TRIGGER trg_bookings_before_update
BEFORE UPDATE ON Bookings
FOR EACH ROW
BEGIN
    DECLARE v_capacity INT;
    DECLARE v_confirmed INT;

    -- Terminal states cannot be reopened; a new booking must be made.
    IF OLD.booking_status IN ('Cancelled', 'Offloaded')
    AND NEW.booking_status IN ('Confirmed', 'Waitlisted') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cancelled/Offloaded bookings cannot be reactivated';
    END IF;

    IF NEW.booking_status = 'Confirmed' AND OLD.booking_status <> 'Confirmed' THEN
        IF NEW.seat_no IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Assign a seat when confirming a booking';
        END IF;

        SELECT ac.seat_capacity INTO v_capacity
        FROM Flights f
        JOIN Aircraft ac ON ac.aircraft_id = f.aircraft_id
        WHERE f.flight_id = NEW.flight_id;

        SELECT COUNT(*) INTO v_confirmed
        FROM Bookings
        WHERE flight_id = NEW.flight_id AND booking_status = 'Confirmed'
        AND booking_id <> NEW.booking_id;

        IF v_confirmed >= v_capacity THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Flight is full: cannot confirm booking';
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------
-- SECTION 12: STORED PROCEDURES (transaction management + row locking)
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_create_booking(
    IN p_passenger_id INT,
    IN p_flight_id INT,
    IN p_seat_no VARCHAR(5),
    IN p_fare_class VARCHAR(20),
    IN p_fare DECIMAL(10,2)
)
BEGIN
    DECLARE v_capacity INT;
    DECLARE v_confirmed INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    -- Serialize concurrent bookings for this flight by locking its row.
    SELECT ac.seat_capacity INTO v_capacity
    FROM Flights f
    JOIN Aircraft ac ON ac.aircraft_id = f.aircraft_id
    WHERE f.flight_id = p_flight_id
    FOR UPDATE;

    SELECT COUNT(*) INTO v_confirmed
    FROM Bookings
    WHERE flight_id = p_flight_id AND booking_status = 'Confirmed'
    FOR UPDATE;

    IF v_confirmed < v_capacity AND p_seat_no IS NOT NULL THEN
        INSERT INTO Bookings (
            passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount
        )
        VALUES (p_passenger_id, p_flight_id, p_seat_no, 'Confirmed', p_fare_class, p_fare);
    ELSE
        INSERT INTO Bookings (
            passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount
        )
        VALUES (p_passenger_id, p_flight_id, NULL, 'Waitlisted', p_fare_class, p_fare);
    END IF;

    COMMIT;
    SELECT booking_id, booking_status, seat_no
    FROM Bookings
    WHERE booking_id = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_cancel_and_promote(IN p_booking_id INT)
BEGIN
    DECLARE v_flight INT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_seat VARCHAR(5);
    DECLARE v_next INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT flight_id, booking_status, seat_no
    INTO v_flight, v_status, v_seat
    FROM Bookings
    WHERE booking_id = p_booking_id
    FOR UPDATE;

    IF v_status IS NULL OR v_status NOT IN ('Confirmed', 'Waitlisted') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Booking not found or not cancellable';
    END IF;

    -- Release the seat so the UNIQUE key does not block its reuse.
    UPDATE Bookings SET booking_status = 'Cancelled', seat_no = NULL
    WHERE booking_id = p_booking_id;
    UPDATE Payments SET payment_status = 'Refunded'
    WHERE booking_id = p_booking_id AND payment_status = 'Paid';

    -- Promote the highest-priority waitlisted passenger into the freed seat.
    IF v_status = 'Confirmed' THEN
        SELECT b.booking_id INTO v_next
        FROM Bookings b
        JOIN Passengers p ON p.passenger_id = b.passenger_id
        WHERE b.flight_id = v_flight AND b.booking_status = 'Waitlisted'
        ORDER BY FIELD(p.loyalty_tier, 'Platinum', 'Gold', 'Silver', 'Bronze'),
                FIELD(b.fare_class, 'First', 'Business', 'Premium Economy', 'Economy'),
                b.booking_timestamp
        LIMIT 1 FOR UPDATE;

        IF v_next IS NOT NULL THEN
            UPDATE Bookings SET booking_status = 'Confirmed', seat_no = v_seat
            WHERE booking_id = v_next;
        END IF;
    END IF;

    COMMIT;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------
-- SECTION 13: TRIGGER / VIEW / PROCEDURE TESTS
-- Statements marked EXPECTED ERROR are meant to fail; run them one at a time
-- in Workbench (a failing statement stops a whole-script run).
-- ---------------------------------------------------------------------
-- T1 EXPECTED ERROR 1644: flight 1 is full (3/3 confirmed)
-- INSERT INTO Bookings (passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount)
--   VALUES (6, 1, '1D', 'Confirmed', 'Economy', 4200);
-- T2 EXPECTED ERROR 1644: confirmed without seat
-- INSERT INTO Bookings (passenger_id, flight_id, booking_status, fare_class, fare_amount)
--   VALUES (6, 3, 'Confirmed', 'Economy', 3800);
-- T3 EXPECTED ERROR 1644: reactivating a cancelled booking
-- UPDATE Bookings SET booking_status = 'Confirmed' WHERE booking_id = 9;
-- T4 EXPECTED ERROR 1369: WITH CHECK OPTION violation
-- UPDATE v_confirmed_bookings SET booking_status = 'Cancelled' WHERE booking_id = 10;
-- T5 EXPECTED ERROR 1062: seat 2C remains reserved by the cancelled sample row
-- because UNIQUE (flight_id, seat_no) also applies to that row.
-- INSERT INTO Bookings (passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount)
--   VALUES (4, 2, '2C', 'Confirmed', 'Economy', 6500);
-- T7 EXPECTED ERROR 1644: a Waitlisted booking must not hold a seat
-- INSERT INTO Bookings (passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount)
--   VALUES (6, 1, '1Z', 'Waitlisted', 'Economy', 4200);
-- T8 insert through the WITH CHECK OPTION view (allowed: row satisfies the view condition)
-- INSERT INTO v_confirmed_bookings (passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount)
--   VALUES (6, 3, '3D', 'Confirmed', 'Economy', 3800);   -- then: DELETE FROM Bookings WHERE seat_no = '3D';
-- T9 EXPECTED ERROR 1369: insert a Cancelled row through the view
-- INSERT INTO v_confirmed_bookings (passenger_id, flight_id, seat_no, booking_status, fare_class, fare_amount)
--   VALUES (6, 3, '3E', 'Cancelled', 'Economy', 3800);
-- T6 Procedure demos (these COMMIT and change data):
-- CALL sp_create_booking(6, 3, '3B', 'Economy', 3800.00);   -- Confirmed (flight 3 has space)
-- CALL sp_create_booking(6, 4, '4C', 'Economy', 7000.00);   -- flight 4 has 2 of 3 seats taken -> Confirmed
-- CALL sp_cancel_and_promote(1);                            -- frees 1A, promotes top waitlisted on flight 1

-- ---------------------------------------------------------------------
-- SECTION 14: FINAL OBJECT CHECK
-- ---------------------------------------------------------------------
SHOW FULL TABLES;
SHOW TRIGGERS;
SELECT (SELECT COUNT(*) FROM Airports) AS airports, (SELECT COUNT(*) FROM Routes) AS routes,
    (SELECT COUNT(*) FROM Aircraft) AS aircraft, (SELECT COUNT(*) FROM Flights) AS flights,
    (SELECT COUNT(*) FROM Passengers) AS passengers, (SELECT COUNT(*) FROM Bookings) AS bookings,
    (SELECT COUNT(*) FROM Payments) AS payments;
-- END OF FILE
