#!/usr/bin/env bash

absolute_path() {
  (cd "$1" && pwd)
}

scripts_path=$(absolute_path "$(dirname "$0")")

fly -t production-local set-pipeline \
    -p bosh-agent \
    -c $scripts_path/pipeline.yml \
    --load-vars-from <(lpass show -G "bosh-agent concourse secrets" --notes)
