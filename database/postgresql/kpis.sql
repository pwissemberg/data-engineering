WITH price_kpis AS (

    SELECT
        
        time,

        CASE
            WHEN volume_from != 0 THEN ROUND((volume_to / volume_from)::NUMERIC, 2)
            ELSE NULL
        END AS volume_weighted_avg_price,
        
        ROUND(
            (close - open)::NUMERIC, 
            2
        ) AS variation,

        CASE
            WHEN open != 0 THEN ROUND((100 * (close - open) / open)::NUMERIC, 2)
            ELSE NULL
        END AS variation_pct,
        
        ROUND(
            (high - low)::NUMERIC, 
            2
        ) AS price_spread,
        
        CASE
            WHEN open != 0 THEN ROUND((100 * (high - low) / open)::NUMERIC, 2)
            ELSE NULL
        END AS open_price_spread_pct,
        
        CASE
            WHEN low != 0 THEN ROUND((100 * (high - low) / low)::NUMERIC, 2)
        END AS low_price_spread_pct

    FROM crypto_hourly_etl

),


market_kpis AS (

    SELECT

        time,

        close > open AS is_green_candle,

        CASE
            WHEN open != 0 AND (high - low) / open > 0.2 THEN TRUE
            ELSE FALSE
        END AS is_volatile,

        CASE
            WHEN ABS((close - open)::NUMERIC) < high - low THEN TRUE
            ELSE FALSE
        END AS is_doji_like

    FROM crypto_hourly_etl

)

SELECT * FROM market_kpis ORDER BY time DESC;