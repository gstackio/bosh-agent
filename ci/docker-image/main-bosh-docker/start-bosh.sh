#!/usr/bin/env bash

set -ex

function stop_docker() {
  service docker stop
}

function start_docker() {
  mkdir -p /var/log
  mkdir -p /var/run
  trap stop_docker EXIT
  service docker start

  rc=1
  for i in $(seq 1 100); do
    echo waiting for docker to come up...
    sleep 1
    set +e
    docker info
    rc=$?
    set -e
    if [ "$rc" -eq "0" ]; then
        break
    fi
  done

  if [ "$rc" -ne "0" ]; then
    exit 1
  fi
}

function main() {
  start_docker 
}

main $@
