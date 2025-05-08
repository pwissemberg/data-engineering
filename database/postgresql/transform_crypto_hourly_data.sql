-- Test: Convert timestamp to datetime (i.e integers to date and hours)  
/*SELECT
    time AS timestamp_time,
    TO_TIMESTAMP(time) AS date_time
FROM crypto_hourly_elt
ORDER BY time DESC
LIMIT 5;*/

CREATE TABLE crypto_hourly_elt_transformed AS (

    WITH transformed AS (

        SELECT

            TO_TIMESTAMP(time) AS time,
            high,
            low,
            open,
            close,
            volumefrom AS volume_from,
            volumeto AS volume_to
        
        FROM crypto_hourly_elt

    )
    
    SELECT * FROM transformed ORDER BY time ASC

);