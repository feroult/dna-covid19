#!/bin/sh -xe

SPREADSHEET="1avGWWl1J19O_Zm0NGTGy2E-fOG05i4ljRfjl87P7FiA"

TABLE="covid19.raw_cases"

bq rm -f -t ${TABLE}

bq mk \
    --external_table_definition=./schema.json@GOOGLE_SHEETS=https://drive.google.com/open?id=${SPREADSHEET} \
    $TABLE
