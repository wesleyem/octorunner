#!/bin/bash

# Start the Docker daemon without sudo (as root)
dockerd &

# Wait for Docker to be ready
TIMEOUT=10
SECONDS=0
while ! docker info > /dev/null 2>&1; do
    echo "Waiting for Docker to start..."
    sleep 1
    if [ $SECONDS -ge $TIMEOUT ]; then
        echo "Docker failed to start within $TIMEOUT seconds."
        exit 1
    fi
done

echo "Docker is running!"

if [ -z "$REPO" ] || [ -z "$TOKEN" ]; then
    echo "Error: REPO and TOKEN environment variables must be set."
    exit 1
fi

REPOSITORY=$REPO
ACCESS_TOKEN=$TOKEN

echo "REPO: ${REPOSITORY}"
echo "ACCESS_TOKEN: <hidden>"

REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" \
    https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)

if [ -z "$REG_TOKEN" ]; then
    echo "Failed to retrieve the registration token. Please check your REPOSITORY and ACCESS_TOKEN."
    exit 1
fi

cd /home/docker/actions-runner
./config.sh --url https://github.com/${REPOSITORY} --token ${REG_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
    echo "Runner removed successfully."
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
