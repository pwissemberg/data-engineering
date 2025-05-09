CREATE TABLE crypto_weekly AS (

    WITH weekly_raw AS (

        SELECT

            time,
            DATE(time) AS date,
            EXTRACT(year FROM time) AS calendar_year,
            EXTRACT(week FROM time) AS calendar_week,
            high,
            low,
            open,
            close,
            volume_from,
            volume_to

        FROM crypto_hourly_etl

    ),



    weekly_processed AS (

        SELECT

            FIRST_VALUE(date) OVER(PARTITION BY calendar_year, calendar_week ORDER BY date ASC) AS date,
            calendar_year,
            calendar_week,
            MAX(high) OVER(PARTITION BY calendar_year, calendar_week) AS high,
            MIN(low) OVER(PARTITION BY calendar_year, calendar_week) AS low,
            FIRST_VALUE(open) OVER(PARTITION BY calendar_year, calendar_week ORDER BY time ASC) AS open,
            FIRST_VALUE(close) OVER(PARTITION BY calendar_year, calendar_week ORDER BY time DESC) AS close,
            SUM(volume_from) OVER (PARTITION BY calendar_year, calendar_week) AS volume_from,
            SUM(volume_to) OVER(PARTITION BY calendar_year, calendar_week) AS volume_to

        FROM weekly_raw
        GROUP BY time, date, calendar_year, calendar_week, high, low, open, close, volume_from, volume_to

    ),



    weekly_final AS (

        SELECT

            DISTINCT(date) AS date,
            calendar_year,
            calendar_week,
            high,
            low,
            open,
            close,
            volume_from,
            volume_to

        FROM weekly_processed

    )



    SELECT * FROM weekly_final ORDER BY date ASC



);