#!/usr/bin/env bash

set -euo pipefail

function usage() {
    CMDNAME="$(basename -- "$0")"

      echo """
Usage: ${CMDNAME} <service_name> <service_type> <keytab_file>

Creates an account for the service.

The service name is combined with the domain to create an principal name. If your service is named
\"presto\" a principal \"presto.example.com\" will be created.

The protocol can have any value, but it must be identical in the server and client configuration.
For example: HTTP.
"""
}

if [[ ! "$#" -eq 3 ]]; then
    echo "You must provide exactly three arguments."
    usage
    exit 1
fi

SERVICE_NAME=$1
SERVICE_TYPE=$2
KEYTAB_FILE=$3

DOMAIN_NAME=example.com
REALM_NAME=EXAMPLE.COM

cat << EOF | kadmin.local &>/dev/null
add_principal -randkey "${SERVICE_NAME}.${DOMAIN_NAME}@${REALM_NAME}"
add_principal -randkey "${SERVICE_TYPE}/${SERVICE_NAME}.${DOMAIN_NAME}@${REALM_NAME}"
ktadd -k ${KEYTAB_FILE} -norandkey "${SERVICE_NAME}.${DOMAIN_NAME}@${REALM_NAME}"
ktadd -k ${KEYTAB_FILE} -norandkey "${SERVICE_TYPE}/${SERVICE_NAME}.${DOMAIN_NAME}@${REALM_NAME}"
quit
EOF

chmod 777 "${KEYTAB_FILE}" &>/dev/null

echo "Created service: ${SERVICE_NAME}"
