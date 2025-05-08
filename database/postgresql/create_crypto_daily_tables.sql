WITH daily_raw AS (

    SELECT

        DATE(time) AS date,
        EXTRACT(hour FROM time) AS hour,
        high,
        low,
        open,
        close,
        volume_from,
        volume_to

    FROM crypto_hourly_etl

),



daily_processed AS (

    SELECT

        date,
        MAX(high) OVER (PARTITION BY date) AS high,
        MIN(low) OVER (PARTITION BY date) AS low,
        FIRST_VALUE(open) OVER(PARTITION BY date ORDER BY hour ASC) AS open,
        FIRST_VALUE(close) OVER(PARTITION BY date ORDER BY hour DESC) AS close,
        SUM(volume_from) OVER (PARTITION BY date) AS daily_volume_from,
        SUM(volume_to) OVER (PARTITION BY date) AS daily_volume_to

    FROM daily_raw
    GROUP BY date, hour, high, low, open, close, volume_from, volume_to

),



daily_final AS (

    SELECT

        DISTINCT(date) AS date,
        high,
        low,
        open,
        close,
        daily_volume_from,
        daily_volume_to

    FROM daily_processed

)



SELECT * FROM daily_final ORDER BY date ASC;