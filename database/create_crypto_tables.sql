CREATE TABLE crypto_hourly_etl(

    time DATETIME NOT NULL,
    high FLOAT NOT NULL,
    low FLOAT NOT NULL,
    open FLOAT NOT NULL,
    close FLOAT NOT NULL,
    volume_from FLOAT NOT NULL,
    volume_to FLOAT NOT NULL

);

INSERT INTO crypto_hourly_etl (time, high, low, open, close, volume_from, volume_to) VALUES (-1, -1, -1, -1, -1, -1, -1);

-- Test if table was created by inserting data
SELECT * FROM crypto_hourly_etl;

-- Delete all records then
-- N.B: To delete a table from a db, use DROP statement
-- TRUNCATE TABLE crypto_hourly;
DELETE FROM crypto_hourly_etl;

-- After Python data loading, check if data have been successfully loaded
SELECT * FROM crypto_hourly_etl;