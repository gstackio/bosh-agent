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
    #   device-mapper \
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
curl -fL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" | tar zx && \
mv /docker/* /bin/ && chmod +x /bin/docker* && \
pip install docker-compose==${DOCKER_COMPOSE_VERSION} && \
curl -fL "https://github.com/jwilder/docker-squash/releases/download/v${DOCKER_SQUASH}/docker-squash-linux-amd64-v${DOCKER_SQUASH}.tar.gz" | tar zx && \
mv /docker-squash* /bin/ && chmod +x /bin/docker-squash* && \
rm -rf /var/cache/apk/* && \
rm -rf /root/.cache