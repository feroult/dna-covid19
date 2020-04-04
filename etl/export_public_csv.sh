#!/bin/sh 

BUCKET="gs://covid19-john-hopkins-university-unofficial-export"
FILE="cases-$(date -v-60M '+%Y%m%d-%H')h.csv.gz"
URI="${BUCKET}/${FILE}"

export_last_period() {
    echo "exporting..."
    bq extract \
        --compression GZIP \
        'covid19.cases' \
        ${URI}
}

update_index_page() {
    list=""
    for file in $(gsutil ls ${BUCKET}/*.gz); do
        url="https://storage.googleapis.com/$(echo $file | cut -c6-)"
        desc="$(echo $file | rev | cut -d/ -f1 | rev)"
        list="${list}<p><a href=\"${url}\">${desc}</a></p>"
    done
    list=$list sh -c 'echo "'"$(cat index.html)"'"' > .staging/exports.html
    gsutil cp .staging/exports.html ${BUCKET}
    gsutil \
        setmeta -h "Content-Type:text/html" \
        -h "Cache-Control:private, max-age=0, no-transform" \
        ${BUCKET}/*.html
}

gsutil ls ${URI}

if [ $? -eq 0 ]; then
    echo "already exported"
else
    export_last_period
    update_index_page
fi

update_index_page

