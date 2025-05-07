-- Convert timestamp into datetime
SELECT
    time AS timestamp_time,
    DATETIME(time, 'unixepoch') AS date_time 
FROM crypto_hourly_elt;



WITH transformed AS (

    SELECT

        DATETIME(time, 'unixepoch') AS date_time,
        high,
        low,
        open,
        close,
        volumefrom AS volume_from,
        volumeto AS volume_to
        --Dropping conversionType and conversionSymbols columns simply by not selecting them

    FROM crypto_hourly_elt

)

SELECT * FROM transformed ORDER BY date_time ASC;


-- Not authorized in SQLite
/*CREATE TABLE crypto_hourly_elt_transformed(

    WITH transformed AS (

        SELECT

            DATETIME(time, 'unixepoch') AS date_time,
            high,
            low,
            open,
            close,
            volumefrom AS volume_from,
            volumeto AS volume_to
            --Dropping conversionType and conversionSymbols columns simply by not selecting them

        FROM crypto_hourly_elt

    )

    SELECT * FROM transformed ORDER BY date_time ASC

);*/


CREATE TABLE crypto_hourly_elt_tmp AS
SELECT
    DATETIME(time, 'unixepoch') AS date_time,
    high,
    low,
    open,
    close,
    volumefrom AS volume_from,
    volumeto AS volume_to
    --Dropping conversionType and conversionSymbols columns simply by not selecting them
FROM crypto_hourly_elt;

CREATE TABLE crypto_hourly_elt_transformed AS
SELECT
    *
FROM crypto_hourly_elt_tmp
ORDER BY date_time ASC;

DROP TABLE crypto_hourly_elt_tmp;

SELECT * FROM crypto_hourly_elt_transformed;