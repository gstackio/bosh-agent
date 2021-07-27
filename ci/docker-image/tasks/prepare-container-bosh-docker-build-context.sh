#!/bin/bash
set -eux -o pipefail

cp -rp bosh-src/ci/old-docker/main-bosh-${container_engine}/* docker-build-context

cp bosh-cli/*bosh* docker-build-context/bosh

mkdir docker-build-context/bosh-deployment
cp -R bosh-deployment/* docker-build-context/bosh-deployment

bash bosh-agent/ci/docker-image/main-bosh-docker/install-docker-2.sh
bash bosh-agent/ci/docker-image/main-bosh-docker/install-ruby.sh

echo "install-docker-2"
bash bosh-agent/ci/docker-image/main-bosh-docker/start-bosh.sh
echo "start-docker"

bash bosh-agent/bin/test-integration
echo "test-integration!"