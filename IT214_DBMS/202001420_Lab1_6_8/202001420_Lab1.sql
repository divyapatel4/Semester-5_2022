-- Query 1: Show all the details of the ticket collector.
SELECT * FROM rail_db.ticketcollector;

-- Query 2: List the ticket id whose price is greater than Rs3000.
SELECT ticket_id FROM rail_db.ticket
WHERE Amount >3000;

-- Query 3: Show all the food items that are not available.   
SELECT item FROM rail_db.pantry
where availability = 'No';

-- Query 4: Count the number of female passengers.
SELECT count(gender) FROM rail_db.passengerdetails
WHERE gender = 'female';

-- Query 5: Find out the smallest age of passenger travelling.
SELECT MIN(age) as minimum FROM rail_db.passengerdetails;

-- Query 6: Find out the eldest tc among all the ticket collectors.
SELECT max(age) as eldest FROM rail_db.ticketcollector;

-- Query 7: Write a query to print all the food items being served on the train.
SELECT DISTINCT item from rail_db.pantry;

-- Query 8: Print the name of trains where numb of seats available is greater than 5
SELECT train_name FROM rail_db.train
WHERE seats_available>5;

-- Query 9: Print the number of rows present in the passenger table
SELECT count(passenger_id) FROM rail_db.passengerdetails;

-- Query 10: Find the ticket id of the costliest ticket.
SELECT ticket_id FROM rail_db.ticket
where amount = (select(max(amount)) from rail_db.ticket );

-- Query 11: Show the second highest priced ticket_id
SELECT ticket_id FROM rail_db.ticket
ORDER BY amount DESC
LIMIT 1
OFFSET 1;

-- Query 12: Print the name of passengers whose ticket is confirmed
SELECT name FROM rail_db.passengerdetails
WHERE reservation_status  = 'confirm';


-- Query 13: Print all the names of stations.
SELECT name FROM rail_db.station

-- Query 14: Print the name of all the ticket collectors who are below the age of 40.
SELECT first_name,last_name FROM rail_db.ticketcollector
WHERE age<40

-- Query 15: Write a query to print the number of foods that were available & their mode of payment was online.
SELECT * FROM rail_db.pantry
WHERE availability='Yes' and payment_mode='online'
