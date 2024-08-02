#!/bin/bash -e

#-XX:+HeapDumpOnOutOfMemoryError
#-XX:HeapDumpPath=/tmp

exec $SNAP/jvb/bin/java.sh \
  -XX:+UseG1GC \
  -Djdk.tls.ephemeralDHKeySize=2048 \
  -Djdk.net.usePlainDatagramSocketImpl=true \
  -Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=$SNAP_DATA \
  -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=config \
  -Djava.util.logging.config.file=$SNAP_DATA/config/jvb.log.properties \
  -Dconfig.file=$SNAP_DATA/config/jvb.conf \
  -cp $SNAP/jvb/usr/share/jitsi-videobridge/jitsi-videobridge.jar:$SNAP/jvb/usr/share/jitsi-videobridge/lib/* \
  org.jitsi.videobridge.MainKt
