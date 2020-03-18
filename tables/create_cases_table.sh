#!/bin/sh -e

echo "Creating cases table..."

bq query \
    --destination_table covid19.cases \
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
  DATE_DIFF(cases.date, start.date, DAY) outbreak_days,
  DATE_DIFF(CURRENT_DATE(), cases.date, DAY) outbreak_countdown
   FROM covid19.raw_cases cases
LEFT OUTER JOIN 
 (SELECT country_region, min(date) date
    FROM covid19.raw_cases
   WHERE cases > 10
     and case_type = 'Confirmed'
   GROUP BY country_region) start ON cases.country_region = start.country_region"
   