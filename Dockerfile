FROM ubuntu:24.04

ARG RUNNER_VERSION="2.321.0"
ARG DEBIAN_FRONTEND=noninteractive

ENV PATH="/home/docker/actions-runner/bin:$PATH"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    curl \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    docker.io \
    libicu-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/docker/actions-runner

WORKDIR /home/docker/actions-runner
RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm -f ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh /home/docker/start.sh
RUN chmod +x /home/docker/start.sh

WORKDIR /home/docker/actions-runner

# Set entrypoint
ENTRYPOINT ["/home/docker/start.sh"]
