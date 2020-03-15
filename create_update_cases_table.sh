#!/bin/sh -xe

# gcloud auth login --enable-gdrive-access

RAW_TABLE="covid19.raw_cases"
TABLE="covid19.cases"
OUTBREAK_CONFIRMED_CASES="10"

bq query \
    --destination_table ${TABLE} \
    --replace \
    --use_legacy_sql=false \
"SELECT 
  cases.country_region,
  cases.province_state,
  cases.date,
  cases.case_type,
  cases.cases,
  CONCAT(CAST(cases.lat as STRING),',',CAST(cases.long as STRING)) lat_long,
  ST_GEOGPOINT(cases.long, cases.lat) point,
  cases.difference,
  start.start_date, 
  DATE_DIFF(cases.date, start.start_date, DAY) outbreak_days,
  PARSE_DATETIME('%Y-%m-%d %H:%M:%S', cases.last_update_date) last_update_date
   FROM ${RAW_TABLE} cases
 INNER JOIN 
 (SELECT country_region, min(date) start_date 
    FROM ${RAW_TABLE}
   WHERE cases > ${OUTBREAK_CONFIRMED_CASES}
     and case_type = 'Confirmed'
   GROUP BY country_region
   ORDER BY country_region) start
   ON cases.country_region = start.country_region
WHERE cases.date >= start.start_date"