#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/prosody
${BUILD_DIR}/bin/lua -v
${BUILD_DIR}/bin/saslauthd -v
${BUILD_DIR}/bin/prosodyctl.sh || true
