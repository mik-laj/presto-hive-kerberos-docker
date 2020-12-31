#!/usr/bin/env bash

set -euo pipefail

# Terminal Control codes
# see: https://stackoverflow.com/a/5947802
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

function err() {
  echo -e "${COLOR_RED}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*${COLOR_RESET}" >&2
  exit 1
}

function log() {
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*"
}

function create_network() {
    network_name="example.com"
    network="10.5.0.0/24"
    gateway="$(echo ${network} | cut -f1-3 -d'.').254"

    if docker network ls | awk '{print $2}' | grep "^${network_name}$" &> /dev/null; then
      log "Docker network '${network_name}' already exists. Skipping."
      return 0
    fi

    docker network create \
        --driver=bridge \
        --subnet="${network}" \
        --ip-range="${network}" \
        --gateway="${gateway}" \
        "${network_name}" &> /dev/null

    RET_CODE=$?
    if [[ ${RET_CODE} != 0 ]]; then
        log "Fail to create network"
        return ${RET_CODE}
    fi
    log "Created network: ${network_name}"
}

create_network
docker-compose up --build $*