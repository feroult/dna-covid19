#!/bin/sh -e

echo "Creating projections table..."

bq query \
    --destination_table covid19.projections \
    --replace \
    --use_legacy_sql=false \
"SELECT
  country_region,
  case_type,
  outbreak_days,
  CAST(EXP(intercept + slope * outbreak_days) AS INT64) cases
FROM
  UNNEST(GENERATE_ARRAY(1, 50)) AS outbreak_days
FULL OUTER JOIN (
  SELECT
    c.country_region,
    c.case_type,
    slope,
    intercept
  FROM
    covid19.cases c,
    covid19.slopes_log s
  WHERE
    c.country_region = s.country_region
    AND c.case_type = s.case_type
    AND outbreak_countdown = 0 )
ON
  TRUE"
   