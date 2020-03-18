#!/bin/sh -xe

PROJECT_ID="feroult-cloud"

gcloud run deploy covid19outbreak \
    --image gcr.io/${PROJECT_ID}/covid19_outbreak \
    --region us-central1 \
    --platform managed \
    -q

