#!/bin/bash -xe

#-XX:+HeapDumpOnOutOfMemoryError
#-XX:HeapDumpPath=/tmp

exec $SNAP/jicofo/bin/java.sh \
  -Xmx3072m \
  -Djdk.tls.ephemeralDHKeySize=2048 \
  -Djava.util.logging.config.file=$SNAP_DATA/config/jicofo.log.properties \
  -Dconfig.file=$SNAP_DATA/config/jicofo.conf \
  -cp $(JARS=($SNAP/jicofo/usr/share/jicofo/jicofo*.jar $SNAP/jicofo/usr/share/jicofo/lib/*.jar); IFS=:; echo "${JARS[*]}") \
  org.jitsi.jicofo.Main "$@"