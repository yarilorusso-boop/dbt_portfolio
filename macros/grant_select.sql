{% macro grant_select(schema=target.schema, role=target.role, database=target.database) %}
     {% set sql %}
         use database {{ database }};
         GRANT usage ON SCHEMA {{ schema }} TO {{ role }};
         GRANT select ON ALL TABLES IN SCHEMA {{ schema }} TO {{ role }};
         GRANT select on ALL VIEWS IN SCHEMA {{ schema }} TO {{ role }};
     {% endset %}
     {{log ("Granting select on schema " ~ schema ~ " to role " ~ role, info=True)}}
     {% do run_query(sql) %}
     {{log ("Finished Granting select on schema " ~ schema ~ " to role " ~ role ~ " completed", info=True)}}
     {% endmacro %}