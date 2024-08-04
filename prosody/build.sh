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

apt update
apt install -y build-essential
wget https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.28/cyrus-sasl-2.1.28.tar.gz
tar xf cyrus-sasl-2.1.28.tar.gz
cd cyrus-sasl-2.1.28
./configure \
  --prefix=${BUILD_DIR}/prosody/usr \
  --enable-plain \
  --with-configdir=/snap/jitsimeet/current/config/sasl2 \
  --with-plugindir=/snap/jitsimeet/current/prosody/sasl2
make
make install
cp -r /snap/jitsimeet/current/prosody/sasl2 ${BUILD_DIR}

#apt install -y gcc luarocks libldap2-dev
#luarocks install lualdap LDAP_DIR=/usr LDAP_DI=$(echo /usr/lib/*-linux-gnu*) LDAP_LIBDIR=$(echo /usr/lib/*-linux-gnu*)
