#!/bin/sh -e

DATA_REPO="https://github.com/CSSEGISandData/COVID-19.git"
DATA_PATH="./COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid"
STAGING_BUCKET="gs://covid19_outbreak"
TABLE="covid19.raw_cases"

convert_cases() {
    CASE_TYPE=$1
    cat ${DATA_PATH}-${CASE_TYPE}.csv | python3 ./convert.py ${CASE_TYPE} > .staging/${CASE_TYPE}.csv
}

update_staging() {
    echo "Updating staging..."

    if [ ! -d "COVID-19" ]; then
        git clone --depth=1 ${DATA_REPO}
    else 
        (cd COVID-19 && git pull)
    fi
    rm -rf .staging
    mkdir .staging
    convert_cases "Confirmed"
    convert_cases "Deaths"
    convert_cases "Recovered"
    python3 ./today.py > .staging/Today.csv
    gsutil -m cp -r .staging/*.csv ${STAGING_BUCKET}
}

create_raw_table() {
    echo "Creating raw table..."
    bq load \
        --replace \
        --skip_leading_rows 1 \
        --source_format=CSV \
        ${TABLE} \
        ${STAGING_BUCKET}/*.csv \
        ./schema.json
}

run() {
    update_staging
    create_raw_table
}

run