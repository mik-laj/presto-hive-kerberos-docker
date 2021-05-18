#!/usr/bin/env bash
set -euo pipefail

# Terminal Control codes
# see: https://stackoverflow.com/a/5947802
COLOR_GREEN='\033[0;32m'
COLOR_RESET='\033[0m'


function log() {
  echo -e "${COLOR_GREEN}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*${COLOR_RESET}"
}

BUCKET_NAME=hadoop-data

log "Create buckets"
./aws-cli.sh s3 rm --recursive "s3://${BUCKET_NAME}" || true
./aws-cli.sh s3 mb "s3://${BUCKET_NAME}" || true

log "List catalogs"
./presto-send-query.sh "SHOW CATALOGS"

log "Run simple TPCH query"
./presto-send-query.sh "SELECT name FROM tpch.sf1.customer ORDER BY custkey ASC LIMIT 3"

log "Create new schema"
bash -x  ./presto-send-query.sh "CREATE SCHEMA hive.sample_schema
WITH (
   location = 's3a://${BUCKET_NAME}/'
)"

log "Create new table"
./presto-send-query.sh "CREATE TABLE hive.sample_schema.sample_table (
   col1 varchar,
   col2 varchar
)"

log "Insert data"
./presto-send-query.sh "INSERT INTO hive.sample_schema.sample_table SELECT 'value1.1', 'value1.2'"

log "Query data"
./presto-send-query.sh "SELECT * FROM hive.sample_schema.sample_table"
