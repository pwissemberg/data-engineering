CREATE TABLE crypto_monthly AS (

    WITH monthly_raw AS (

        SELECT

            time,
            DATE(time) AS date,
            EXTRACT(year FROM time) AS calendar_year,
            EXTRACT(month FROM time) AS calendar_month,
            high,
            low,
            open,
            close,
            volume_from,
            volume_to

        FROM crypto_hourly_etl

    ),



    monthly_processed AS (

        SELECT

            FIRST_VALUE(date) OVER(PARTITION BY calendar_year, calendar_month ORDER BY date ASC) AS date,
            calendar_year,
            calendar_month,
            MAX(high) OVER(PARTITION BY calendar_year, calendar_month) AS high,
            MIN(low) OVER(PARTITION BY calendar_year, calendar_month) AS low,
            FIRST_VALUE(open) OVER(PARTITION BY calendar_year, calendar_month ORDER BY time ASC) AS open,
            FIRST_VALUE(close) OVER(PARTITION BY calendar_year, calendar_month ORDER BY time DESC) AS close,
            SUM(volume_from) OVER (PARTITION BY calendar_year, calendar_month) AS volume_from,
            SUM(volume_to) OVER (PARTITION BY calendar_year, calendar_month) AS volume_to

        FROM monthly_raw
        GROUP BY time, date, calendar_year, calendar_month, high, low, open, close, volume_from, volume_to

    ),



    monthly_final AS (

        SELECT

            DISTINCT(date) AS date,
            calendar_year,
            calendar_month,
            high,
            low,
            open,
            close,
            volume_from,
            volume_to

        FROM monthly_processed

    )



    SELECT * FROM monthly_final ORDER BY date ASC



);