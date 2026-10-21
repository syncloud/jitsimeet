#!/bin/bash -ex
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

HOOKS=${DIR}/../build/snap/meta/hooks
BIN=${DIR}/../build/snap/bin
mkdir -p ${HOOKS} ${BIN}

CGO_ENABLED=0 go build -buildvcs=false -o ${HOOKS}/install ./cmd/install
CGO_ENABLED=0 go build -buildvcs=false -o ${HOOKS}/configure ./cmd/configure
CGO_ENABLED=0 go build -buildvcs=false -o ${HOOKS}/pre-refresh ./cmd/pre-refresh
CGO_ENABLED=0 go build -buildvcs=false -o ${HOOKS}/post-refresh ./cmd/post-refresh
CGO_ENABLED=0 go build -buildvcs=false -o ${BIN}/cli ./cmd/cli
