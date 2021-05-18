#!/usr/bin/env bash
set -x
docker-compose run \
  -T \
  --rm \
  -v "$PWD:$PWD" \
  -w "$PWD" \
  hive-metastore-presto java -cp presto-custom-client/target/my-app-1.0-SNAPSHOT.jar com.mycompany.app.App
