#!/usr/bin/env bash

set -euo pipefail

DOCKER_ARGS=(
  --rm
  --network example.com
  -e PGPASSWORD=hivemetastore
  -e PGHOST=postgres
  -e PGUSER=hivemetastore
  -e PGDATABASE=hivemetastore
  -w "$PWD"
  -v "$PWD:$PWD"
)

if [ -t 0 ] ; then
  DOCKER_ARGS+=(
    --tty
  )
fi

if [[ "$#" -eq 0 ]]; then
  docker run "${DOCKER_ARGS[@]}" --entrypoint bash postgres:9.6.10
else
  docker run "${DOCKER_ARGS[@]}" postgres:9.6.10 psql "${@}"
fi