#!/bin/bash

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

function check_service {
    INTEGRATION_NAME=$1
    CALL=$2
    MAX_CHECK=${3}
    echo "Start checking ${INTEGRATION_NAME}"
    while true
    do
        set +e
        LAST_CHECK_RESULT=$(eval "${CALL}" 2>&1)
        RES=$?
        set -e
        if [[ ${RES} == 0 ]]; then
            echo -e "${COLOR_GREEN}Working${COLOR_RESET}"
            break
        else
            echo "Checking ${INTEGRATION_NAME}. Please wait."
            MAX_CHECK=$((MAX_CHECK-1))
        fi
        if [[ ${MAX_CHECK} == 0 ]]; then
            echo -e "${COLOR_RED}Maximum number of retries while checking service. Exiting.${COLOR_RESET}"
            break
        else
            sleep 1
        fi
    done
    if [[ ${RES} != 0 ]]; then
        echo "Service could not be started!"
        echo
        echo "${LAST_CHECK_RESULT}"
        echo
        return ${RES}
    fi
}

function check_kerberos {
  check_service "Keytab" "test -f ${KRB5_KTNAME}" 30
  KDC_HOST="$(cat /etc/krb5.conf | grep "\s\+kdc\s\+=" | cut -d "=" -f 2 | xargs)"
  check_service "Kerberos KDC" "nc -zvv '${KDC_HOST}' 88" 30
}

function check_database {
  # Auto-detect DB parameters
  [[ ${HIVE_METASTORE_JDBC_URL} =~ jdbc:([^:]*)://([^@/]*)@?([^/:]*):?([0-9]*)/([^\?]*)\??(.*) ]] && \
      DETECTED_DB_BACKEND=${BASH_REMATCH[1]} &&
      # Not used USER match
      DETECTED_DB_HOST=${BASH_REMATCH[2]} &&
      DETECTED_DB_PORT=${BASH_REMATCH[3]} &&
      # Not used SCHEMA match
      # Not used PARAMS match
  if [[ -z "${DETECTED_DB_PORT=}" ]]; then
    DETECTED_DB_PORT=5432
  fi

  check_service "PostgreSQL" "nc -zvv ${DETECTED_DB_HOST} ${DETECTED_DB_PORT}" "20"
}

log "Checking environment"
check_kerberos
check_database

log "Generating configuration"
envsubst < "${HADOOP_CONF_DIR}/core-site.template.xml" > "${HADOOP_CONF_DIR}/core-site.xml"
#envsubst < "${HADOOP_CONF_DIR}/hdfs-site.template.xml" > "${HADOOP_CONF_DIR}/hdfs-site.xml"
#envsubst < "${HADOOP_CONF_DIR}/yarn-site.template.xml" > "${HADOOP_CONF_DIR}/yarn-site.xml"
envsubst < "${HIVE_CONF_DIR}/hive-site.template.xml" > "${HIVE_CONF_DIR}/hive-site.xml"
#run_verbose cat "${HADOOP_CONF_DIR}/core-site.xml"
#run_verbose cat "${HADOOP_CONF_DIR}/hdfs-site.xml"
#run_verbose cat "${HADOOP_CONF_DIR}/yarn-site.xml"
#run_verbose cat "${HIVE_CONF_DIR}/hive-site.xml"

log 'Initializing kerberos'
echo "KRB5_KTNAME=${KRB5_KTNAME}"
echo "HIVE_METASTORE_KERBEROS_PRINCIPAL=${HIVE_METASTORE_KERBEROS_PRINCIPAL}"
#run_verbose ls -lah /etc/security/
#run_verbose ls -lah /etc/security/keytab

#ln -s /root/kerberos-keytabs/nn.service.keytab /etc/security/keytab
#run_verbose klist -e -k -t /etc/security/keytab/nn.service.keytab
#run_verbose klist -e -k -t /etc/security/keytab/sn.service.keytab
#run_verbose klist -e -k -t  /etc/security/keytab/dn.service.keytab

run_verbose klist -k "${KRB5_KTNAME}"
run_verbose kinit -k "${HIVE_METASTORE_KERBEROS_PRINCIPAL}"
run_verbose klist

log "Executing cmd: ${*}"
exec ${*}