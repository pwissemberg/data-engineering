WITH hourly_processed AS (

    SELECT
        
        TO_TIMESTAMP(time) AS time,
        high,
        low,
        open,
        close,
        volumefrom AS volume_from,
        volumeto AS volume_to

    FROM {{ source('crypto_api', 'crypto_hourly_elt') }}

    WHERE

        EXTRACT(year FROM TO_TIMESTAMP(time)) >= 2014

),



hourly_final AS (

    SELECT

        DISTINCT *

    FROM hourly_processed

)



SELECT * FROM hourly_final