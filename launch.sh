#!/bin/sh
/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file /key/credentials.json --project "$PROJECT" -q
/google-cloud-sdk/bin/gcloud $*