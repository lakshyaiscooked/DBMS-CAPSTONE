# Flight Reservation Management System

A MySQL database project for managing airports, routes, aircraft, flights, passengers, bookings and payments. The SQL script demonstrates relational table design, flight-search queries, booking history, seat availability, waitlisting, views, window functions, indexes, triggers and stored procedures.

## Project structure

```text
Flight_Reservation_System_GitHub_Ready/
├── Flight_Reservation_System.sql
├── README.md
├── .gitignore
└── .vscode/
    └── settings.json
```

## Requirements

- MySQL Server 8.0 or later
- MySQL Workbench 8.0 or another MySQL client that supports stored procedures and triggers

The database uses MySQL 8 features, including `utf8mb4_0900_ai_ci`, enforced `CHECK` constraints, window functions and stored program delimiters.

## Run the project

1. Start your local MySQL Server.
2. Open `Flight_Reservation_System.sql` in MySQL Workbench.
3. Review the setup warning at the top of the file.
4. Execute the script from top to bottom using **Query > Execute (All or Selection)** or the lightning-bolt execute button.
5. Refresh the Schemas panel and select `FlightReservationDB` to inspect the tables, views, triggers and stored procedures.

> **Important:** The first section runs `DROP DATABASE IF EXISTS FlightReservationDB`. Running the script deletes and recreates that database, including any existing data in it. Back up anything you need before execution.

## Database tables

| Table | Purpose |
|---|---|
| `Airports` | Airport codes, names, cities and countries |
| `Routes` | Source airport, destination airport and route distance |
| `Aircraft` | Aircraft model, registration number and seat capacity |
| `Flights` | Flight number, route, aircraft, schedule and status |
| `Passengers` | Passenger contact details and loyalty tier |
| `Bookings` | Passenger reservations, seats, fare details and booking status |
| `Payments` | Payments associated with bookings |

## Features demonstrated

- Primary keys, foreign keys, unique constraints and `CHECK` constraints
- Sample data for all seven tables
- Basic `SELECT` queries and multi-table `JOIN` operations
- Booking and payment changes inside a transaction that is rolled back
- Views for flight occupancy, waitlisted bookings and confirmed bookings
- Window functions including `ROW_NUMBER()`, `RANK()`, `SUM() OVER()` and `LAG()`
- Composite indexes and `EXPLAIN` statements for selected lookups
- Triggers for validating booking inserts and updates
- Stored procedures for creating bookings and cancelling/promoting bookings
- Final checks for database objects and sample row counts

## Testing notes

The file contains commented test examples in Section 13. Statements marked `EXPECTED ERROR` are intended to fail and should be tested one at a time; do not uncomment all of them and run the entire script together. The procedure demonstrations in that section use `COMMIT` and change data. The main booking-management example in Section 6 is wrapped in a transaction and ends with `ROLLBACK`, so it does not keep those demonstration changes.

The sample data intentionally uses small aircraft capacities to make a full flight and a waitlist easy to demonstrate. One cancelled sample booking retains seat `2C`, which demonstrates a limitation of the current `UNIQUE (flight_id, seat_no)` constraint: it still reserves that seat value until the booking's `seat_no` is set to `NULL`. The cancellation procedure does set the released seat to `NULL` before promoting the next passenger.

The `EXPLAIN` statements are included so that query plans can be inspected in Workbench. Query-plan output, benchmark timings and multi-session concurrency test results are not stored in this repository; capture them separately only after running the tests on your own MySQL instance.

## Suggested GitHub repository description

`MySQL-based flight reservation database demonstrating relational design, SQL queries, views, window functions, indexing, triggers and stored procedures.`
