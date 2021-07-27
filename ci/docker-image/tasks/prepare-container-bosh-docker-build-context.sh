#!/bin/bash
set -eux -o pipefail

cp -rp bosh-src/ci/old-docker/main-bosh-${container_engine}/* docker-build-context

cp bosh-cli/*bosh* docker-build-context/bosh

mkdir docker-build-context/bosh-deployment
cp -R bosh-deployment/* docker-build-context/bosh-deployment

bash bosh-src/ci/old-docker/main-bosh-docker/install.sh
echo 'Everything is installed'
bash bosh-agent/bin/test-integration

echo 'Everything worked'