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
  outbreak.start_date outbreak_start_date, 
  outbreak.last_date outbreak_last_date,
  DATE_DIFF(cases.date, outbreak.start_date, DAY) outbreak_days,
  DATE_DIFF(outbreak.last_date, cases.date, DAY) outbreak_countdown,
  PARSE_DATETIME('%Y-%m-%d %H:%M:%S', cases.last_update_date) last_update_date
   FROM ${RAW_TABLE} cases
INNER JOIN 
 (SELECT country_region, min(date) start_date, max(date) last_date
    FROM ${RAW_TABLE}
   WHERE cases > ${OUTBREAK_CONFIRMED_CASES}
     and case_type = 'Confirmed'
   GROUP BY country_region
   ORDER BY country_region) outbreak
ON cases.country_region = outbreak.country_region"
