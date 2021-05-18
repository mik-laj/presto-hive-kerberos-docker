#!/usr/bin/env bash

set -euo pipefail

DOCKER_ARGS=(
  --interactive
)


if [ -t 0 ] ; then
  DOCKER_ARGS+=(
    --tty
  )
fi

docker exec "${DOCKER_ARGS[@]}" \
  hive-metastore-hive-metastore hadoop org.apache.hadoop.security.KDiag ${*}
