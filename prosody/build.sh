#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/prosody
mkdir -p ${BUILD_DIR}
cp -r /usr ${BUILD_DIR}
cp -r /bin ${BUILD_DIR}
cp -r /lib ${BUILD_DIR}
cp -r /prosody-plugins ${BUILD_DIR}
cp -r /prosody-plugins-contrib ${BUILD_DIR}
cp -r /prosody-plugins-custom ${BUILD_DIR}
cp --remove-destination ${DIR}/bin/* ${BUILD_DIR}/bin

sed -i "s#CFG_SOURCEDIR=.*;#CFG_SOURCEDIR='/snap/jitsimeet/current/prosody/usr/lib/prosody';#g"  ${BUILD_DIR}/usr/bin/prosody
sed -i "s#CFG_CONFIGDIR=.*;#CFG_CONFIGDIR='/var/snap/jitsimeet/current/config';#g"  ${BUILD_DIR}/usr/bin/prosody
sed -i "s#CFG_PLUGINDIR=.*;#CFG_PLUGINDIR='/snap/jitsimeet/current/prosody/usr/lib/prosody/modules/';#g"  ${BUILD_DIR}/usr/bin/prosody
sed -i "s#CFG_DATADIR=.*;#CFG_DATADIR='/var/snap/jitsimeet/current/data';#g"  ${BUILD_DIR}/usr/bin/prosody
