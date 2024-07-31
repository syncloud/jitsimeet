#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/jicofo
mkdir -p ${BUILD_DIR}
cp -r /bin ${BUILD_DIR}
cp -r /usr ${BUILD_DIR}
cp -r /lib ${BUILD_DIR}

JAVA_DIR=$(echo /usr/lib/jvm/java-17-openjdk-*)
rm -rf $BUILD_DIR/$JAVA_DIR/conf
cp -r --dereference $JAVA_DIR/conf $BUILD_DIR/$JAVA_DIR
rm -rf $BUILD_DIR/$JAVA_DIR/lib
rm -rf $JAVA_DIR/lib/src.zip
cp -r --dereference $JAVA_DIR/lib $BUILD_DIR/$JAVA_DIR

mv $BUILD_DIR/$JAVA_DIR/lib/jspawnhelper $BUILD_DIR/$JAVA_DIR/lib/jspawnhelper.bin
cp $DIR/bin/jspawnhelper $BUILD_DIR/$JAVA_DIR/lib

cp --remove-destination ${DIR}/bin/* ${BUILD_DIR}/bin