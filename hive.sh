#!/usr/bin/env bash


set -euo pipefail

DOCKER_ARGS=(
  --interactive
  -e KRB5_TRACE=/dev/null
  -e HADOOP_OPTS=
)


if [ -t 0 ] ; then
  DOCKER_ARGS+=(
    --tty
  )
fi

if [[ "$#" -eq 0 ]]; then
  docker exec "${DOCKER_ARGS[@]}" hive-metastore-hive-metastore /opt/hive/bin/hive
else
  docker exec "${DOCKER_ARGS[@]}" hive-metastore-hive-metastore /opt/hive/bin/hive "${@}"
fi
