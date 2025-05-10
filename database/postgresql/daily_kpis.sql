CREATE TABLE daily_kpis AS (



    WITH price_kpis AS (

        SELECT
            
            date,

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
            END AS low_price_spread_pct,

            -- Advanced KPIs
            AVG(close) OVER (ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg,
            STDDEV(close) OVER (ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS volatility,
            CASE
                WHEN STDDEV(close) OVER (ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) != 0 THEN (close - AVG(close) OVER (ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / STDDEV(close) OVER (ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
                ELSE NULL
            END AS z_score,
            MAX(high) OVER (ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_max_high,
            MIN(low) OVER (ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_min_low

        FROM crypto_daily
        GROUP BY date, high, low, open, close, volume_from, volume_to

    ),


    market_kpis AS (

        SELECT

            date,

            close > open AS is_green_candle,

            CASE
                WHEN open != 0 AND (high - low) / open > 0.2 THEN TRUE
                ELSE FALSE
            END AS is_volatile,

            CASE
                WHEN ABS((close - open)::NUMERIC) < high - low THEN TRUE
                ELSE FALSE
            END AS is_doji_like,

            --Advanced KPIs
            close > AVG(close) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS is_price_above_avg

        FROM crypto_daily
        GROUP BY date, high, low, open, close

    )



    SELECT     
        
        p.date,
        p.volume_weighted_avg_price,
        p.variation,
        p.variation_pct,
        p.price_spread,
        p.open_price_spread_pct,
        p.low_price_spread_pct,
        p.moving_avg,
        m.is_price_above_avg
        p.volatility,
        p.z_score,
        p.rolling_max_high,
        p.rolling_min_low
        m.is_green_candle,
        m.is_volatile,
        m.is_doji_like

    FROM price_kpis AS p

    LEFT JOIN market_kpis AS m
        ON p.date = m.date

    ORDER BY p.date ASC



);