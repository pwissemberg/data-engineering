SELECT
    
    TO_TIMESTAMP(time) AS time,
    high,
    low,
    open,
    close,
    volumefrom AS volume_from,
    volumeto AS volume_to

FROM {{ source('crypto_api', 'crypto_hourly_elt') }}