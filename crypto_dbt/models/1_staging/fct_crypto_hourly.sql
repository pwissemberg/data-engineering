WITH hourly_processed AS (

    SELECT
        
        TO_TIMESTAMP(time) AS time,
        high,
        low,
        open,
        close,
        volumefrom AS volume_from,
        volumeto AS volume_to

    FROM {{ source('crypto_api', 'btc_eur_hourly') }}

    WHERE

        EXTRACT(year FROM TO_TIMESTAMP(time)) >= 2014

)



SELECT * FROM hourly_processed