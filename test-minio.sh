#!/usr/bin/env bash

set -euo pipefail

BUCKET_NAME=test-bucket-$RANDOM

./aws-cli.sh s3 mb "s3://${BUCKET_NAME}"
./aws-cli.sh s3 ls | grep ${BUCKET_NAME}
./aws-cli.sh s3 rb "s3://${BUCKET_NAME}" | grep ${BUCKET_NAME}
