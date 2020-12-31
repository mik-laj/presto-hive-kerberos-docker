#!/usr/bin/env bash

set -euo pipefail

./psql.sh -c "SELECT version()"
./psql.sh -c 'select 12345' | grep 12345