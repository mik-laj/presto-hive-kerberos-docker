#!/usr/bin/env bash

set -euo pipefail
function usage() {
    CMDNAME="$(basename -- "$0")"

      echo """
Usage: ${CMDNAME} <sql>

Sends a SQL query to the Presto cluster and waits for the result.
"""
}

if [[ ! "$#" -eq 1 ]]; then
    echo "You must provide exactly one argument."
    usage
    exit 1
fi


function send_query {
  SQL="${1}"
  RESPONSE="$(docker-compose run -e KRB5_TRACE=/dev/null --rm hive-metastore-krb5-client bash -c "
  kinit -k bob@EXAMPLE.COM &> /dev/null;
  curl -X POST \
    --insecure \
    --negotiate \
    -u : \
    'https://hive-metastore-presto.example.com:7778/v1/statement' \
    --data ${SQL@Q}
  ")"
  echo "RESPONSE=${RESPONSE}"
  NEXT_URL="$(echo "${RESPONSE}"| jq -r .nextUri)"
  STATE="$(echo "${RESPONSE}" | jq -r .stats.state)"

  echo "${RESPONSE}" | jq .

  while [[ "${STATE}" == "QUEUED" ]]; do
    RESPONSE="$(docker-compose run -e KRB5_TRACE=/dev/null --rm hive-metastore-krb5-client bash -c "
    kinit -k bob@EXAMPLE.COM &>/dev/null;
    curl -X GET \
      --insecure \
      --negotiate \
      -u : \
      '${NEXT_URL}'
    ")"
    STATE="$(echo "${RESPONSE}" | jq -r .stats.state)"
    NEXT_URL="$(echo "${RESPONSE}" | jq -r .nextUri)"
    echo "${RESPONSE}" | jq .
  done;
  if [[ "${STATE}" == "FAILED" ]]; then
    exit 1
  fi
  while [[ ! "${NEXT_URL}" == "null" ]]; do
    RESPONSE="$(docker-compose run -e KRB5_TRACE=/dev/null --rm hive-metastore-krb5-client bash -c "
    kinit -k bob@EXAMPLE.COM &>/dev/null;
    curl -X GET \
      --insecure \
      --negotiate \
      -u : \
      '${NEXT_URL}'
    ")"
    NEXT_URL="$(echo "${RESPONSE}" | jq -r .nextUri)"
    echo "${RESPONSE}" | jq .
  done;

  if [[ "${STATE}" == "FAILED" ]]; then
    exit 1
  fi
}

send_query "${1}"

