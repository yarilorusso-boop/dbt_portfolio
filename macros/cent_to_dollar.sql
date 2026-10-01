{%- macro cent_to_dollar(column_name, decimals=4) -%}
    round({{ column_name }} *1.0 / 100.0, {{ decimals }}) 
{%- endmacro -%}