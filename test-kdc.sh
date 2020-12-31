#!/usr/bin/env bash

set -euo pipefail

DOCKER_ARGS=()

docker-compose exec -T \
  hive-metastore-kdc \
    kadmin.local list_principals

docker-compose exec -T \
  hive-metastore-kdc \
    kadmin.local list_principals | grep hive-metastore-presto.example.com@EXAMPLE.COM

docker-compose exec -T \
  hive-metastore-kdc \
    kadmin.local list_principals | grep alice/admin@EXAMPLE.COM

docker-compose exec -T \
  hive-metastore-kdc \
      kadmin.local list_principals | grep bob@EXAMPLE.COM
