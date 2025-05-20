WITH price_kpis AS (

    SELECT
            
        date,

        {{ ratio('volume_from', 'volume_to') }} AS volume_weighted_avg_price,

        {{ difference('close', 'open') }} AS variation,

        {{ difference_pct('close', 'open') }} AS variation_pct,

        {{ difference('high', 'low') }} AS price_spread,
            
        /*CASE
            WHEN open != 0 THEN ROUND((100 * (high - low) / open)::NUMERIC, 2)
            ELSE NULL
        END AS open_price_spread_pct,*/
            
        {{ difference_pct('high', 'low') }} AS price_spread_pct,

        -- Advanced KPIs
        {{ rolling('date', 'close', 7, 'avg') }} AS moving_avg,
        {{ rolling('date', 'close', 7, 'std') }} AS volatility,
        {{ z_score('date', 'close', 7) }} AS z_score,
        {{ rolling('date', 'high', 7, 'max') }} AS rolling_max_high,
        {{ rolling('date', 'low', 7, 'min') }} AS rolling_min_low

    FROM {{ ref('fct_crypto_daily') }}
    GROUP BY date, high, low, open, close, volume_from, volume_to

),


market_kpis AS (

    SELECT

        date,

        {{ is_greater('close', 'open') }} AS is_green_candle,


        /*CASE
            WHEN open != 0 AND (high - low) / open > 0.2 THEN TRUE
            ELSE FALSE
        END AS is_volatile,*/

        {{ is_greater('high - low', 'ABS((close - open)::NUMERIC)') }} AS is_doji_like,

        --Advanced KPIs
        {{ is_greater('close', 'AVG(close)') }} OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS is_price_above_avg

    FROM {{ ref('fct_crypto_daily') }}
    GROUP BY date, high, low, open, close

)



    SELECT     
        
        p.date,
        p.volume_weighted_avg_price,
        p.variation,
        p.variation_pct,
        p.price_spread,
        --p.open_price_spread_pct,
        p.price_spread_pct,
        p.moving_avg,
        m.is_price_above_avg,
        p.volatility,
        p.z_score,
        p.rolling_max_high,
        p.rolling_min_low,
        m.is_green_candle,
        --m.is_volatile,
        m.is_doji_like

    FROM price_kpis AS p

    LEFT JOIN market_kpis AS m
        ON p.date = m.date

    ORDER BY p.date ASC