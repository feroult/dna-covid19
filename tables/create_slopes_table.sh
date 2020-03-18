#!/bin/sh -e

echo "Creating slopes table..."

bq query \
    --destination_table covid19.slopes \
    --replace \
    --use_legacy_sql=false \
"SELECT
          country_region,
          case_type,
          slope,
          (SUM_OF_Y - SLOPE * SUM_OF_X) / N AS INTERCEPT,
          CORRELATION
     FROM
          (
               SELECT
                    country_region,
                    case_type,
                    N,
                    SUM_OF_X,
                    SUM_OF_Y,
                    CORRELATION * STDDEV_OF_Y / STDDEV_OF_X AS SLOPE,
                    CORRELATION
               FROM
                    (
                         SELECT
                              country_region,
                              case_type,
                              COUNT(*) AS N,
                              SUM(X) AS SUM_OF_X,
                              SUM(Y) AS SUM_OF_Y,
                              STDDEV_POP(X) AS STDDEV_OF_X,
                              STDDEV_POP(Y) AS STDDEV_OF_Y,
                              CORR(X, Y) AS CORRELATION
                         FROM
                              (
                                   SELECT
                                        c.country_region,
                                        c.case_type,
                                        c.outbreak_days AS X,
                                        SUM(c.cases) AS Y
                                   FROM
                                        covid19.cases c
                                   WHERE
                                        c.outbreak_days >= 0
                                        AND c.outbreak_countdown <= 10
                                   GROUP BY
                                        c.country_region,
                                        c.case_type,
                                        c.outbreak_days
                              )
                         WHERE
                              country_region IS NOT NULL
                              AND X IS NOT NULL
                              AND Y IS NOT NULL
                         GROUP BY
                              country_region,
                              case_type
                    )
          )
     WHERE
          IS_NAN(slope) = FALSE
     ORDER BY
          case_type,
          slope DESC"
   