export DOCKER_CHANNEL=stable
export DOCKER_VERSION=19.03.2
export DOCKER_COMPOSE_VERSION=1.24.1
export DOCKER_SQUASH=0.2.0
export DEBIAN_FRONTEND=noninteractive
# Install Docker, Docker Compose, Docker Squash
apt-get update && \
apt-get -y install \
    bash \
    curl \
    python-pip \
    python-dev \
    iptables \
    util-linux \
    ca-certificates \
    gcc \
    libc-dev \
    libffi-dev \
    libssl-dev \
    make \
    git \
    wget \
    net-tools \
    iproute2 \
    && \
curl -fL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" | tar zx 

mv docker/* /bin/ && chmod +x /bin/docker* && \
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

curl -o /usr/local/bin/bosh -L https://github.com/cloudfoundry/bosh-cli/releases/download/v6.4.4/bosh-cli-6.4.4-linux-amd64 
chmod +x /usr/local/bin/bosh

rm -rf /var/cache/apk/* && \
rm -rf /root/.cache