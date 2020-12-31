#!/bin/bash

set -euo pipefail

# Terminal Control codes
# see: https://stackoverflow.com/a/5947802
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

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

function log() {
  echo -e "${COLOR_GREEN}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*${COLOR_RESET}"
}

if [ -f /tmp/presto-initiaalized ]; then
  exec /bin/sh -c "$@"
fi

PRESTO_CONFIG_FILE="/usr/lib/presto/default/etc/config.properties"
JVM_CONFIG_FILE="/usr/lib/presto/default/etc/jvm.config"

log "Generate self-signed SSL certificate"
JKS_KEYSTORE_FILE=/tmp/ssl_keystore.jks
JKS_KEYSTORE_PASS=presto

keytool \
    -genkeypair \
    -alias "presto-ssl" \
    -keyalg RSA \
    -keystore "${JKS_KEYSTORE_FILE}" \
    -validity 10000 \
    -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown"\
    -storepass "${JKS_KEYSTORE_PASS}"

log "Set up SSL in ${PRESTO_CONFIG_FILE}"
cat << EOF >> "${PRESTO_CONFIG_FILE}"
http-server.https.enabled=true
http-server.https.port=7778
http-server.https.keystore.path=${JKS_KEYSTORE_FILE}
http-server.https.keystore.key=${JKS_KEYSTORE_PASS}
node.internal-address-source=FQDN
EOF

if [[ -n "${KRB5_CONFIG=}" ]] ; then
    log "Set up Kerberos in ${PRESTO_CONFIG_FILE}"
    cat << EOF >> "${PRESTO_CONFIG_FILE}"
http-server.authentication.type=KERBEROS
http-server.authentication.krb5.service-name=HTTP
http-server.authentication.krb5.principal-hostname=${KRB5_PRINCIPAL}
http-server.authentication.krb5.keytab=${KRB5_KTNAME}
http.authentication.krb5.config=${KRB5_CONFIG}
EOF

    log "Add debug Kerberos options to ${JVM_CONFIG_FILE}"
    cat <<"EOF" >> "${JVM_CONFIG_FILE}"
-Dsun.security.krb5.debug=true
-Dlog.enable-console=true
EOF
fi

HIVE_CATALOG_CONFIG_FILE="/usr/lib/presto/default/etc/catalog/hive.properties"

cat << EOF >> "${HIVE_CATALOG_CONFIG_FILE}"
connector.name=hive-hadoop2

hive.metastore.uri=${HIVE_METASTORE_URI}

hive.metastore.authentication.type=KERBEROS
hive.metastore.service.principal=hive/hive-metastore-hive-metastore.example.com@EXAMPLE.COM
hive.metastore.client.principal=hive-metastore-presto.example.com@EXAMPLE.COM
hive.metastore.client.keytab=${KRB5_KTNAME}

hive.hdfs.authentication.type=KERBEROS
hive.hdfs.presto.principal=hive-metastore-presto.example.com@EXAMPLE.COM
hive.hdfs.presto.keytab=${KRB5_KTNAME}

hive.s3.aws-access-key=${S3_ACCESS_KEY}
hive.s3.aws-secret-key=${S3_SECRET_KEY}
hive.s3.endpoint=${S3_ENDPOINT}
hive.s3.path-style-access=true
hive.s3.ssl.enabled=false
EOF

log "Waiting for keytab: ${KRB5_KTNAME}"
check_service "Keytab" "test -f ${KRB5_KTNAME}" 30

touch /tmp/presto-initiaalized

echo "Config: ${JVM_CONFIG_FILE}"
cat "${JVM_CONFIG_FILE}"

echo "Config: ${PRESTO_CONFIG_FILE}"
cat "${PRESTO_CONFIG_FILE}"

echo "Config: ${HIVE_CATALOG_CONFIG_FILE}"
cat "${HIVE_CATALOG_CONFIG_FILE}"

log "Executing cmd: ${*}"
exec /bin/sh -c "${@}"
