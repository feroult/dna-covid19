#!/bin/sh -xe

SPREADSHEET="1avGWWl1J19O_Zm0NGTGy2E-fOG05i4ljRfjl87P7FiA"

#SCHEMA="country_region:STRING,province_state:STRING,date:DATE,case_type:STRING,cases:INTEGER,long:NUMERIC,lat:NUMERIC,difference:INTEGER,last_update_date:DATETIME"

TABLE="covid19.cases"

bq rm -f -t ${TABLE}

bq mk \
    --external_table_definition=./schema.json@GOOGLE_SHEETS=https://drive.google.com/open?id=${SPREADSHEET} \
    $TABLE
