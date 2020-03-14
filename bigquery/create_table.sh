#!/bin/sh -xe

# gcloud auth login --enable-gdrive-access

RAW_TABLE="covid19.raw_cases"
TABLE="covid19.cases"

bq query \
    --destination_table ${TABLE} \
    --replace \
    --use_legacy_sql=false \
"SELECT cases.*, start.start_date, DATE_DIFF(cases.date, start.start_date, DAY) outbreak_days 
   FROM ${RAW_TABLE} cases
 INNER JOIN 
 (SELECT country_region, min(date) start_date 
    FROM ${RAW_TABLE}
   WHERE cases > 0
     and case_type = 'Confirmed'
   GROUP BY country_region
   ORDER BY country_region) start
   ON cases.country_region = start.country_region
WHERE cases.date >= start.start_date"