#!/usr/bin/env bash

set -euo pipefail

function usage() {
    CMDNAME="$(basename -- "$0")"

      echo """
Usage: ${CMDNAME} <username> <password> <keytab_file>

Creates an account for the unprivileged client. The authorization data is saved in <keytab_file>.
"""
}

if [[ ! "$#" -eq 3 ]]; then
    echo "You must provide exactly three arguments."
    usage
    exit 1
fi


USERNAME=$1
PASSWORD=$2
KEYTAB_FILE=$3

REALM_NAME=EXAMPLE.COM

cat << EOF | kadmin.local &>/dev/null
add_principal -pw $PASSWORD "${USERNAME}@${REALM_NAME}"
ktadd -k ${KEYTAB_FILE} -norandkey "${USERNAME}@${REALM_NAME}"
listprincs
quit
EOF

chmod 777 "${KEYTAB_FILE}" &>/dev/null

echo "Created client: ${USERNAME}"
