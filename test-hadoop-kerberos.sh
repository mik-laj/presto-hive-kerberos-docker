#!/usr/bin/env bash

set -euo pipefail

./kdiag.sh --secure
./kdiag.sh --secure --resource hdfs-default.xml --resource hdfs-site.xml
./kdiag.sh --secure --resource yarn-default.xml --resource yarn-site.xml
