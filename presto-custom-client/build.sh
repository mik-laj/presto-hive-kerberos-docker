#!/usr/bin/env bash

docker run \
    -v "$PWD:$PWD" \
    -w "$PWD" \
    maven \
        mvn package
