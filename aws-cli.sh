#!/usr/bin/env bash

set -euo pipefail

DOCKER_ARGS=(
  --rm
  --interactive
  --network example.com
  -w "$PWD"
  -v "$PWD:$PWD"
  -e "AWS_ACCESS_KEY_ID=minio"
  -e "AWS_SECRET_ACCESS_KEY=minio123"
  # Fix for Github Action
  # See:
  # https://github.com/aws/aws-cli/issues/5623
  # https://github.com/aws/aws-cli/issues/5262
  -e "AWS_EC2_METADATA_DISABLED=true"
)

if [ -t 0 ] ; then
  DOCKER_ARGS+=(
    --tty
  )
fi

if [[ "$#" -eq 0 ]]; then
  docker run "${DOCKER_ARGS[@]}" \
    --entrypoint bash \
    amazon/aws-cli:2.0.59
else
  docker run "${DOCKER_ARGS[@]}" \
    amazon/aws-cli:2.0.59 \
      --endpoint-url http://hive-metastore-minio.example.com:9000 \
      "${@}"
fi
