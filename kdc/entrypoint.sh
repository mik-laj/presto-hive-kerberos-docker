#!/bin/bash

set -xeuo pipefail

(
  export
  sleep 2;
  if [[ -v POST_BOOTSTRAP_COMMAND ]]; then
      bash -c "$POST_BOOTSTRAP_COMMAND"
  fi
) &
exec "$@"
