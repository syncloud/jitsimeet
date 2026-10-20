#!/bin/bash -e
DIR=$(cd "$(dirname "$0")" && pwd)
cd "$DIR"

ARTIFACT_SUBDIR=$1
SPEC=$2
DISTRO=${3:-bookworm}

export PLAYWRIGHT_APP_DOMAIN=jitsimeet.${DISTRO}.com
export PLAYWRIGHT_DEVICE_HOST=jitsimeet.${DISTRO}.com
export PLAYWRIGHT_DEVICE_USER=user
export PLAYWRIGHT_DEVICE_PASSWORD=Password1
export PLAYWRIGHT_SSH_USER=root
export PLAYWRIGHT_SSH_PASSWORD=Password1
export PLAYWRIGHT_PROJECT=desktop
export PLAYWRIGHT_ARTIFACT_DIR=/drone/src/artifact/${ARTIFACT_SUBDIR}

apt-get update -qq && apt-get install -y -qq sshpass openssh-client curl
npm ci --no-audit --no-fund
npx playwright test --project=${PLAYWRIGHT_PROJECT} "$SPEC"
