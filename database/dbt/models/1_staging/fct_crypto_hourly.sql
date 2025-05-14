WITH hourly_raw AS (

    SELECT
        
        time,
        high,
        low,
        open,
        close,
        volumefrom AS volume_from,
        volumeto AS volume_to

    FROM {{ source('crypto_api', 'crypto_hourly_elt') }}

),



hourly_processed AS (

    SELECT
        
        TO_TIMESTAMP(time) AS time,
        high,
        low,
        open,
        close,
        volume_from,
        volume_to

    FROM hourly_raw

),



hourly_final AS (

    SELECT

        DISTINCT *

    FROM hourly_processed

)



SELECT * FROM hourly_final