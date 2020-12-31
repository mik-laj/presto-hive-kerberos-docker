#!/usr/bin/env bash

set -euo pipefail

docker-compose down --volumes --remove-orphans
docker network rm "example.com" || true
