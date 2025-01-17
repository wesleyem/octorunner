#!/bin/bash

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
