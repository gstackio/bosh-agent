#!/usr/bin/env bash

set -eu
lpass ls > /dev/null
fly -t production-local set-pipeline \
    -p hello-docker \
    -c pipeline.yml \
    -l <(lpass show --note "bosh:docker-images concourse secrets") \
