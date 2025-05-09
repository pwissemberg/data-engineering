--CREATE OR REPLACE TABLE crypto_yearly AS (

    WITH yearly_raw AS (

        SELECT

            time,
            DATE(time) AS date,
            EXTRACT(year FROM time) AS calendar_year,
            high,
            low,
            open,
            close,
            volume_from,
            volume_to

        FROM crypto_hourly_etl

    ),



    yearly_processed AS (

        SELECT

            FIRST_VALUE(date) OVER(PARTITION BY calendar_year ORDER BY date ASC) AS date,
            calendar_year,
            MAX(high) OVER(PARTITION BY calendar_year) AS high,
            MIN(low) OVER(PARTITION BY calendar_year) AS low,
            FIRST_VALUE(open) OVER(PARTITION BY calendar_year ORDER BY time ASC) AS open,
            FIRST_VALUE(close) OVER(PARTITION BY calendar_year ORDER BY time DESC) AS close,
            SUM(volume_from) OVER (PARTITION BY calendar_year) AS volume_from,
            SUM(volume_to) OVER (PARTITION BY calendar_year) AS volume_to

        FROM monthly_raw
        GROUP BY time, date, calendar_year, high, low, open, close, volume_from, volume_to

    ),



    monthly_final AS (

        SELECT

            DISTINCT(date),
            calendar_year,
            high,
            low,
            open,
            close,
            volume_from,
            volume_to

        FROM yearly_processed

    )



    SELECT * FROM yearly_final ORDER BY date ASC



);