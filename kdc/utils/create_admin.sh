#!/usr/bin/env bash

set -euo pipefail

function usage() {
    CMDNAME="$(basename -- "$0")"

      echo """
Usage: ${CMDNAME} <username> <password>

Creates an account for the administrator.
"""
}

if [[ ! "$#" -eq 2 ]]; then
    echo "You must provide exactly two arguments."
    usage
    exit 1
fi

USERNAME=$1
PASSWORD=$2

REALM_NAME=EXAMPLE.COM

cat << EOF | kadmin.local &>/dev/null
add_principal -pw $PASSWORD "${USERNAME}/admin@${REALM_NAME}"
listprincs
quit
EOF

echo "Created admin: ${USERNAME}"
