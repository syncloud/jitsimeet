#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/jvb
JAVA_HOME=$(echo $BUILD_DIR/usr/lib/jvm/java-17-openjdk-*)
${BUILD_DIR}/bin/java.sh -version
${JAVA_HOME}/lib/jspawnhelper --help