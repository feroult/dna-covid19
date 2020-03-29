#!/bin/sh -x

PROJECT_ID="feroult-cloud"
JOB_ID="update-covid19"
URI="https://covid19outbreak-d3uwkj73ia-uc.a.run.app"
CLIENT_SERVICE_ACCOUNT_EMAIL="${JOB_ID}@${PROJECT_ID}.iam.gserviceaccount.com "

create_service_account() {
  gcloud iam service-accounts create ${JOB_ID}

  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member serviceAccount:${CLIENT_SERVICE_ACCOUNT_EMAIL} \
    --role roles/run.invoker
}

create_scheduler() {
  gcloud scheduler jobs delete ${JOB_ID}
  gcloud scheduler jobs create http ${JOB_ID} \
    --http-method=GET \
    --schedule="every 2 minutes" \
    --uri=${URI} \
    --oidc-service-account-email=${CLIENT_SERVICE_ACCOUNT_EMAIL}
}

# create_service_account
create_scheduler  