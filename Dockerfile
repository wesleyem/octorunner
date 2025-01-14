FROM ubuntu:24.04

# Set ARGs with defaults
ARG RUNNER_VERSION="2.321.0"
ARG DEBIAN_FRONTEND=noninteractive

# Set environment variables to reduce warnings
ENV PATH="/home/docker/actions-runner/bin:$PATH"

# Update and install system dependencies
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

# Create docker user and directories
RUN useradd -m -g docker docker && mkdir -p /home/docker/actions-runner

RUN usermod -aG docker docker

# Download and extract GitHub Actions runner
WORKDIR /home/docker/actions-runner
RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm -f ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install dependencies for the GitHub Actions runner
RUN /home/docker/actions-runner/bin/installdependencies.sh

# Set permissions for the docker user
RUN chown -R docker:docker /home/docker

# Copy the entrypoint script
COPY start.sh /home/docker/start.sh
RUN chmod +x /home/docker/start.sh

RUN systemctl enable docker.service
RUN systemctl enable containerd.service

# Switch to the docker user
USER docker
WORKDIR /home/docker/actions-runner

# Set entrypoint
ENTRYPOINT ["/home/docker/start.sh"]
