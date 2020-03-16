#!/bin/sh -xe

PROJECT_ID="feroult-cloud"

gcloud builds submit --tag gcr.io/${PROJECT_ID}/covid19_outbreak
