#!/bin/sh -e

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
  start.date outbreak_start_date, 
  last.date outbreak_last_date,
  DATE_DIFF(cases.date, start.date, DAY) outbreak_days,
  DATE_DIFF(last.date, cases.date, DAY) outbreak_countdown,
   FROM ${RAW_TABLE} cases
LEFT OUTER JOIN 
 (SELECT country_region, min(date) date
    FROM ${RAW_TABLE}
   WHERE cases > ${OUTBREAK_CONFIRMED_CASES}
     and case_type = 'Confirmed'
   GROUP BY country_region) start ON cases.country_region = start.country_region   
LEFT OUTER JOIN
 (SELECT country_region, max(date) date 
    FROM ${RAW_TABLE}
   WHERE case_type = 'Confirmed'
   GROUP BY country_region) last ON cases.country_region = last.country_region"
