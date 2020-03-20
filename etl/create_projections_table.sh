#!/bin/sh -e

echo "Creating projections table..."

bq query \
    --destination_table covid19.projections \
    --replace \
    --use_legacy_sql=false \
"SELECT
  *
FROM (
  SELECT
    country_region,
    country_region || ' (projected)' AS label,
    case_type,
    outbreak_days,
    'Projected' AS data_type,
    p.cases
  FROM (
    SELECT
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
      TRUE) p
  WHERE
    p.outbreak_days > (
    SELECT
      MAX(outbreak_days)
    FROM
      covid19.cases
    WHERE
      country_region = p.country_region)
  UNION ALL
  SELECT
    country_region,
    label,
    case_type,
    outbreak_days,
    data_type,
    SUM(cases)
  FROM (
    SELECT
      country_region,
      country_region AS label,
      case_type,
      outbreak_days,
      'Valid' AS data_type,
      c.cases
    FROM
      covid19.cases c
    WHERE
      outbreak_days >= 0)
  GROUP BY
    country_region,
    label,
    case_type,
    outbreak_days,
    data_type)"
   
