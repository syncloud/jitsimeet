#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/prosody
mkdir -p ${BUILD_DIR}
cp -r /usr ${BUILD_DIR}
cp -r /bin ${BUILD_DIR}
cp -r /lib ${BUILD_DIR}


cp -r /defaults/* ${BUILD_DIR}/config
rm ${BUILD_DIR}/config/conf.d/visitors.cfg.lua
rm ${BUILD_DIR}/config/conf.d/brewery.cfg.lua

cp --remove-destination ${DIR}/bin/* ${BUILD_DIR}/bin
