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

log "Checking Kerberos"
check_service "Keytab" "test -f ${KRB5_KTNAME}" 30


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