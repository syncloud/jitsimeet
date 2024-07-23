#!/bin/bash -e
/bin/rm -f $SNAP_DATA/saslauthd.socket
exec $SNAP/prosody/bin/saslauthd -a ldap -O $SNAP_DATA/config/saslauthd.conf -c -m $SNAP_DATA/saslauthd.socket -n 5 -d
