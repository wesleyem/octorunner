FROM ubuntu:24.04 AS deps

ARG RUNNER_VERSION="2.321.0"
ARG DEBIAN_FRONTEND=noninteractive

ENV PATH="/home/docker/actions-runner/bin:$PATH"

# Install necessary packages
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
    openssh-client \
    libicu-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user and home directory for the runner
RUN useradd -m -g docker docker && mkdir -p /home/docker/{actions-runner,.ssh} && chown -R docker:docker /home/docker

# Download and install GitHub Actions runner
WORKDIR /home/docker/actions-runner
RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm -f ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install runner dependencies
RUN ./bin/installdependencies.sh

FROM deps AS main

# Copy the start script and adjust permissions
COPY start.sh /home/docker/start.sh
RUN chmod +x /home/docker/start.sh && chown docker:docker /home/docker/start.sh

# Set non-root user and working directory
USER docker
WORKDIR /home/docker/actions-runner

# Set entrypoint
ENTRYPOINT ["/home/docker/start.sh"]
