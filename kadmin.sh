#!/usr/bin/env bash

set -euo pipefail

DOCKER_ARGS=(
)


if [ ! -t 0 ] ; then
  DOCKER_ARGS+=(
    -T
  )
fi

docker-compose run ${DOCKER_ARGS[*]} \
  -e KRB5_TRACE=/dev/stderr \
  hive-metastore-krb5-client \
  kadmin \
    -p alice/admin@EXAMPLE.COM \
    -w alice ${*}