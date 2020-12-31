#!/usr/bin/env bash
set -euo pipefail

# Terminal Control codes
# see: https://stackoverflow.com/a/5947802
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

function log() {
  echo -e "${COLOR_GREEN}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*${COLOR_RESET}"
}

function run_verbose {
  log "Executing cmd: ${*}"
  ${*}
}

BUCKET_NAME=hadoop-data

log "Create buckets"
./aws-cli.sh s3 rm --recursive "s3://${BUCKET_NAME}" || true
./aws-cli.sh s3 mb "s3://${BUCKET_NAME}" || true

log "Create table"
./hive.sh -e "DROP TABLE employee" || true
./hive.sh -e "CREATE TABLE IF NOT EXISTS employee (
  eid int,
  name String,
  salary String,
  destination String
)
COMMENT 'Employee details'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 's3a://${BUCKET_NAME}/';
;"


log "Copy data"
rm test-data.txt || true
cat <<EOF >> test-data.txt
1201  Gopal       45000    Technical manager
1202  Manisha     45000    Proof reader
1203  Masthanvali 40000    Technical writer
1204  Kiran       40000    Hr Admin
1205  Kranthi     30000    Op Admin
EOF

./aws-cli.sh s3 cp test-data.txt "s3://${BUCKET_NAME}/test-data.txt"

log "List S3 files"
./aws-cli.sh s3 ls --recursive "s3://${BUCKET_NAME}/"

#log "Run HQL"
#./hive.sh -e "SHOW DATABASES;"
#./hive.sh -e "DESCRIBE employee;"
#./hive.sh -e "SELECT * FROM employee;"
