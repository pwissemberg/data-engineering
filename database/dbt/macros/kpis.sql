{% macro round(metric, decimal) %}

    ROUND((metric)::NUMERIC, 2)

{% endmacro %}



{% macro volume_weighted_avg_price(volume_from, volume_to) %}

    CASE
        WHEN {{ volume_from }} != 0 THEN {{ volume_to }} / {{ volume_from }}
        ELSE NULL
    END

{% endmacro %}



{% macro difference(col1, col2) %}

    {{ col1 }} - {{ col2 }}

{% endmacro %}



{% macro difference_pct(col1, col2) %}

    CASE
        WHEN {{ col2 }} != 0 THEN 100 * {{ ratio(difference(col1, col2), col2) }}
        ELSE NULL
    END

{% endmacro %}



{% macro moving_avg(time, target, window) %}

    AVG({{ target }}) OVER (ORDER BY {{ time }} ASC ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW) 
    
{% endmacro %}



{% macro volatility(time, target, window) %}

    STDDEV({{ target }}) OVER (ORDER BY {{ time }} ASC ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW) 
    
{% endmacro %}



{% macro z_score(time, target, window) %}

    CASE
        WHEN {{ volatility(time, target, window) }} != 0 THEN ({{ target }} - AVG({{ target }}) OVER (ORDER BY {{ time }} ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW)) / {{ volatility(time, target, window) }}
        ELSE NULL
    END
    
{% endmacro %}



{% macro rolling_max(time, target, window) %}

    MAX({{ target }}) OVER (ORDER BY {{ time }} ASC ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW)

{% endmacro %}



{% macro rolling_min(time, target, window) %}

    MIN({{ target }}) OVER (ORDER BY {{ time }} ASC ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW)

{% endmacro %}



{% macro is_greater(col1, col2) %}

        {{ col1 }} > {{ col2 }}

{% endmacro %}



{% macro ratio(numerator, denominator) %}

    CASE
        WHEN {{ denominator }} != 0 THEN {{ numerator }} / {{ denominator }}
        ELSE NULL
    END

{% endmacro %}



{% macro rolling(time, target, window, func) %}

    {% if func == 'avg' %}
        AVG({{ target }}) OVER (ORDER BY {{ time }} ASC ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW)
    {% elif func == 'std' %}
        STDDEV({{ target }}) OVER (ORDER BY {{ time }} ASC ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW)
    {% elif func == 'min' %}
        MIN({{ target }}) OVER (ORDER BY {{ time }} ASC ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW)
    {% elif func == 'max' %}
        MAX({{ target }}) OVER (ORDER BY {{ time }} ASC ROWS BETWEEN {{ window - 1 }} PRECEDING AND CURRENT ROW)
    {% else %}
        {% do log('Function only supports: AVG, STDDEV, MIN, MAX') %}
    {% endif %} 

{% endmacro %}