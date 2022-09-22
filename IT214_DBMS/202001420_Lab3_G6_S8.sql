SET SEARCH_PATH TO rail_db --I. Create before trigger functions to avoid the common error message.
    --1. Create a trigger on the Table of your choice to check if the Primary key ID already exists or not before inserting a new record & Send a custom reply instead of an error message.
    -- Creating trigger function
CREATE OR REPLACE FUNCTION rail_db.primary_key_check() RETURNS trigger AS $$
DECLARE temp_id integer;
BEGIN
SELECT tc_id into temp_id
from rail_db.ticketcollector tc1
where tc1.tc_id = NEW.tc_id;
IF(temp_id = NEW.tc_id) THEN RAISE NOTICE 'Notice : This violates constraint of primary key.';
RETURN OLD;
ELSE RAISE NOTICE 'Notice : Primary key does not exist in table.';
RETURN NEW;
END IF;
END;
$$ LANGUAGE 'plpgsql';
-- trigger
CREATE OR REPLACE TRIGGER "trigger1" BEFORE
INSERT ON "rail_db".ticketcollector FOR EACH ROW EXECUTE PROCEDURE "rail_db".primary_key_check() -- verification
INSERT INTO ticketcollector
VALUES(9, 'darsh', 'mehta', 29);
INSERT INTO ticketcollector
VALUES(18, 'raju', 'sheth', 22);
INSERT INTO ticketcollector
VALUES(34, 'mohan', 'shah', 22);
--2. Create a trigger on the Table of your choice to check if the Foreign key ID already exists or not before inserting a new record. & Send a custom reply instead of an Notice  message.
-- trigger function
CREATE OR REPLACE FUNCTION rail_db.foreign_key_check() RETURNS trigger AS $$
DECLARE temp_id integer;
BEGIN
SELECT tc_id into temp_id
from rail_db.train t1
where t1.tc_id = NEW.tc_id;
IF(temp_id = NEW.tc_id) THEN RAISE NOTICE 'Notice : Foreign key already exists in this table.';
RETURN OLD;
ELSE RAISE NOTICE 'Notice : Foreign key is not present in this table.';
RETURN NEW;
END IF;
END;
$$ LANGUAGE 'plpgsql';
-- trigger
CREATE OR REPLACE TRIGGER "trigger2" BEFORE
INSERT ON "rail_db".train FOR EACH ROW EXECUTE PROCEDURE "rail_db".foreign_key_check() --verification
INSERT INTO train
VALUES(
        201,
        'Rajdhani Express',
        '10:21:00',
        '02:30:00',
        12,
        '2022-08-11',
        14
    );
INSERT INTO train
VALUES(
        202,
        'Vikas Express',
        '09:05:00',
        '04:30:00',
        12,
        '2022-08-11',
        31
    );
--II. Create functions for a specific section.
--1. Find the ticket id for an amount greater than 2000. Return a temp table with ticket id, amount and status in the result table. Make sure below both records are visible in results.
--tickets with id greater than 2000
SELECT ticket_id
FROM ticket
WHERE amount > 2000
ORDER BY ticket_id;
--trigger function
CREATE OR REPLACE FUNCTION rail_db.func_temp1_Q2() RETURNS TABLE(a integer, b integer, c character(30)) AS $$
DECLARE TEMP_R_LIST record;
BEGIN CREATE TEMP TABLE test (a1 integer, b1 integer, c1 character(30)) ON COMMIT DROP;
FOR TEMP_R_LIST IN (
    select ticket_id,
        amount,
        status
    from rail_db.ticket
) LOOP IF(TEMP_R_LIST.amount > 2000) THEN
INSERT INTO test (a1, b1, c1)
VALUES (
        TEMP_R_LIST.ticket_id,
        TEMP_R_LIST.amount,
        TEMP_R_LIST.status
    );
END IF;
END LOOP;
RETURN QUERY TABLE test;
END;
$$ LANGUAGE 'plpgsql';
SELECT ALL rail_db.func_temp1_Q2() --2. Create a new column, “total_amount” in the ticket table. Call the function to calculate the total amount with the formula amount+0.12*amount. Display the updated table.
    -- new attribute total_amount
ALTER TABLE ticket
ADD total_amount decimal(7, 2);
-- trigger function
CREATE OR REPLACE FUNCTION rail_db.func_temp2_Q2() RETURNS void AS $$
DECLARE TEMP_R_LIST record;
BEGIN FOR TEMP_R_LIST IN (
    select ticket_id,
        amount,
        total_amount
    FROM rail_db.ticket
) LOOP
UPDATE rail_db.ticket
SET total_amount = TEMP_R_LIST.amount + 0.12 * TEMP_R_LIST.amount
WHERE TEMP_R_LIST.ticket_id = ticket_id;
END LOOP;
END;
$$ LANGUAGE 'plpgsql';
SELECT rail_db.func_temp2_Q2();
SELECT *
FROM ticket
ORDER BY ticket_id;
---III.	Create Trigger functions for a specific section.
---1. Create a column “state” in the station table. Create a trigger to put the default value 1 for every new entry if nothing is given by the user. Insert new records and check the functionality of Triggers.
-- new attribute state
ALTER TABLE station
ADD state INTEGER -- trigger function
CREATE OR REPLACE FUNCTION rail_db.state_update() RETURNS trigger AS $$
DECLARE temp_state int;
BEGIN
SELECT state INTO temp_state
from rail_db.station s
where s.station_id = NEW.station_id
    and state is not null;
update station
set state = 1
where NEW.station_id = station_id;
if(temp_state <> 1) then
update station
set state = temp_state
WHERE NEW.station_id = station_id;
end if;
return new;
END;
$$ LANGUAGE 'plpgsql';
-- trigger
CREATE OR REPLACE TRIGGER "t3"
AFTER
INSERT ON rail_db.station FOR EACH ROW EXECUTE PROCEDURE rail_db.state_update();
INSERT INTO station
VALUES(103, 'BM6 HGF', '09:15:00', 202, 'Yes');
INSERT INTO station
VALUES(101, 'BHF H68', '11:15:00', 202, 'Yes', 5);
SELECT *
FROM station -- 2. Create a new table del_train with column tr_id. Create a new Trigger and call after deletion. After each train deletion it should enter the tr_id to the del_train table. Check for at least 3 records and print the del_train table.
    CREATE TABLE del_train(tr_id integer);
-- trigger function
CREATE OR REPLACE FUNCTION rail_db.train_backup() RETURNS TRIGGER AS $$ BEGIN
INSERT INTO del_train
VALUES(OLD.train_id);
RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';
-- trigger
CREATE OR REPLACE TRIGGER "trigger_train_backup"
AFTER DELETE ON train FOR EACH ROW EXECUTE PROCEDURE rail_db.train_backup();
--Inserting some extra data 
INSERT INTO train(train_id, tc_id)
VALUES(201, 4),
(202, 2),
(203, 8),
(204, 9),
(205, 11);
--Deleting data from train
DELETE FROM train
WHERE train_id = 201;
SELECT *
FROM rail_db.del_train;
DELETE FROM train
WHERE train_id = 202;
SELECT *
FROM rail_db.del_train;
DELETE FROM train
WHERE train_id = 204;
DELETE FROM train
WHERE train_id = 205;
SELECT *
FROM rail_db.del_train;