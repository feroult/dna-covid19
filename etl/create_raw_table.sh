#!/bin/sh -e

DATA_REPO="https://github.com/CSSEGISandData/COVID-19.git"
DATA_PATH="./COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid"
DAILY_REPORTS="./COVID-19/csse_covid_19_data/csse_covid_19_daily_reports"
STAGING_BUCKET="gs://covid19_outbreak"

convert_cases() {
    CASE_TYPE=$1
    cat ${DATA_PATH}-${CASE_TYPE}.csv | ./convert.py ${CASE_TYPE} > .staging/${CASE_TYPE}.csv
}

convert_cases_daily_reports() {
    for report in `find $DAILY_REPORTS -name \*.csv`; do
        date=$(echo $report | rev | cut -d/ -f1 | rev | cut -d. -f1)
        echo $report
        ./convert_daily_report.py $date $report .staging/Cases-$date.csv
    done
}

update_staging() {
    echo "Updating staging..."

    if [ ! -d "COVID-19" ]; then
        git clone --depth=1 ${DATA_REPO}
    else 
        (cd COVID-19 && git pull >/dev/null)
    fi
    rm -rf .staging
    mkdir .staging
    
    echo "Parsing previous dates..."
    # convert_cases "Confirmed"
    # convert_cases "Deaths"
    # convert_cases "Recovered"
    convert_cases_daily_reports

    echo "Fetching today cases..."
    ./today.py > .staging/Today.csv

    NEW_HASH=$(sha256sum .staging/* | sha256sum | cut -d' ' -f1)
    OLD_HASH=$(gsutil cat ${STAGING_BUCKET}/HASH)
    if [ "${NEW_HASH}" == "${OLD_HASH}" ]; then
        echo "Already up to date."
        exit 1
    fi
    gsutil -m cp -r .staging/*.csv ${STAGING_BUCKET}
}

create_raw_table() {
    echo "Creating raw table..."
    bq load \
        --replace \
        --skip_leading_rows 1 \
        --source_format=CSV \
        covid19.raw_cases \
        ${STAGING_BUCKET}/*.csv \
        ./schema.json
}

mark_hash() {
    NEW_HASH=$(sha256sum .staging/* | sha256sum | cut -d' ' -f1)
    echo ${NEW_HASH} > .staging/HASH
    gsutil cp .staging/HASH ${STAGING_BUCKET}/HASH
}

run() {
    update_staging
    create_raw_table
    mark_hash
}

run