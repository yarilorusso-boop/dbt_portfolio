{% set database = target.database | upper %}
{% set schema = target.schema | upper %}

SELECT    
    table_type,
    table_schema,
    table_name,
    last_altered,
    CASE WHEN table_type = 'VIEW' THEN 'VIEW'
         ELSE 'TABLE' END AS object_type,
    {% raw %}
    'DROP ' || CASE WHEN table_type = 'VIEW' THEN 'VIEW' ELSE 'TABLE' END || ' ' || table_catalog || '.' || table_schema || '.' || table_name || ';' AS drop_statement
    {% endraw %}
FROM {{ target.database }}.information_schema.tables
WHERE table_schema = UPPER('{{ target.schema }}')
  AND date(last_altered) <= date(dateadd('day', -7, current_date))
ORDER BY 4 DESC


