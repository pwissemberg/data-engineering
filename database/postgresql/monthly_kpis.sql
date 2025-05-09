CREATE TABLE monthly_kpis AS (



    WITH price_kpis AS (

        SELECT
            
            date,
            calendar_year,
            calendar_month,

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

        FROM crypto_monthly

    ),


    market_kpis AS (

        SELECT

            date,
            calendar_year,
            calendar_month,

            close > open AS is_green_candle,

            CASE
                WHEN open != 0 AND (high - low) / open > 0.2 THEN TRUE
                ELSE FALSE
            END AS is_volatile,

            CASE
                WHEN ABS((close - open)::NUMERIC) < high - low THEN TRUE
                ELSE FALSE
            END AS is_doji_like

        FROM crypto_monthly

    )



    SELECT     
        
        p.date,
        p.calendar_year,
        p.calendar_month,
        p.volume_weighted_avg_price,
        p.variation,
        p.variation_pct,
        p.price_spread,
        p.open_price_spread_pct,
        p.low_price_spread_pct,
        m.is_green_candle,
        m.is_volatile,
        m.is_doji_like

    FROM price_kpis AS p

    LEFT JOIN market_kpis AS m
        ON p.date = m.date

    ORDER BY p.date ASC



);