#!/usr/bin/env bash

set -euo pipefail

echo "Test keytab file"
docker-compose run \
  --rm \
  -T \
  -e KRB5_TRACE=/dev/stderr \
  hive-metastore-krb5-client \
    klist -k

docker-compose run \
  -T \
  --rm \
  hive-metastore-krb5-client \
    klist -k | grep bob@EXAMPLE.COM

echo "Test credentials"
docker-compose run \
  -T \
  --rm \
  -e KRB5_TRACE=/dev/stderr \
    hive-metastore-krb5-client bash -c "
      kinit -k bob@EXAMPLE.COM && \
      klist | tee /dev/stderr | grep 'krbtgt/EXAMPLE.COM@EXAMPLE.COM'
    "
