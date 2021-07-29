#!/bin/bash
set -eux -o pipefail
source bosh-agent/ci/docker-image/main-bosh-docker/start-bosh-2.sh
echo "start-docker works"

./bosh-agent/bin/test-integration
echo "test-integration!"