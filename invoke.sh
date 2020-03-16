#!/bin/sh 

curl -H \
    "Authorization: Bearer $(gcloud auth print-identity-token)" \
    https://covid19outbreak-d3uwkj73ia-uc.a.run.app